import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Parámetros de Argon2id. La memoria se mantiene moderada (12 MiB) porque
/// esta app usa la implementación pura en Dart de `package:cryptography`
/// (sin aceleración nativa): valores más altos, como los 19-64 MiB que
/// recomienda OWASP para implementaciones nativas, tardarían varios segundos
/// en un teléfono de gama media y bloquearían la UI de login/registro.
const int _memoriaKiB = 12288; // 12 MiB
const int _iteraciones = 3;
const int _paralelismo = 1;
const int _longitudHashBytes = 32;
const int _longitudSalBytes = 16;

/// Hashea [contrasena] con Argon2id y una sal aleatoria nueva (RFC 9106,
/// ganador de la Password Hashing Competition; recomendado por OWASP como
/// primera opción para contraseñas). El resultado codifica en un solo string
/// el algoritmo, los parámetros y la sal junto con el hash — igual que el
/// formato PHC de bcrypt/argon2 — para poder guardarlo tal cual en la
/// columna `passwordHash` sin necesitar una columna de sal aparte:
///
///   `argon2id$m=12288,t=3,p=1$<sal en base64>$<hash en base64>`
///
/// Cada llamada genera una sal distinta, así que dos usuarios con la misma
/// contraseña nunca terminan con el mismo valor guardado.
Future<String> hashContrasena(String contrasena) async {
  final sal = _generarSal();
  final algoritmo = _crearAlgoritmo(
    memoria: _memoriaKiB,
    iteraciones: _iteraciones,
    paralelismo: _paralelismo,
  );
  final hash = await _derivarHash(algoritmo, contrasena, sal);
  return 'argon2id\$m=$_memoriaKiB,t=$_iteraciones,p=$_paralelismo'
      '\$${base64Url.encode(sal)}\$${base64Url.encode(hash)}';
}

/// Verifica que [contrasena] corresponda al [hashAlmacenado] producido por
/// [hashContrasena]. Vuelve a derivar el hash usando la MISMA sal y los
/// mismos parámetros leídos del string guardado (nunca una sal nueva) y
/// compara los bytes resultantes en tiempo constante, para no filtrar
/// información por temporización.
Future<bool> verificarContrasena(String contrasena, String hashAlmacenado) async {
  final partes = hashAlmacenado.split(r'$');
  if (partes.length != 4 || partes[0] != 'argon2id') return false;

  final parametros = _parametrosDesde(partes[1]);
  if (parametros == null) return false;

  final List<int> sal;
  final List<int> hashEsperado;
  try {
    sal = base64Url.decode(partes[2]);
    hashEsperado = base64Url.decode(partes[3]);
  } catch (_) {
    return false;
  }

  final algoritmo = _crearAlgoritmo(
    memoria: parametros.$1,
    iteraciones: parametros.$2,
    paralelismo: parametros.$3,
    longitudHash: hashEsperado.length,
  );
  final hashCalculado = await _derivarHash(algoritmo, contrasena, sal);
  return _sonIguales(hashCalculado, hashEsperado);
}

Argon2id _crearAlgoritmo({
  required int memoria,
  required int iteraciones,
  required int paralelismo,
  int longitudHash = _longitudHashBytes,
}) {
  return Argon2id(
    memory: memoria,
    iterations: iteraciones,
    parallelism: paralelismo,
    hashLength: longitudHash,
  );
}

Future<List<int>> _derivarHash(Argon2id algoritmo, String contrasena, List<int> sal) async {
  final claveDerivada = await algoritmo.deriveKey(
    secretKey: SecretKey(utf8.encode(contrasena)),
    nonce: sal,
  );
  return claveDerivada.extractBytes();
}

List<int> _generarSal() {
  final aleatorio = Random.secure();
  return List<int>.generate(_longitudSalBytes, (_) => aleatorio.nextInt(256));
}

/// Parsea `"m=12288,t=3,p=1"` a `(memoria, iteraciones, paralelismo)`.
(int, int, int)? _parametrosDesde(String segmento) {
  final valores = <String, int>{};
  for (final par in segmento.split(',')) {
    final partes = par.split('=');
    if (partes.length != 2) return null;
    final valor = int.tryParse(partes[1]);
    if (valor == null) return null;
    valores[partes[0]] = valor;
  }
  final m = valores['m'];
  final t = valores['t'];
  final p = valores['p'];
  if (m == null || t == null || p == null) return null;
  return (m, t, p);
}

/// Comparación de bytes en tiempo constante: evita que un atacante deduzca
/// en qué byte difiere el hash midiendo cuánto tarda la comparación.
bool _sonIguales(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diferencia = 0;
  for (var i = 0; i < a.length; i++) {
    diferencia |= a[i] ^ b[i];
  }
  return diferencia == 0;
}

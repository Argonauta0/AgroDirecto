enum RolSeguridad {
  admin,
  auditor,
  usuario;

  static const Map<RolSeguridad, String> _valoresDb = {
    RolSeguridad.admin: 'ADMIN',
    RolSeguridad.auditor: 'AUDITOR',
    RolSeguridad.usuario: 'USUARIO',
  };

  String toJson() => _valoresDb[this]!;

  static RolSeguridad fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(RolSeguridad.usuario, 'USUARIO'),
        )
        .key;
  }
}

extension RolSeguridadEtiqueta on RolSeguridad {
  String get etiqueta {
    switch (this) {
      case RolSeguridad.admin:
        return 'Administrador';
      case RolSeguridad.auditor:
        return 'Auditor';
      case RolSeguridad.usuario:
        return 'Usuario';
    }
  }
}

enum TipoPerfil {
  productor,
  comprador;

  static const Map<TipoPerfil, String> _valoresDb = {
    TipoPerfil.productor: 'PRODUCTOR',
    TipoPerfil.comprador: 'COMPRADOR',
  };

  String toJson() => _valoresDb[this]!;

  static TipoPerfil fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(TipoPerfil.productor, 'PRODUCTOR'),
        )
        .key;
  }
}

extension TipoPerfilEtiqueta on TipoPerfil {
  String get etiqueta {
    switch (this) {
      case TipoPerfil.productor:
        return 'Productor';
      case TipoPerfil.comprador:
        return 'Comprador';
    }
  }
}

class Usuario {
  final String id;
  final String nombreCompleto;
  final String telefono;
  final String passwordHash;
  final RolSeguridad rolSeguridad;
  final TipoPerfil tipoPerfil;
  final String departamento;
  final String municipio;
  final String direccionExacta;
  final DateTime creadoEn;

  Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.telefono,
    required this.tipoPerfil,
    required this.departamento,
    required this.municipio,
    this.passwordHash = '',
    this.rolSeguridad = RolSeguridad.usuario,
    this.direccionExacta = '',
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  bool get esProductor => tipoPerfil == TipoPerfil.productor;
  bool get esComprador => tipoPerfil == TipoPerfil.comprador;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombreCompleto: json['nombreCompleto'] as String,
      telefono: json['telefono'] as String,
      passwordHash: json['passwordHash'] as String? ?? '',
      rolSeguridad: RolSeguridad.fromJson(json['rolSeguridad'] as String? ?? 'USUARIO'),
      tipoPerfil: TipoPerfil.fromJson(json['tipoPerfil'] as String),
      departamento: json['departamento'] as String,
      municipio: json['municipio'] as String,
      direccionExacta: json['direccionExacta'] as String? ?? '',
      creadoEn: json['creadoEn'] != null
          ? DateTime.parse(json['creadoEn'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'telefono': telefono,
      'passwordHash': passwordHash,
      'rolSeguridad': rolSeguridad.toJson(),
      'tipoPerfil': tipoPerfil.toJson(),
      'departamento': departamento,
      'municipio': municipio,
      'direccionExacta': direccionExacta,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  Usuario copyWith({
    String? id,
    String? nombreCompleto,
    String? telefono,
    String? passwordHash,
    RolSeguridad? rolSeguridad,
    TipoPerfil? tipoPerfil,
    String? departamento,
    String? municipio,
    String? direccionExacta,
    DateTime? creadoEn,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      passwordHash: passwordHash ?? this.passwordHash,
      rolSeguridad: rolSeguridad ?? this.rolSeguridad,
      tipoPerfil: tipoPerfil ?? this.tipoPerfil,
      departamento: departamento ?? this.departamento,
      municipio: municipio ?? this.municipio,
      direccionExacta: direccionExacta ?? this.direccionExacta,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario &&
        other.id == id &&
        other.nombreCompleto == nombreCompleto &&
        other.telefono == telefono &&
        other.passwordHash == passwordHash &&
        other.rolSeguridad == rolSeguridad &&
        other.tipoPerfil == tipoPerfil &&
        other.departamento == departamento &&
        other.municipio == municipio &&
        other.direccionExacta == direccionExacta &&
        other.creadoEn == creadoEn;
  }

  @override
  int get hashCode => Object.hash(
        id,
        nombreCompleto,
        telefono,
        passwordHash,
        rolSeguridad,
        tipoPerfil,
        departamento,
        municipio,
        direccionExacta,
        creadoEn,
      );

  @override
  String toString() =>
      'Usuario(id: $id, nombreCompleto: $nombreCompleto, tipoPerfil: $tipoPerfil, '
      'rolSeguridad: $rolSeguridad, telefono: $telefono)';
}

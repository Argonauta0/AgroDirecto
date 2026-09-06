# AgroDirecto

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.13-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.13-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)


> Aplicación móvil que conecta directamente a productores agrícolas con compradores (restaurantes, comedores, supermercados), eliminando intermediarios en la cadena de comercialización.

## Stack Tecnológico y Dependencias

| Categoría          | Tecnología / Paquete                                                  |
|---------------------|-------------------------------------------------------------------------|
| Lenguaje            | [Dart](https://dart.dev) `^3.13.0`                                     |
| Framework           | [Flutter](https://flutter.dev) SDK                                     |
| UI Toolkit          | Material Design (widgets nativos de Flutter)                           |
| Tipografía          | [`google_fonts`](https://pub.dev/packages/google_fonts) `^6.2.1`       |
| Iconografía         | [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) `^1.0.8` |
| Gestión de estado   | `StatefulWidget` + `setState` (estado local por vista)                 |
| Backend / Base de datos | [Supabase](https://supabase.com) (PostgreSQL gestionado) vía [`supabase_flutter`](https://pub.dev/packages/supabase_flutter) `^2.8.0` |
| Seguridad de contraseñas | [`cryptography`](https://pub.dev/packages/cryptography) `^2.9.0` — hashing Argon2id con sal por usuario |
| Linting             | [`flutter_lints`](https://pub.dev/packages/flutter_lints) `^6.0.0`     |
| Testing             | `flutter_test` (widget tests, SDK de Flutter)                          |
| Plataforma soportada| Android  |

> **Nota:** la app ya no usa un repositorio en memoria. Los datos (usuarios, productos, ofertas agrícolas, solicitudes de compra y facturas) se persisten en tablas de Supabase/PostgreSQL a través de `lib/servicios/servicio_supabase.dart`. La URL y la clave pública (`anon`/`publishable`) del proyecto Supabase están configuradas en `lib/main.dart`; no se requiere un archivo `.env` para ejecutar la app, pero sí una conexión a internet y que el proyecto de Supabase correspondiente exista y tenga las tablas esperadas.

## Backend: conexión con Supabase

La app se conecta a un proyecto de Supabase al arrancar, en `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'https://<proyecto>.supabase.co',
  publishableKey: '<anon/publishable key>',
);
```

- La **`publishableKey`** es la clave pública (`anon key`) de Supabase, diseñada para ser incluida en el cliente. La protección real de los datos depende de que las tablas tengan **Row Level Security (RLS)** habilitado con políticas adecuadas en el proyecto de Supabase (no versionadas en este repo).
- Toda la lógica de acceso a datos vive en `lib/servicios/servicio_supabase.dart`, que expone métodos estáticos (`registrarUsuario`, `login`, `obtenerCatalogo`, `agregarOferta`, `procesarPedido`, etc.) sobre las tablas `usuario`, `producto`, `oferta_agricola`, `solicitud_compra` y `factura`. Las vistas ya no mantienen listas locales de dominio: consultan y mutan estas tablas de forma asíncrona.
- **Autenticación propia (no `supabase.auth`)**: el login/registro se implementa contra la tabla `usuario` propia, no contra el sistema de Auth de Supabase. Esto implica que no hay tokens de sesión ni expiración automática — el estado de sesión se guarda en memoria en `ServicioSupabase.usuarioActual`.

## Seguridad de contraseñas

Las contraseñas nunca se guardan ni se transmiten en texto plano. `lib/utilidades/seguridad.dart` implementa:

- **Hashing con Argon2id** (RFC 9106, recomendado por OWASP), vía `package:cryptography`, con parámetros ajustados para no bloquear la UI en dispositivos móviles (12 MiB de memoria, 3 iteraciones, paralelismo 1).
- **Sal aleatoria distinta por usuario** (`Random.secure()`, 16 bytes), para que dos usuarios con la misma contraseña nunca produzcan el mismo hash.
- **Formato de almacenamiento tipo PHC** en la columna `passwordHash`, autocontenido (algoritmo + parámetros + sal + hash):
  ```
  argon2id$m=12288,t=3,p=1$<sal en base64>$<hash en base64>
  ```
- **Verificación en tiempo constante** al iniciar sesión, para evitar ataques de temporización.

## Arquitectura y Estructura del Software

El proyecto sigue una organización por capas simple, típica de una app Flutter de una sola aplicación (sin paquetes internos separados):

- **`modelos/`** — Entidades del dominio (POJOs/DTOs de Dart) con serialización propia (`toJson` / `fromJson`).
- **`servicios/`** — Acceso a datos y lógica de negocio contra el backend (`ServicioSupabase`).
- **`vistas/`** — Pantallas (`Widget`s de pantalla completa), una por flujo de usuario.
- **`widgets/`** — Componentes de UI reutilizables entre vistas.
- **`utilidades/`** — Helpers puros sin estado (formato de fechas, hashing/verificación de contraseñas).
- **`tema_app.dart`** — Definición centralizada de paleta de colores y `ThemeData`.

```text
agro_directo/
├── android/                            # Proyecto nativo Android (Gradle)
├── lib/
│   ├── main.dart                       # Punto de entrada de la app + inicialización de Supabase
│   ├── tema_app.dart                   # Paleta de colores y tema Material
│   ├── modelos/                        # Entidades del dominio
│   │   ├── modelo_usuario.dart         # Usuario, roles y tipos de perfil (productor/comprador)
│   │   ├── modelo_oferta_agricola.dart # Oferta/cosecha publicada por un productor
│   │   ├── modelo_producto.dart        # Producto del catálogo
│   │   ├── modelo_solicitud_compra.dart# Solicitud de compra de un comprador
│   │   └── modelo_factura.dart         # Factura y desglose de comisión de la plataforma
│   ├── servicios/
│   │   └── servicio_supabase.dart      # Acceso a datos (Supabase/PostgreSQL) y autenticación
│   ├── utilidades/
│   │   ├── formato_fecha.dart          # Helpers de formato de fechas en español
│   │   └── seguridad.dart              # Hashing y verificación de contraseñas (Argon2id)
│   ├── vistas/                         # Pantallas de la aplicación
│   │   ├── vista_login.dart
│   │   ├── vista_registro.dart
│   │   ├── vista_catalogo.dart
│   │   ├── vista_panel_productor.dart
│   │   ├── vista_publicar.dart
│   │   ├── vista_editar_oferta.dart
│   │   └── vista_pedido.dart
│   └── widgets/                        # Componentes reutilizables
│       ├── tarjeta_producto.dart
│       ├── indicador_inventario.dart
│       └── resumen_liquidacion.dart
├── test/
│   └── widget_test.dart                # Pruebas de widgets
├── pubspec.yaml                        # Dependencias y metadata del proyecto
├── pubspec.lock                        # Versiones resueltas de dependencias
└── analysis_options.yaml               # Reglas de linting (flutter_lints)
```

## Requisitos Previos del Sistema

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>= 3.13` (incluye Dart `>= 3.13`)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/) con el plugin de Flutter
- Android SDK / Java (gestionados por Android Studio)
- Un emulador Android configurado o un dispositivo físico con depuración USB habilitada
- Git

Verifica que tu entorno esté correctamente configurado con:

```bash
flutter doctor
```

## Instalación Básica y Configuración Local

1. **Clonar el repositorio**

   ```bash
   git clone https://github.com/<usuario>/agro_directo.git
   cd agro_directo
   ```

2. **Instalar dependencias**

   ```bash
   flutter pub get
   ```

3. **Configuración de entorno**

   La app se conecta a un proyecto de Supabase configurado directamente en `lib/main.dart` (URL + clave pública `anon`/`publishable`). No se requiere un archivo `.env`, pero sí conexión a internet y que ese proyecto Supabase exista con las tablas `usuario`, `producto`, `oferta_agricola`, `solicitud_compra` y `factura`. Si vas a apuntar a tu propio proyecto de Supabase, reemplaza `url` y `publishableKey` en `Supabase.initialize(...)`.

4. **Verificar dispositivos disponibles**

   ```bash
   flutter devices
   ```

## Instrucciones de Ejecución y Compilación

### Ejecución en modo desarrollo

```bash
flutter run
```

Para ejecutar en un dispositivo o emulador específico:

```bash
flutter run -d <device_id>
```

### Compilación (build) de producción

Generar APK de release:

```bash
flutter build apk --release
```

Generar App Bundle (recomendado para publicación en Google Play):

```bash
flutter build appbundle --release
```

## Scripts y Comandos Útiles

| Comando                         | Descripción                                                  |
|-----------------------------------|-----------------------------------------------------------------|
| `flutter pub get`                | Instala/actualiza las dependencias del proyecto                |
| `flutter pub upgrade`            | Actualiza las dependencias a sus últimas versiones compatibles |
| `flutter run`                    | Ejecuta la app en modo debug en el dispositivo conectado        |
| `flutter test`                   | Ejecuta las pruebas de widgets ubicadas en `test/`               |
| `flutter analyze`                | Analiza el código en busca de errores y problemas de lint       |
| `flutter build apk --release`    | Genera el APK de producción                                     |
| `flutter build appbundle --release` | Genera el App Bundle para Google Play                        |
| `flutter clean`                  | Limpia archivos de build y caché del proyecto                    |
| `flutter doctor`                 | Diagnostica el estado del entorno de desarrollo Flutter          |

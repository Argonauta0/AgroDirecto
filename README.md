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
| Capa de datos       | Repositorio en memoria (`DatosEnMemoria`) — sin backend externo aún    |
| Linting             | [`flutter_lints`](https://pub.dev/packages/flutter_lints) `^6.0.0`     |
| Testing             | `flutter_test` (widget tests, SDK de Flutter)                          |
| Plataforma soportada| Android  |

> **Nota:** la aplicación no requiere `.env`, llaves de API ni base de datos para ejecutarse localmente. Toda la información (usuarios, ofertas, productos y pedidos) vive en memoria dentro de `lib/datos_en_memoria.dart` y se reinicia en cada ejecución. La capa de datos está aislada para poder sustituirse por un backend real (REST, Firebase, etc.) sin afectar las vistas.

## Arquitectura y Estructura del Software

El proyecto sigue una organización por capas simple, típica de una app Flutter de una sola aplicación (sin paquetes internos separados):

- **`modelos/`** — Entidades del dominio (POJOs/DTOs de Dart) con serialización propia (`toJson` / `fromJson`).
- **`vistas/`** — Pantallas (`Widget`s de pantalla completa), una por flujo de usuario.
- **`widgets/`** — Componentes de UI reutilizables entre vistas.
- **`utilidades/`** — Helpers puros sin estado (formato de fechas, etc.).
- **`datos_en_memoria.dart`** — Repositorio central que simula la persistencia/backend.
- **`tema_app.dart`** — Definición centralizada de paleta de colores y `ThemeData`.

```text
agro_directo/
├── android/                          # Proyecto nativo Android (Gradle)
├── lib/
│   ├── main.dart                     # Punto de entrada de la app
│   ├── tema_app.dart                 # Paleta de colores y tema Material
│   ├── datos_en_memoria.dart         # Repositorio de datos en memoria (mock de backend)
│   ├── modelos/                      # Entidades del dominio
│   │   ├── modelo_usuario.dart       # Usuario, roles y tipos de perfil (productor/comprador)
│   │   ├── modelo_oferta_lote.dart   # Oferta/lote publicado por un productor
│   │   ├── modelo_producto.dart      # Producto del catálogo
│   │   └── modelo_pedido.dart        # Pedido/reserva de un comprador
│   ├── utilidades/
│   │   └── formato_fecha.dart        # Helpers de formato de fechas en español
│   ├── vistas/                       # Pantallas de la aplicación
│   │   ├── vista_login.dart
│   │   ├── vista_registro.dart
│   │   ├── vista_catalogo.dart
│   │   ├── vista_panel_productor.dart
│   │   ├── vista_publicar.dart
│   │   ├── vista_editar_oferta.dart
│   │   └── vista_pedido.dart
│   └── widgets/                      # Componentes reutilizables
│       ├── tarjeta_producto.dart
│       ├── indicador_inventario.dart
│       └── resumen_liquidacion.dart
├── test/
│   └── widget_test.dart              # Pruebas de widgets
├── pubspec.yaml                      # Dependencias y metadata del proyecto
├── pubspec.lock                      # Versiones resueltas de dependencias
└── analysis_options.yaml             # Reglas de linting (flutter_lints)
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

   No se requieren archivos `.env`, llaves de API ni configuración adicional: la app usa datos en memoria (`lib/datos_en_memoria.dart`) que se cargan al iniciar.

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

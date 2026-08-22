# AgroDirecto

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.13-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.13-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)

## Descripción y Propósito

**AgroDirecto** es una aplicación móvil que conecta directamente a productores agrícolas con compradores (restaurantes, comedores, supermercados), eliminando intermediarios en la cadena de comercialización. Los productores publican sus cosechas disponibles con precio y cantidad, y los compradores exploran un catálogo filtrable, revisan la ficha de trazabilidad de cada lote y coordinan la reserva directamente con el productor.

## Stack Tecnológico

| Categoría              | Tecnología / Herramienta                                   |
|-------------------------|-------------------------------------------------------------|
| Frontend / Mobile       | [Flutter](https://flutter.dev) 3.x · Dart 3.x               |
| UI Toolkit               | Material Design (widgets nativos de Flutter)                |
| Gestión de estado        | `StatefulWidget` + `setState` (estado local por vista)      |
| Capa de datos            | Repositorio en memoria (`DatosEnMemoria`) — sin backend aún |
| Calidad de código        | `flutter_lints`, `flutter analyze`                           |
| Testing                  | `flutter_test` (widget tests)                                |
| Target actual            | Android (proyecto Flutter multiplataforma, listo para agregar iOS/Web) |

> **Nota:** la versión actual del proyecto usa una capa de datos en memoria (`lib/datos_en_memoria.dart`) como simulación de backend para efectos de demo/hackathon. No requiere base de datos ni variables de entorno para ejecutarse localmente. Está estructurada para ser reemplazada por un backend real (REST/Firebase/etc.) sin afectar las vistas.

## Arquitectura / Estructura del Proyecto

```text
agro_directo/
├── android/                     # Proyecto nativo Android
├── lib/
│   ├── main.dart                # Punto de entrada de la app
│   ├── tema_app.dart            # Paleta de colores y tema Material
│   ├── datos_en_memoria.dart    # Repositorio de datos en memoria (mock)
│   ├── modelos/                 # Entidades del dominio
│   │   ├── modelo_producto.dart
│   │   ├── modelo_pedido.dart
│   │   ├── modelo_productor.dart
│   │   └── modelo_comprador.dart
│   ├── utilidades/
│   │   └── formato_fecha.dart   # Helpers de formato (fechas en español)
│   ├── vistas/                  # Pantallas de la aplicación
│   │   ├── vista_login.dart
│   │   ├── vista_registro.dart
│   │   ├── vista_catalogo.dart
│   │   ├── vista_panel_productor.dart
│   │   ├── vista_publicar.dart
│   │   └── vista_pedido.dart
│   └── widgets/                 # Componentes reutilizables
│       ├── tarjeta_producto.dart
│       └── indicador_modo_rural.dart
├── test/
│   └── widget_test.dart         # Pruebas de widgets
├── pubspec.yaml                 # Dependencias y metadata del proyecto
└── analysis_options.yaml        # Reglas de linting
```

## Requisitos Previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>= 3.13` (incluye Dart `>= 3.13`)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/) con el plugin de Flutter
- Un emulador Android configurado o un dispositivo físico con depuración USB habilitada
- Java/Android SDK instalado (gestionado por Android Studio)

Verifica que tu entorno esté correctamente configurado con:

```bash
flutter doctor
```

## Instalación y Configuración

1. **Clonar el repositorio**

   ```bash
   git clone https://github.com/<usuario>/agro_directo.git
   cd agro_directo
   ```

2. **Instalar dependencias**

   ```bash
   flutter pub get
   ```

3. **Variables de entorno / Configuración**

   El proyecto **no requiere** archivo `.env` ni llaves de API en su estado actual: toda la data (productores, compradores, productos y pedidos) vive en memoria dentro de `lib/datos_en_memoria.dart` y se reinicia en cada ejecución. 

4. **Verificar dispositivos disponibles**

   ```bash
   flutter devices
   ```

## Instrucciones de Ejecución

### Entorno de desarrollo

```bash
flutter run
```

Para ejecutar en un dispositivo específico:

```bash
flutter run -d <device_id>
```

### Compilación / Build

Generar APK de release para Android:

```bash
flutter build apk --release
```

Generar App Bundle (recomendado para publicación en Google Play):

```bash
flutter build appbundle --release
```

## Scripts Principales / Comandos Útiles

| Comando                      | Descripción                                              |
|-------------------------------|------------------------------------------------------------|
| `flutter pub get`             | Instala/actualiza las dependencias del proyecto            |
| `flutter run`                 | Ejecuta la app en modo debug en el dispositivo conectado    |
| `flutter test`                | Ejecuta las pruebas de widgets ubicadas en `test/`          |
| `flutter analyze`             | Analiza el código en busca de errores y problemas de lint  |
| `flutter build apk --release` | Genera el APK de producción                                |
| `flutter clean`               | Limpia archivos de build y caché del proyecto               |



# Decisiones Técnicas y Arquitectónicas - HUAGURUNCHO 360

## 1. Visor 360°: WebView WebGL vs. Plugins Nativos de Flutter
- **Problema**: Muchos paquetes nativos 360 de Flutter (como `panorama` o `flutter_cube`) presentan incompatibilidades con las últimas versiones de Flutter (3.24+ / Dart 3 null-safety) o fallan al renderizar en ciertos chipsets Android al cargar imágenes locales de gran resolución.
- **Decisión**: Implementar un visor 360° embebido de alto rendimiento usando `webview_flutter` y un bundle HTML5/WebGL local autónomo (`assets/web/viewer_360.html`).
- **Beneficios**:
  - 100% offline sin necesidad de CDN o servidores web externos.
  - Compatibilidad total con aceleración por hardware en Android WebKit.
  - Soporte para rotación táctil fluida con inercia, zoom y posicionamiento esférico de hotspots (yaw/pitch).
  - Comunicación bidireccional limpia mediante `JavaScriptChannel` (`FlutterBridge`).

## 2. Persistencia Local y Sincronización Idempotente
- **Problema**: En zonas altoandinas de Huachón y la cordillera de Huaguruncho la conectividad a internet es nula o intermitente. Los turistas deben poder registrar incidentes ecológicos sin fricción y sin duplicar datos cuando la red regrese.
- **Decisión**:
  - Uso de **Drift (SQLite)** para almacenamiento local tipado y seguro.
  - Generación de `local_uuid` (UUIDv4) en el cliente en el momento de captura.
  - Endpoint `POST /api/v1/environmental-reports/sync-batch/` en Django con validación de existencia previa de `local_uuid`. Si un reporte ya existe en base de datos, el servidor retorna el registro existente sin duplicar el incidente.
  - Almacenamiento persistente de fotografías en el directorio privado de la aplicación (`getApplicationDocumentsDirectory`) antes de la sincronización.

## 3. Autenticación Progresiva (Frictionless Onboarding)
- **Problema**: Forzar login antes de permitir ver rutas o explorar el tour 360° genera abandono de usuarios.
- **Decisión**:
  - La exploración de rutas, visor 360°, checklist de seguridad y creación local de reportes son accesibles sin inicio de sesión.
  - La autenticación mediante JWT (`SimpleJWT`) solo se solicita al momento de sincronizar los eco-reportes con los servidores centrales o al acceder a funciones del perfil.

## 4. Paquetes Offline y Gestión de Almacenamiento
- **Problema**: Las fotos 360° en alta resolución pueden consumir decenas de megabytes.
- **Decisión**:
  - Arquitectura basada en "Paquetes Offline" por ruta turística (`OfflinePackage`).
  - El manifiesto (`manifest_json`) lista todas las escenas, hotspots y URLs de descarga.
  - El usuario puede descargar una ruta específica con barra de progreso y eliminarla cuando necesite liberar almacenamiento interno.

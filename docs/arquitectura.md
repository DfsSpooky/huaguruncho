# Arquitectura del Sistema - HUAGURUNCHO 360

## 1. Visión General
**HUAGURUNCHO 360** es una plataforma orientada al turismo sostenible y la gestión ambiental comunitaria en la zona del Nevado Huaguruncho (distrito de Huachón, provincia de Pasco, Perú). El sistema está compuesto por:

1. **Backend API REST**: Desarrollado con Django 5 y Django REST Framework, con persistencia relacional, autenticación JWT, documentación Swagger/OpenAPI y panel de administración Django Admin para guardaparques, guías y municipalidades.
2. **Aplicación Móvil**: Desarrollada en Flutter (Android First), con capacidad de operación 100% offline mediante SQLite (Drift), sincronización de eco-reportes idempotente y visor de panoramas 360° equirectangulares interactivo.

---

## 2. Diagrama de Arquitectura

```
+-------------------------------------------------------------------------+
|                              USUARIO / TURISTA                          |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
|                          FLUTTER MOBILE APP                             |
|                                                                         |
|  [ Presentation Layer ]                                                 |
|    - Home, 360 Tour Viewer, Routes, Safety Checklist, Eco-Reports, Auth |
|                                                                         |
|  [ Business Logic Layer (Riverpod) ]                                   |
|    - AuthController, RoutesController, SyncController, ReportFormCtrl  |
|                                                                         |
|  [ Data / Repository Layer ]                                            |
|    - RoutesRepository, ReportsRepository, SafetyRepository, OfflineRepo |
|                                                                         |
|  [ Local Persistence (Drift / SQLite) ]       [ Network (Dio + JWT) ]   |
|    - local_routes, local_scenes, local_hotspots  - Offline Manifest     |
|    - pending_reports, safety_checklist           - Sync Batch Queue     |
|                                                  - Auth Endpoints       |
+-------------------------------------------------------------------------+
                                    |
                       (HTTP/REST - JSON / Multipart)
                                    |
                                    v
+-------------------------------------------------------------------------+
|                           DJANGO BACKEND API                            |
|                                                                         |
|  [ Security & Middleware ]                                              |
|    - CORS, SimpleJWT (Access/Refresh Tokens), Role-Based Permissions    |
|                                                                         |
|  [ REST API Endpoints (/api/v1/) ]                                      |
|    - /auth/ (Register, Login, Refresh, Profile)                         |
|    - /routes/ & /scenes/ & /safety-recommendations/                     |
|    - /environmental-reports/ (Idempotent Sync-Batch & Evidences)        |
|    - /routes/{uuid}/offline-package/ (Manifest & Assets)                |
|    - /admin/ (Django Admin Dashboard & Administrative APIs)             |
|                                                                         |
|  [ ORM & Persistence ]                                                  |
|    - PostgreSQL (Producción) / SQLite (Desarrollo Local)                |
|    - File Storage / Media (Panoramas, Evidencias fotográficas)          |
+-------------------------------------------------------------------------+
```

---

## 3. Patrones de Diseño Aplicados

### En Flutter:
- **Clean Architecture Pragmática + Feature First**:
  - `lib/core`: Componentes transversales (base de datos, red, tema, servicios comunes).
  - `lib/features/<feature>`: Dividido en `data/` (data sources, repositorios, DTOs), `domain/` (modelos de entidad) y `presentation/` (controladores Riverpod, pantallas y widgets).
- **Offline-First & Repository Pattern**: Las pantallas consultan los repositorios, los cuales priorizan la lectura de la base de datos local SQLite y orquestan la sincronización con la API cuando hay conexión disponible.
- **Idempotencia en Sincronización**: Cada reporte ambiental genera un `local_uuid` (UUIDv4) en el dispositivo. La API rechaza duplicaciones y reutiliza el recurso si ya fue recibido.
- **Visor 360° Híbrido WebGL**: Renderizado equirectangular interactivo mediante un bundle HTML5/WebGL local en WebView, garantizando máxima estabilidad y soporte offline.

### En Django:
- **Modular Django Apps**:
  - `apps.accounts`: Usuarios personalizados, roles (`turista`, `guia`, `administrador`, `municipalidad`).
  - `apps.tourism`: Rutas, escenas 360°, hotspots interactivos y recomendaciones de seguridad.
  - `apps.environmental_reports`: Reportes de incidentes ambientales y evidencias fotográficas.
  - `apps.offline_packages`: Generación de manifiestos y paquetes de descarga offline.
  - `apps.common`: Modelos base (UUID, timestamps), paginación y permisos estándar.
- **Custom Model Managers & QuerySets**: Consultas optimizadas con `select_related` y `prefetch_related` para evitar problemas N+1 en escenas y hotspots.

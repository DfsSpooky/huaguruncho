# HUAGURUNCHO 360
> **“Explora, cuida y recorre el Nevado Huaguruncho”**  
> *Plataforma móvil y backend para turismo sostenible y gestión ambiental participativa en Huachón, Pasco, Perú.*

> 📖 **[Ver Documentación Completa del Sistema (SISTEMA_HUAGURUNCHO_360.md)](file:///Users/miguel/Documents/Proyectos/Aqui%20en%20Huaguruncho/SISTEMA_HUAGURUNCHO_360.md)** — *Guía detallada de qué es, para qué sirve, cómo funciona y manual de cada módulo.*

---

## 🏔️ 1. Descripción del Proyecto

**HUAGURUNCHO 360** es una solución digital completa orientada al turismo de alta montaña responsable en la cordillera del Nevado Huaguruncho (5,742 m s.n.m.). La plataforma permite:

1. **Puesto de Control Guardabosques ("Huella Cero")**: Módulo exclusivo y 100% offline para el registro de ascensos de visitantes y control jurado de retorno de residuos sólidos (botellas, latas, empaques, gas, baterías).
2. **Explorar Rutas y Senderos**: Consulta de distancias, dificultades, tiempos estimados y recomendaciones de seguridad.
3. **Tour Virtual 360° Real e Interactivo**: Navegación equirectangular mediante giros táctiles con el dedo, zoom y hotspots interactivos (cambio de escenas, información ambiental y advertencias de peligro).
4. **Live Trekking GPS y Seguridad**: Grabador satelital de trayectorias, checklists de montaña y botón SOS de emergencia.
5. **Paquetes Offline**: Descarga completa de rutas y panoramas para uso 100% desconectado en la cordillera.
6. **Eco-Reportes Ciudadanos Offline-First**: Formulario con captura satelital GPS, fotografías de evidencia y cola local en SQLite (Drift).
7. **Sincronización Idempotente**: Sincronización automática o manual al recuperar señal de red, garantizando cero duplicados mediante `local_uuid`.
8. **Panel de Administración**: Django Admin para que guías, guardaparques y personal municipal de Huachón gestionen rutas, escenas 360 y atiendan reportes ambientales.

---

## 🏛️ 2. Arquitectura del Monorepo

```
Aqui en Huaguruncho/
├── README.md
├── .gitignore
├── docs/
│   ├── arquitectura.md              # Diseño arquitectónico y capas
│   ├── api.md                       # Especificación de endpoints REST
│   ├── instalacion.md               # Guía paso a paso multiplataforma
│   ├── decisiones-tecnicas.md       # Decisiones técnicas y justificaciones
│   └── captura-de-panoramas.md      # Guía para fotógrafos y guías 360
├── rust/
│   ├── Cargo.toml                   # Workspace Rust (huaguruncho_core + huaguruncho_server)
│   ├── Dockerfile                   # Contenedor ligero para el microservicio Axum
│   ├── huaguruncho_core/            # Motor nativo (GPX, RDP iterativo, EXIF, ZIP+BLAKE3, Sello Huella Cero)
│   └── huaguruncho_server/          # Microservicio HTTP Axum + Tokio (puerto 8081)
├── backend/
│   ├── manage.py
│   ├── requirements.txt
│   ├── config/                      # Settings modulares, URLs y Swagger
│   ├── apps/
│   │   ├── common/                  # Modelos base, permisos, paginación y rust_bridge.py (FFI)
│   │   ├── accounts/                # Custom User y autenticación JWT
│   │   ├── tourism/                 # Rutas, escenas 360, hotspots y seguridad (acelerado con Rust)
│   │   ├── environmental_reports/   # Eco-reportes y sincronización batch con firma ECO360
│   │   └── offline_packages/        # Manifiestos y empaquetador ZIP nativo en Rust
│   └── tests/                       # Suite de tests unitarios, de integración y motor Rust
└── mobile/
    ├── pubspec.yaml
    ├── third_party/huaguruncho_core/# Cabecera C ABI para generación automática de bindings FFI
    ├── tool/ffigen.dart             # Generador automático de bindings (package:ffigen)
    ├── assets/
    │   ├── images/                  # Portadas y logos
    │   ├── panoramas/               # Panoramas equirectangulares de prueba
    │   ├── web/                     # Motor WebGL 360 local autónomo
    │   └── mock_data/               # Manifiesto demo 100% offline
    ├── lib/
    │   ├── app/                     # GoRouter y configuración de app
    │   ├── core/                    # Drift SQLite, Dio, RustCoreService (FFI), GPS, Cámara, Sync
    │   ├── src/third_party/         # Bindings FFI autogenerados (huaguruncho_core.g.dart)
    │   └── features/                # Auth, Home, Routes, Tours 360, Offline, Safety, Reports, Checkpoint
    └── test/                        # Tests unitarios de modelos, sincronización y FFI Rust
```

---

## 🚀 3. Guía de Instalación y Ejecución Rápida

### 3.1 Backend (Django + Django REST Framework)

1. **Ingresar a la carpeta del backend y crear entorno virtual:**
   ```bash
   cd backend
   python3 -m venv .venv
   source .venv/bin/activate   # En Windows: .venv\Scripts\Activate.ps1
   ```

2. **Instalar dependencias:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Ejecutar migraciones y cargar datos semilla (Seed Data):**
   ```bash
   python manage.py migrate
   python manage.py seed_huaguruncho
   ```

4. **Iniciar el servidor Django:**
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

**Accesos y Credenciales por Defecto:**
- **Swagger UI Interactivo**: [http://localhost:8000/api/docs/](http://localhost:8000/api/docs/)
- **Django Admin**: [http://localhost:8000/admin/](http://localhost:8000/admin/)
- **Superusuario**: `admin@huaguruncho.pe` / `Huaguruncho2026!`
- **Guía de Montaña**: `guia@huaguruncho.pe` / `Huaguruncho2026!`
- **Personal Municipal**: `municipalidad@huachon.gob.pe` / `Huaguruncho2026!`

---

### 3.2 Aplicación Móvil (Flutter)

1. **Ingresar a la carpeta móvil y obtener paquetes:**
   ```bash
   cd mobile
   flutter pub get
   ```

2. **Configuración de Red (Opcional):**
   - En `mobile/lib/core/constants/api_endpoints.dart`, el valor por defecto es `http://10.0.2.2:8000/api/v1` para emulador Android.
   - En dispositivo físico, ingresa la IP de tu PC o edítala en runtime desde la pantalla **Mi Perfil > Configuración de Servidor**.
   - **Modo Demo Local**: La app incluye modo demo y assets locales embebidos, por lo que puedes explorar el tour 360° y guardar reportes incluso sin encender el servidor.

3. **Compilar y Ejecutar en Android:**
   ```bash
   flutter run
   ```

---

## 🧪 4. Ejecución de Pruebas Automatizadas

**Pruebas del Backend (14 tests):**
```bash
cd backend
python manage.py test
```

**Pruebas de la App Móvil:**
```bash
cd mobile
flutter test
```

---

## 📸 5. Cómo Reemplazar Panoramas de Ejemplo por Fotos 360 Reales

1. **Captura o renderiza imágenes equirectangulares** en proporción exacta `2:1` (ejemplo: `4096 x 2048` o `6000 x 3000` en formato JPG).
2. **Opción Local (Sin Servidor)**: Reemplaza los archivos en `mobile/assets/panoramas/`:
   - `scene_huachon_plaza.jpg`
   - `scene_laguna_huaguruncho.jpg`
   - `scene_mirador_glaciar.jpg`
3. **Opción Backend (En Producción)**:
   - Ingresa al Django Admin en `http://localhost:8000/admin/`.
   - Dirígete a **Tourism > Escenas 360°**.
   - Sube la nueva fotografía en el campo `panorama_image` y ajusta los hotspots (yaw/pitch).
   - En **Offline Packages**, pulsa **Regenerar Manifiesto** para que la app móvil descargue la nueva versión en un toque.

---

## 📋 6. Estado del MVP y Funcionalidades para Fase 2

### ✅ Funcionalidades Entregadas en este MVP:
- [x] Arquitectura limpia monorepo desacoplada.
- [x] Modelos Django con Custom User, Roles, Rutas, Escenas, Hotspots, Seguridad y Eco-Reportes.
- [x] Autenticación JWT completa con refresh token rotativo.
- [x] Documentación Swagger/OpenAPI 3.0 interactiva.
- [x] Persistencia local tipada con Drift SQLite.
- [x] Visor 360° interactivo con giros táctiles, inercia, zoom y hotspots bidireccionales vía WebView WebGL.
- [x] Sistema de descarga de paquetes offline con barra de progreso granular.
- [x] Formulario de Eco-reportes con geolocalización satelital GPS, selector de cámara/galería y cola offline.
- [x] Sincronización idempotente batch con detección reactiva de red y botón manual "Sincronizar ahora".
- [x] Checklist de seguridad interactivo y persistente.
- [x] Panel administrativo Django Admin con filtros, inlines y acciones de cambio de estado.

### 🔮 Roadmap para Fase 2:
- Integración de mapas vectoriales interactivos con Mapbox / OpenStreetMap offline.
- Notificaciones push mediante Firebase Cloud Messaging para alertas meteorológicas.
- Grabación de rutas GPS en vivo (tracking de caminata).
- Soporte para audio-guías en quechua y español en cada punto 360°.

---

*Desarrollado para la conservación del Nevado Huaguruncho y el desarrollo turístico de la comunidad de Huachón, Pasco, Perú.*

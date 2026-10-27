# Especificación de la API REST - HUAGURUNCHO 360

Prefijo Base: `/api/v1/`
Formato de Intercambio: `application/json` (o `multipart/form-data` para archivos)
Documentación Interactiva:
- Swagger UI: `http://localhost:8000/api/docs/`
- ReDoc: `http://localhost:8000/api/redoc/`
- OpenAPI Schema: `http://localhost:8000/api/schema/`

---

## 1. Autenticación (`/api/v1/auth/`)

### 1.1 Registro de Usuario
- **Método / URL**: `POST /api/v1/auth/register/`
- **Request Body**:
  ```json
  {
    "email": "turista@ejemplo.com",
    "password": "PasswordSegura123!",
    "full_name": "Juan Pérez",
    "phone": "+51987654321"
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "user": {
      "id": 1,
      "email": "turista@ejemplo.com",
      "full_name": "Juan Pérez",
      "role": "turista",
      "created_at": "2026-08-21T18:00:00Z"
    },
    "tokens": {
      "access": "eyJhbGciOi...",
      "refresh": "eyJhbGciOi..."
    }
  }
  ```

### 1.2 Inicio de Sesión
- **Método / URL**: `POST /api/v1/auth/login/`
- **Request Body**:
  ```json
  {
    "email": "turista@ejemplo.com",
    "password": "PasswordSegura123!"
  }
  ```
- **Response (200 OK)**: Tokens `access` y `refresh` junto a datos del usuario.

### 1.3 Refrescar Token
- **Método / URL**: `POST /api/v1/auth/refresh/`
- **Request Body**: `{"refresh": "..."}`
- **Response (200 OK)**: `{"access": "..."}`

---

## 2. Rutas y Escenas Turísticas (`/api/v1/routes/`)

### 2.1 Listar Rutas
- **Método / URL**: `GET /api/v1/routes/`
- **Response (200 OK)**:
  ```json
  {
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
      {
        "id": 1,
        "uuid": "43e26462-8356-4c4f-9e66-6b2c28aa1d58",
        "name": "Ruta piloto Huachón – Mirador Huaguruncho",
        "slug": "huachon-mirador-huaguruncho",
        "description": "Ruta emblemática hacia el imponente nevado Huaguruncho...",
        "difficulty": "moderada",
        "distance_km": 14.5,
        "estimated_duration_minutes": 360,
        "safety_recommendations": "Llevar ropa térmica, bloqueador solar y bastones de trekking.",
        "cover_image_url": "http://localhost:8000/media/routes/cover_huaguruncho.jpg",
        "scenes_count": 3
      }
    ]
  }
  ```

### 2.2 Detalle de Ruta con Escenas
- **Método / URL**: `GET /api/v1/routes/{uuid}/`

### 2.3 Escenas de una Ruta
- **Método / URL**: `GET /api/v1/routes/{uuid}/scenes/`

### 2.4 Paquete Offline de una Ruta
- **Método / URL**: `GET /api/v1/routes/{uuid}/offline-package/`
- **Response (200 OK)**:
  ```json
  {
    "package_uuid": "7a3562a0-41ff-48ba-bb8f-801c87dbfa33",
    "route_uuid": "43e26462-8356-4c4f-9e66-6b2c28aa1d58",
    "version": 1,
    "size_bytes": 12582912,
    "manifest": {
      "route": { ... },
      "scenes": [
        {
          "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "title": "Plaza Principal de Huachón",
          "panorama_url": "http://localhost:8000/media/panoramas/scene1.jpg",
          "hotspots": [ ... ]
        }
      ]
    }
  }
  ```

---

## 3. Escenas y Hotspots 360° (`/api/v1/scenes/`)

### 3.1 Detalle de Escena con Hotspots
- **Método / URL**: `GET /api/v1/scenes/{uuid}/`
- **Response (200 OK)**:
  ```json
  {
    "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "title": "Plaza Principal de Huachón",
    "description": "Punto de partida del circuito hacia el nevado.",
    "panorama_image_url": "http://localhost:8000/media/panoramas/scene1.jpg",
    "latitude": -10.601234,
    "longitude": -75.952345,
    "sequence": 1,
    "hotspots": [
      {
        "uuid": "550e8400-e29b-41d4-a716-446655440000",
        "type": "navigation",
        "yaw": 45.0,
        "pitch": -5.0,
        "title": "Avanzar a Laguna Huaguruncho",
        "content": "Camino hacia el campamento base.",
        "target_scene_uuid": "8b84332e-b6a1-432d-88f1-f09c1fa416b9",
        "icon": "arrow_forward"
      }
    ]
  }
  ```

---

## 4. Recomendaciones de Seguridad (`/api/v1/safety-recommendations/`)

- **Método / URL**: `GET /api/v1/safety-recommendations/`
- **Response (200 OK)**: Lista categorizada (`equipamiento`, `salud`, `hidratacion`, `seguridad`, `ambiente`, `bateria`).

---

## 5. Eco-Reportes Ambientales (`/api/v1/environmental-reports/`)

### 5.1 Crear Reporte Individual
- **Método / URL**: `POST /api/v1/environmental-reports/`
- **Permisos**: Autenticado o anónimo con `local_uuid`.

### 5.2 Sincronización en Lote (Sync-Batch)
- **Método / URL**: `POST /api/v1/environmental-reports/sync-batch/`
- **Headers**: `Authorization: Bearer <access_token>`
- **Request Body**:
  ```json
  {
    "reports": [
      {
        "local_uuid": "e93ab637-290a-4a6c-9a4f-561bcfad5b0c",
        "category": "basura",
        "description": "Acumulación de botellas plásticas en la orilla de la laguna.",
        "latitude": -10.605412,
        "longitude": -75.962134,
        "accuracy_meters": 4.5,
        "captured_at": "2026-08-21T15:20:00Z"
      }
    ]
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "results": [
      {
        "local_uuid": "e93ab637-290a-4a6c-9a4f-561bcfad5b0c",
        "success": true,
        "server_uuid": "36d23ea5-76ea-45a4-ba09-5a1e8a4a51e2",
        "status": "recibido",
        "message": "Reporte sincronizado correctamente"
      }
    ]
  }
  ```

### 5.3 Adjuntar Evidencia Fotográfica
- **Método / URL**: `POST /api/v1/environmental-reports/{uuid}/evidences/`
- **Body**: `multipart/form-data` con campo `image`.

### 5.4 Listar Mis Reportes
- **Método / URL**: `GET /api/v1/environmental-reports/me/`

---

## 6. Endpoints Administrativos (`/api/v1/admin/`)

- **Listar Reportes**: `GET /api/v1/admin/environmental-reports/?category=basura&status=recibido`
- **Actualizar Estado**: `PATCH /api/v1/admin/environmental-reports/{uuid}/status/`
  ```json
  {
    "status": "en_revision",
    "admin_notes": "Equipo de limpieza municipal notificado."
  }
  ```

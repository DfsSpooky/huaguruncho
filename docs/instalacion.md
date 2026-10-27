# Guía de Instalación y Ejecución - HUAGURUNCHO 360

Esta guía explica paso a paso cómo configurar y ejecutar tanto el **Backend Django** como la **App Móvil Flutter** en entornos Windows, Linux y macOS.

---

## 1. Requisitos Previos

- **Python**: 3.12 o superior.
- **Node.js**: LTS (opcional, para herramientas de assets).
- **Flutter SDK**: 3.24+ (con soporte para Android SDK 34/35).
- **Git**
- **Android Studio / Android SDK**: Para compilar o ejecutar en emulador/dispositivo Android.

---

## 2. Configuración y Ejecución del Backend (Django)

### Paso 2.1: Crear y activar entorno virtual Python

**En macOS / Linux:**
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
```

**En Windows (PowerShell):**
```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### Paso 2.2: Instalar dependencias
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Paso 2.3: Configurar variables de entorno
Crea tu archivo `.env` a partir del archivo `.env.example`:
```bash
cp .env.example .env
```
*(En Windows puedes usar `copy .env.example .env`)*

### Paso 2.4: Ejecutar migraciones
```bash
python manage.py migrate
```

### Paso 2.5: Cargar datos iniciales (Seed Data)
Este comando creará el superusuario administrador, las rutas piloto del Nevado Huaguruncho, escenas 360°, hotspots interactivos y recomendaciones de seguridad:
```bash
python manage.py seed_huaguruncho
```
**Credenciales creadas por defecto:**
- **Superusuario**: `admin@huaguruncho.pe`
- **Contraseña**: `Huaguruncho2026!`
- **Guía Turístico**: `guia@huaguruncho.pe` / `Huaguruncho2026!`

### Paso 2.6: Iniciar el servidor de desarrollo
```bash
python manage.py runserver 0.0.0.0:8000
```
- API REST: `http://localhost:8000/api/v1/`
- Swagger UI interactivo: `http://localhost:8000/api/docs/`
- Django Admin: `http://localhost:8000/admin/`

---

## 3. Configuración y Ejecución de la App Móvil (Flutter)

### Paso 3.1: Configurar URL base en Flutter
Abre `mobile/lib/core/constants/api_endpoints.dart`:
- Para **Emulador Android**: usa `http://10.0.2.2:8000` (mapea al localhost de tu PC).
- Para **Dispositivo Físico Android**: usa la IP local de tu PC en la red WiFi (ej. `http://192.168.1.50:8000`).
- Para **Modo 100% Offline/Demo**: La aplicación incluye un interruptor "Modo Demo Local" que permite navegar las escenas 360° y guardar reportes sin necesidad de levantar el backend.

### Paso 3.2: Obtener dependencias de Flutter
```bash
cd mobile
flutter pub get
```

### Paso 3.3: Ejecutar la aplicación en Android
```bash
flutter run
```

---

## 4. Ejecución de Pruebas Automatizadas

**Backend:**
```bash
cd backend
python manage.py test
```

**Flutter:**
```bash
cd mobile
flutter test
```

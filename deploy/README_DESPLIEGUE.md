# Guía de Despliegue en Producción - HUAGURUNCHO 360
**Dominio Oficial del Backend:** `apih.aquienpasco.com`

---

## 1. Configuración de DNS

En tu proveedor de dominio (Cloudflare, Namecheap, GoDaddy, etc.) crea un registro DNS de tipo **A**:

| Tipo | Nombre | Valor / Destino | TTL |
| :--- | :--- | :--- | :--- |
| **A** | `apih` | `IP_PUBLICA_DE_TU_SERVIDOR` | Automático / 300 |

*Si usas Cloudflare, puedes colocar el proxy en modo "DNS Only" (nube gris) inicialmente para la emisión del certificado SSL con Let's Encrypt, y luego activarlo si deseas protección DDoS.*

---

## 2. Preparación del Entorno (`.env`)

Copia el archivo de plantilla a `.env` dentro de la carpeta `backend/`:

```bash
cd backend
cp .env.example .env
```

Genera una clave secreta segura de producción (ejecutar en terminal):
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(50))"
```

Edita `backend/.env` con tus credenciales:
```ini
DEBUG=False
SECRET_KEY=pega_aqui_la_clave_secreta_generada_arriba
ALLOWED_HOSTS=apih.aquienpasco.com,.aquienpasco.com,localhost,127.0.0.1,backend
CSRF_TRUSTED_ORIGINS=https://apih.aquienpasco.com,https://aquienpasco.com,https://*.aquienpasco.com
CORS_ALLOWED_ORIGINS=https://apih.aquienpasco.com,https://aquienpasco.com,https://www.aquienpasco.com

# Base de datos PostgreSQL
DB_NAME=huaguruncho_db
DB_USER=huaguruncho_user
DB_PASSWORD=tu_contraseña_ultra_segura_2026
DB_HOST=db
DB_PORT=5432
DATABASE_URL=postgres://huaguruncho_user:tu_contraseña_ultra_segura_2026@db:5432/huaguruncho_db

# Seguridad HTTPS
SECURE_SSL_REDIRECT=True
SECURE_HSTS_SECONDS=31536000
SERVE_MEDIA=True
```

---

## 3. Despliegue con Docker Compose (Recomendado)

### Paso 3.1: Emisión inicial del Certificado SSL (Let's Encrypt)
Antes de levantar Nginx con SSL por primera vez, emite el certificado para `apih.aquienpasco.com`:

```bash
# Certbot standalone (asegúrate de que el puerto 80 no esté ocupado)
sudo certbot certonly --standalone -d apih.aquienpasco.com -m tu-correo@aquienpasco.com --agree-tos --no-eff-email
```

### Paso 3.2: Levantar el stack completo
Desde la raíz del proyecto:

```bash
docker compose -f deploy/docker-compose.prod.yml up -d --build
```

El script `entrypoint.sh` se ejecutará automáticamente en el contenedor:
1. Esperará a que PostgreSQL esté listo.
2. Aplicará todas las migraciones (`python manage.py migrate`).
3. Recopilará y optimizará los archivos estáticos (`collectstatic` con WhiteNoise).
4. Iniciará Gunicorn con 3 workers WSGI.

### Paso 3.3: Sembrar datos iniciales del Nevado Huaguruncho
```bash
docker compose -f deploy/docker-compose.prod.yml exec backend python manage.py seed_huaguruncho
```

### Paso 3.4: Crear cuenta de Administrador
```bash
docker compose -f deploy/docker-compose.prod.yml exec backend python manage.py createsuperuser
```

---

## 4. Despliegue Nativo en Servidor Ubuntu / Debian (Sin Docker)

Si prefieres usar un servidor VPS tradicional con Systemd y Nginx:

### Paso 4.1: Instalar dependencias del sistema
```bash
sudo apt update && sudo apt install -y python3.12 python3.12-venv python3-pip postgresql postgresql-contrib nginx certbot python3-certbot-nginx curl libpq-dev build-essential
```

### Paso 4.2: Configurar PostgreSQL
```bash
sudo -u postgres psql -c "CREATE DATABASE huaguruncho_db;"
sudo -u postgres psql -c "CREATE USER huaguruncho_user WITH PASSWORD 'tu_contraseña_ultra_segura_2026';"
sudo -u postgres psql -c "ALTER ROLE huaguruncho_user SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE huaguruncho_user SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE huaguruncho_user SET timezone TO 'America/Lima';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE huaguruncho_db TO huaguruncho_user;"
```

### Paso 4.3: Configurar entorno virtual y dependencias
```bash
cd /var/www/huaguruncho/backend
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements/production.txt
python manage.py migrate --settings=config.settings.production
python manage.py collectstatic --noinput --settings=config.settings.production
python manage.py seed_huaguruncho --settings=config.settings.production
python manage.py createsuperuser --settings=config.settings.production
```

### Paso 4.4: Crear servicio Systemd (`/etc/systemd/system/huaguruncho.service`)
```ini
[Unit]
Description=Gunicorn daemon para HUAGURUNCHO 360 (apih.aquienpasco.com)
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/huaguruncho/backend
Environment="PATH=/var/www/huaguruncho/backend/.venv/bin"
Environment="DJANGO_SETTINGS_MODULE=config.settings.production"
ExecStart=/var/www/huaguruncho/backend/.venv/bin/gunicorn config.wsgi:application --workers 3 --bind 127.0.0.1:8000 --timeout 120

[Install]
WantedBy=multi-user.target
```

Habilitar y arrancar servicio:
```bash
sudo systemctl daemon-reload
sudo systemctl enable huaguruncho
sudo systemctl start huaguruncho
```

### Paso 4.5: Configurar Nginx y Certificado SSL
Copia `deploy/nginx/apih.aquienpasco.com.conf` a `/etc/nginx/sites-available/apih.aquienpasco.com`:
```bash
sudo cp deploy/nginx/apih.aquienpasco.com.conf /etc/nginx/sites-available/apih.aquienpasco.com
sudo ln -s /etc/nginx/sites-available/apih.aquienpasco.com /etc/nginx/sites-enabled/
sudo certbot --nginx -d apih.aquienpasco.com
sudo systemctl reload nginx
```

---

## 5. Verificación de Funcionamiento

Prueba los siguientes endpoints desde cualquier terminal o navegador:

1. **Health Check:**
   ```bash
   curl -I https://apih.aquienpasco.com/health/
   # Retorna: HTTP/2 200 OK
   # Body: {"status": "ok", "database": "operational", "domain": "apih.aquienpasco.com", ...}
   ```

2. **Panel de Administración:**
   `https://apih.aquienpasco.com/admin/`

3. **Documentación Interactiva Swagger / OpenAPI:**
   `https://apih.aquienpasco.com/api/docs/`

4. **Documentación ReDoc:**
   `https://apih.aquienpasco.com/api/redoc/`

5. **API v1 Base:**
   `https://apih.aquienpasco.com/api/v1/routes/`

---

## 6. Conexión desde la App Móvil (Flutter)

La app móvil ya viene configurada por defecto con `https://apih.aquienpasco.com/api/v1`.

Para compilar el APK de producción:
```bash
cd mobile
flutter build apk --release
```

Para compilar apuntando a un servidor de pruebas o local (opcional):
```bash
flutter build apk --release --dart-define=API_URL=http://tu-ip:8000/api/v1
```

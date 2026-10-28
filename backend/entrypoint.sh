#!/bin/sh
set -e

echo "=================================================="
echo "    HUAGURUNCHO 360 - BACKEND PRODUCCIÓN"
echo "    Dominio oficial: apih.aquienpasco.com"
echo "=================================================="

# Esperar a PostgreSQL si está configurado en un host remoto/contenedor
if [ -n "$DB_HOST" ] && [ "$DB_HOST" != "localhost" ] && [ "$DB_HOST" != "127.0.0.1" ]; then
    echo "Verificando disponibilidad de base de datos en $DB_HOST:${DB_PORT:-5432}..."
    python - <<END
import socket
import time
import os
import sys

host = os.environ.get('DB_HOST')
port = int(os.environ.get('DB_PORT', 5432))
timeout = 45
start = time.time()

while True:
    try:
        with socket.create_connection((host, port), timeout=2):
            print("✔ Conexión a PostgreSQL establecida con éxito.")
            sys.exit(0)
    except (socket.error, socket.timeout):
        if time.time() - start > timeout:
            print(f"⚠ Aviso: Espera de base de datos excedió {timeout}s. Continuando inicio...")
            sys.exit(0)
        time.sleep(1)
END
fi

# Preparar y asegurar volumen persistente de archivos media (/app/media)
echo "Asegurando estructura y permisos en volumen persistente de media..."
mkdir -p /app/media/panoramas /app/media/panoramas/thumbnails /app/media/routes/covers /app/media/reports/evidences /app/media/offline_packages
chmod -R 755 /app/media 2>/dev/null || true

# Copiar imágenes base al volumen si aún no existen (sin sobreescribir subidas de usuario)
if [ -d "/app/static/images" ]; then
    cp -n /app/static/images/scene_huachon_plaza.jpg /app/media/panoramas/ 2>/dev/null || true
    cp -n /app/static/images/scene_laguna_huaguruncho.jpg /app/media/panoramas/scene_laguna_huascacocha.jpg 2>/dev/null || true
    cp -n /app/static/images/scene_mirador_glaciar.jpg /app/media/panoramas/ 2>/dev/null || true
fi

# Aplicar migraciones
echo "Aplicando migraciones de base de datos..."
python manage.py migrate --noinput

# Recopilar archivos estáticos
echo "Recopilando archivos estáticos para WhiteNoise..."
python manage.py collectstatic --noinput

# Sembrado automático de datos base (rutas, 360, POIs, superusuario admin@huaguruncho.pe)
if [ "$AUTO_SEED" = "True" ] || [ "$AUTO_SEED" = "true" ] || [ "$AUTO_SEED" = "1" ]; then
    echo "Verificando y cargando datos base de Huaguruncho (seed_huaguruncho)..."
    python manage.py seed_huaguruncho || true
fi

echo "Iniciando servicio con Gunicorn..."
exec "$@"

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=config.settings.production

WORKDIR /app

# Dependencias mínimas del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias de Python (incluye Gunicorn, WhiteNoise y Psycopg para PostgreSQL)
COPY requirements.txt requirements.txt
COPY requirements/ requirements/
RUN pip install --no-cache-dir -r requirements/production.txt

# Copiar código del proyecto
COPY . .

# Permisos ejecutables para el entrypoint
RUN chmod +x /app/entrypoint.sh

EXPOSE 8000

# Entrypoint con migraciones y estáticos automáticos
ENTRYPOINT ["/app/entrypoint.sh"]

# Servidor de aplicaciones WSGI listo para producción
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3", "--timeout", "120"]


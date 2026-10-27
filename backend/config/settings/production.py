"""
Configuración de producción para HUAGURUNCHO 360.
Dominio de producción: apih.aquienpasco.com
"""
import urllib.parse
from pathlib import Path
from decouple import config, Csv
from .base import *

DEBUG = False

# Hosts permitidos
ALLOWED_HOSTS = config(
    'ALLOWED_HOSTS',
    default='apih.aquienpasco.com,.aquienpasco.com,localhost,127.0.0.1,backend,0.0.0.0',
    cast=Csv()
)

# Orígenes confiables para protección CSRF en Django 5 (imprescindible en HTTPS)
CSRF_TRUSTED_ORIGINS = config(
    'CSRF_TRUSTED_ORIGINS',
    default='https://apih.aquienpasco.com,https://aquienpasco.com,https://*.aquienpasco.com,http://localhost:8000,http://127.0.0.1:8000',
    cast=Csv()
)

# Configuración CORS
CORS_ALLOW_ALL_ORIGINS = config('CORS_ALLOW_ALL_ORIGINS', default=False, cast=bool)
CORS_ALLOWED_ORIGINS = config(
    'CORS_ALLOWED_ORIGINS',
    default='https://apih.aquienpasco.com,https://aquienpasco.com,https://www.aquienpasco.com,http://localhost:3000,http://127.0.0.1:3000,http://localhost:8080',
    cast=Csv()
)
CORS_ALLOWED_ORIGIN_REGEXES = [
    r"^https:\/\/.*\.aquienpasco\.com$",
]
CORS_ALLOW_CREDENTIALS = True

# Base de datos: soporta DATABASE_URL (postgres:// o sqlite://) o parámetros individuales
database_url = config('DATABASE_URL', default=None)
if database_url:
    parsed_url = urllib.parse.urlparse(database_url)
    if parsed_url.scheme in ('postgres', 'postgresql'):
        DATABASES = {
            'default': {
                'ENGINE': 'django.db.backends.postgresql',
                'NAME': parsed_url.path.lstrip('/'),
                'USER': parsed_url.username or '',
                'PASSWORD': parsed_url.password or '',
                'HOST': parsed_url.hostname or 'localhost',
                'PORT': str(parsed_url.port or '5432'),
                'CONN_MAX_AGE': config('DB_CONN_MAX_AGE', default=60, cast=int),
            }
        }
    elif parsed_url.scheme == 'sqlite':
        db_path = parsed_url.path
        if db_path.startswith('///'):
            sqlite_file = Path(db_path[3:])
        elif db_path.startswith('/'):
            sqlite_file = BASE_DIR / db_path.lstrip('/')
        else:
            sqlite_file = BASE_DIR / 'db.sqlite3'
        DATABASES = {
            'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': sqlite_file,
            }
        }
    else:
        DATABASES = {
            'default': {
                'ENGINE': 'django.db.backends.postgresql',
                'NAME': config('DB_NAME', default='huaguruncho_db'),
                'USER': config('DB_USER', default='huaguruncho_user'),
                'PASSWORD': config('DB_PASSWORD', default=''),
                'HOST': config('DB_HOST', default='localhost'),
                'PORT': config('DB_PORT', default='5432'),
                'CONN_MAX_AGE': config('DB_CONN_MAX_AGE', default=60, cast=int),
            }
        }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': config('DB_NAME', default='huaguruncho_db'),
            'USER': config('DB_USER', default='huaguruncho_user'),
            'PASSWORD': config('DB_PASSWORD', default=''),
            'HOST': config('DB_HOST', default='localhost'),
            'PORT': config('DB_PORT', default='5432'),
            'CONN_MAX_AGE': config('DB_CONN_MAX_AGE', default=60, cast=int),
        }
    }

# Proxy reverso y cabeceras SSL (Nginx / Cloudflare / Traefik / ALB)
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
USE_X_FORWARDED_HOST = True
USE_X_FORWARDED_PORT = True

# Seguridad de Conexión y Cabeceras HTTP
SECURE_SSL_REDIRECT = config('SECURE_SSL_REDIRECT', default=True, cast=bool)
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'
SECURE_CONTENT_TYPE_NOSNIFF = True

# HTTP Strict Transport Security (HSTS - 1 año)
SECURE_HSTS_SECONDS = config('SECURE_HSTS_SECONDS', default=31536000, cast=int)
SECURE_HSTS_INCLUDE_SUBDOMAINS = config('SECURE_HSTS_INCLUDE_SUBDOMAINS', default=True, cast=bool)
SECURE_HSTS_PRELOAD = config('SECURE_HSTS_PRELOAD', default=True, cast=bool)

# Seguridad de Cookies de Sesión y CSRF
SESSION_COOKIE_SECURE = config('SESSION_COOKIE_SECURE', default=True, cast=bool)
CSRF_COOKIE_SECURE = config('CSRF_COOKIE_SECURE', default=True, cast=bool)
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = False
SESSION_COOKIE_SAMESITE = 'Lax'
CSRF_COOKIE_SAMESITE = 'Lax'

# WhiteNoise para servir archivos estáticos optimizados
MIDDLEWARE.insert(1, 'whitenoise.middleware.WhiteNoiseMiddleware')
STORAGES = {
    "default": {
        "BACKEND": "django.core.files.storage.FileSystemStorage",
    },
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}

# Servir archivos media en producción de forma local si no se usa S3
SERVE_MEDIA_FILES = config('SERVE_MEDIA', default=True, cast=bool)

# Configuración opcional para almacenamiento S3 (AWS / MinIO / DigitalOcean Spaces)
if config('USE_S3', default=False, cast=bool):
    AWS_ACCESS_KEY_ID = config('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = config('AWS_SECRET_ACCESS_KEY')
    AWS_STORAGE_BUCKET_NAME = config('AWS_STORAGE_BUCKET_NAME')
    AWS_S3_REGION_NAME = config('AWS_S3_REGION_NAME', default='us-east-1')
    AWS_S3_CUSTOM_DOMAIN = f'{AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com'
    STORAGES["default"] = {
        "BACKEND": "storages.backends.s3boto3.S3Boto3Storage",
    }
    MEDIA_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/media/'

# Registro de logs para Docker y Cloud (stdout/stderr)
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '[{asctime}] {levelname} [{name}:{lineno}] {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': config('DJANGO_LOG_LEVEL', default='INFO'),
    },
    'loggers': {
        'django.request': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },
        'django.security': {
            'handlers': ['console'],
            'level': 'WARNING',
            'propagate': False,
        },
    },
}

# Proteger documentación OpenAPI / Swagger en producción (solo accesible para administradores)
SPECTACULAR_SETTINGS = {
    **SPECTACULAR_SETTINGS,
    'SERVE_PERMISSIONS': ['rest_framework.permissions.IsAdminUser'],
}

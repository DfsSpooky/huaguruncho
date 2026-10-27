"""
Base settings for HUAGURUNCHO 360 project.
"""
from datetime import timedelta
from pathlib import Path
from decouple import config, Csv

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent.parent

SECRET_KEY = config('SECRET_KEY', default='django-insecure-huaguruncho-360-dev-secret-key-2026!')
DEBUG = config('DEBUG', default=True, cast=bool)

ALLOWED_HOSTS = config(
    'ALLOWED_HOSTS',
    default='localhost,127.0.0.1,10.0.2.2,0.0.0.0,apih.aquienpasco.com,.aquienpasco.com',
    cast=Csv()
)

# CSRF Trusted Origins (Huaguruncho 360 production domain)
CSRF_TRUSTED_ORIGINS = config(
    'CSRF_TRUSTED_ORIGINS',
    default='https://apih.aquienpasco.com,https://aquienpasco.com,https://*.aquienpasco.com,http://localhost:8000,http://127.0.0.1:8000',
    cast=Csv()
)

# Límites de carga de archivos (panoramas 360 alta resolución, paquetes offline, audios, APK)
DATA_UPLOAD_MAX_MEMORY_SIZE = config('DATA_UPLOAD_MAX_MEMORY_SIZE', default=52428800, cast=int)  # 50MB
FILE_UPLOAD_MAX_MEMORY_SIZE = config('FILE_UPLOAD_MAX_MEMORY_SIZE', default=52428800, cast=int)  # 50MB


# Application definition
DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

THIRD_PARTY_APPS = [
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'drf_spectacular',
    'django_filters',
]

LOCAL_APPS = [
    'apps.common',
    'apps.accounts',
    'apps.tourism',
    'apps.environmental_reports',
    'apps.offline_packages',
    'apps.landing',
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'apps.common.context_processors.admin_dashboard_stats',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'
ASGI_APPLICATION = 'config.asgi.application'

# Custom User Model
AUTH_USER_MODEL = 'accounts.User'

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        'OPTIONS': {'min_length': 8},
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization (Perú)
LANGUAGE_CODE = 'es-pe'
TIME_ZONE = 'America/Lima'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = config('STATIC_URL', default='/static/')
STATIC_ROOT = BASE_DIR / config('STATIC_ROOT', default='staticfiles')
STATICFILES_DIRS = [BASE_DIR / 'static']

# Media files
MEDIA_URL = config('MEDIA_URL', default='/media/')
MEDIA_ROOT = BASE_DIR / config('MEDIA_ROOT', default='media')

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticatedOrReadOnly',
    ),
    'DEFAULT_THROTTLE_CLASSES': (
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ),
    'DEFAULT_THROTTLE_RATES': {
        'anon': config('THROTTLE_RATE_ANON', default='120/minute'),
        'user': config('THROTTLE_RATE_USER', default='600/minute'),
    },
    'DEFAULT_PAGINATION_CLASS': 'apps.common.pagination.StandardResultsSetPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ),
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    'COERCE_DECIMAL_TO_STRING': False,
}

# Simple JWT Configuration
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(
        minutes=config('JWT_ACCESS_TOKEN_LIFETIME_MINUTES', default=60, cast=int)
    ),
    'REFRESH_TOKEN_LIFETIME': timedelta(
        days=config('JWT_REFRESH_TOKEN_LIFETIME_DAYS', default=7, cast=int)
    ),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': False,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}

# OpenAPI / Swagger Documentation
SPECTACULAR_SETTINGS = {
    'TITLE': 'HUAGURUNCHO 360 API',
    'DESCRIPTION': 'API REST para turismo sostenible, tour virtual 360 y eco-reportes ambientales en el Nevado Huaguruncho (Huachón, Pasco, Perú).',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'SCHEMA_PATH_PREFIX': '/api/v1',
    'COMPONENT_SPLIT_REQUEST': True,
    'ENUM_NAME_OVERRIDES': {
        'SafetyRecommendationCategoryEnum': 'apps.tourism.models.SafetyRecommendation.Category',
        'BiodiversityCategoryEnum': 'apps.tourism.models.BiodiversitySpecies.Category',
        'BiodiversityConservationStatusEnum': 'apps.tourism.models.BiodiversitySpecies.ConservationStatus',
        'AudioGuideCategoryEnum': 'apps.tourism.models.AudioGuide.Category',
        'CommunityServiceCategoryEnum': 'apps.tourism.models.CommunityService.ServiceCategory',
        'CommunityPostCategoryEnum': 'apps.tourism.models.CommunityPost.PostCategory',
        'POICategoryEnum': 'apps.tourism.models.PointOfInterest.POICategory',
        'EnvironmentalReportCategoryEnum': 'apps.environmental_reports.models.EnvironmentalReport.Category',
        'EnvironmentalReportStatusEnum': 'apps.environmental_reports.models.EnvironmentalReport.Status',
        'TrekkingExpeditionStatusEnum': 'apps.tourism.models.TrekkingExpedition.Status',
        'CheckpointVisitorLogStatusEnum': 'apps.tourism.models.CheckpointVisitorLog.Status',
        'CheckpointVisitorLogWasteStatusEnum': 'apps.tourism.models.CheckpointVisitorLog.WasteStatus',
    },
}

# CORS Configuration
CORS_ALLOW_ALL_ORIGINS = DEBUG
CORS_ALLOWED_ORIGINS = config(
    'CORS_ALLOWED_ORIGINS',
    default='https://apih.aquienpasco.com,https://aquienpasco.com,https://www.aquienpasco.com,http://localhost:3000,http://127.0.0.1:3000,http://localhost:8080',
    cast=Csv()
)
CORS_ALLOWED_ORIGIN_REGEXES = [
    r"^https:\/\/.*\.aquienpasco\.com$",
]
CORS_ALLOW_CREDENTIALS = True

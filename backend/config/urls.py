"""
URL Configuration for HUAGURUNCHO 360 backend.
"""
from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)
from apps.common.views import HealthCheckView, RootHealthCheckView, media_serve

api_v1_patterns = [
    path('health/', HealthCheckView.as_view(), name='health'),
    path('auth/', include('apps.accounts.urls')),
    path('', include('apps.tourism.urls')),
    path('', include('apps.environmental_reports.urls')),
    path('', include('apps.offline_packages.urls')),
]

urlpatterns = [
    path('health/', RootHealthCheckView.as_view(), name='root-health-check'),
    path('admin/', admin.site.urls),
    path('api/v1/', include((api_v1_patterns, 'api-v1'))),
    
    # OpenAPI 3.0 / Swagger documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    # Landing Page & HTMX endpoints
    path('', include('apps.landing.urls')),
]

if getattr(settings, 'SERVE_MEDIA_FILES', False) or settings.DEBUG:
    urlpatterns += [
        re_path(r'^media/(?P<path>.*)$', media_serve, {'document_root': settings.MEDIA_ROOT}),
    ]
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

admin.site.site_header = "HUAGURUNCHO 360 - Panel Administrativo"
admin.site.site_title = "HUAGURUNCHO 360 Admin"
admin.site.index_title = "Gestión de Turismo Sostenible y Reportes Ambientales"

"""
Common API and system views for HUAGURUNCHO 360.
"""
from django.db import connection
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from drf_spectacular.utils import extend_schema, inline_serializer
from rest_framework import serializers

from .rust_bridge import is_rust_engine_available, rust_engine_version
from django.views.static import serve
from django.http import HttpResponse


def media_serve(request, path, document_root=None, show_indexes=False):
    """
    Sirve archivos de media en producción con cabeceras CORS permisivas
    y cacheado optimizado para texturas 360 WebGL, audio y paquetes offline.
    """
    if request.method == "OPTIONS":
        response = HttpResponse(status=200)
    else:
        response = serve(request, path, document_root=document_root, show_indexes=show_indexes)

    response["Access-Control-Allow-Origin"] = "*"
    response["Access-Control-Allow-Methods"] = "GET, HEAD, OPTIONS"
    response["Access-Control-Allow-Headers"] = "*"
    if response.status_code == 200:
        response["Cache-Control"] = "public, max-age=86400"
    return response


class HealthCheckView(APIView):
    """
    Healthcheck endpoint para orquestadores (Docker, Kubernetes, AWS, Nginx).
    Verifica conectividad a la base de datos y disponibilidad del motor nativo.
    """
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        summary="Verificación de estado de salud del sistema",
        description="Retorna el estado de la API, conectividad de base de datos y motor nativo.",
        responses={
            200: inline_serializer(
                name='HealthCheckResponse',
                fields={
                    'status': serializers.CharField(),
                    'timestamp': serializers.DateTimeField(),
                    'database': serializers.CharField(),
                    'service': serializers.CharField(),
                    'version': serializers.CharField(),
                    'domain': serializers.CharField(),
                    'rust_engine': serializers.DictField(),
                }
            )
        }
    )
    def get(self, request):
        db_status = "operational"
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1;")
                cursor.fetchone()
        except Exception as e:
            db_status = f"unhealthy: {str(e)}"
            return Response(
                {
                    "status": "unhealthy",
                    "timestamp": timezone.now().isoformat(),
                    "database": db_status,
                    "service": "huaguruncho-api",
                    "domain": "apih.aquienpasco.com",
                },
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        return Response(
            {
                "status": "ok",
                "timestamp": timezone.now().isoformat(),
                "database": db_status,
                "service": "huaguruncho-api",
                "version": "1.0.0",
                "domain": "apih.aquienpasco.com",
                "rust_engine": {
                    "available": is_rust_engine_available(),
                    "version": rust_engine_version(),
                },
            },
            status=status.HTTP_200_OK,
        )


class RootHealthCheckView(HealthCheckView):
    """
    Healthcheck interno para orquestadores Docker / K8s / ALB (excluido de OpenAPI).
    """
    @extend_schema(exclude=True)
    def get(self, request):
        return super().get(request)


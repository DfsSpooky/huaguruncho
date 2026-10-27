from django.http import HttpResponse, FileResponse
from rest_framework import permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from apps.tourism.models import Route
from .models import OfflinePackage
from .serializers import OfflinePackageSerializer
from .services import update_or_create_offline_package, get_or_generate_offline_zip


class RouteOfflinePackageView(APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        summary="Obtener manifiesto del paquete offline para una ruta",
        description="Retorna el contenido empaquetado (rutas, escenas, hotspots y URLs de panoramas) para almacenamiento offline en la app.",
        responses={200: OfflinePackageSerializer}
    )
    def get(self, request, uuid):
        route = Route.objects.filter(uuid=uuid, is_active=True).first()
        if not route:
            return Response({'detail': 'Ruta no encontrada o inactiva.'}, status=status.HTTP_404_NOT_FOUND)

        package = getattr(route, 'offline_package', None)
        if not package or not package.is_published:
            package = update_or_create_offline_package(route, request)

        serializer = OfflinePackageSerializer(package)
        return Response(serializer.data, status=status.HTTP_200_OK)


class RouteOfflinePackageDownloadView(APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        summary="Descargar paquete ZIP offline completo",
        description="Transmite en streaming un archivo ZIP pre-almacenado con manifest.json, geometrías GeoJSON, fotos 360 y checksum SHA-256.",
        responses={200: {'type': 'string', 'format': 'binary'}}
    )
    def get(self, request, uuid):
        route = Route.objects.filter(uuid=uuid, is_active=True).first()
        if not route:
            return Response({'detail': 'Ruta no encontrada o inactiva.'}, status=status.HTTP_404_NOT_FOUND)

        zip_path, sha256 = get_or_generate_offline_zip(route)
        filename = f"huaguruncho_offline_{route.slug or 'route'}.zip"

        response = FileResponse(open(zip_path, 'rb'), content_type='application/zip')
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        response['X-Checksum-SHA256'] = sha256
        return response


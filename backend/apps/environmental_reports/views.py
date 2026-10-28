from rest_framework import viewsets, permissions, status, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from drf_spectacular.utils import extend_schema, extend_schema_view
from django.utils import timezone
from django.db import transaction
from apps.common.permissions import IsMunicipalidadOrAdmin, IsOwnerOrAdmin
from .models import EnvironmentalReport, ReportEvidence
from apps.tourism.models import Route
from .serializers import (
    EnvironmentalReportSerializer,
    EnvironmentalReportCreateSerializer,
    ReportEvidenceSerializer,
    SyncBatchRequestSerializer,
    SyncBatchResponseSerializer,
    AdminReportStatusSerializer,
)


@extend_schema_view(
    create=extend_schema(
        summary="Crear un nuevo reporte ambiental",
        description="Registra un reporte de incidente ambiental. Si se envía local_uuid existente, retorna el registro sin duplicar."
    ),
    retrieve=extend_schema(summary="Obtener detalle de un reporte ambiental")
)
class EnvironmentalReportViewSet(viewsets.ModelViewSet):
    queryset = EnvironmentalReport.objects.prefetch_related('evidences', 'user', 'route')
    lookup_field = 'uuid'
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['category', 'status', 'route__uuid']
    search_fields = ['description', 'admin_notes']
    ordering_fields = ['captured_at', 'created_at']

    def get_permissions(self):
        if self.action in ['update', 'partial_update', 'destroy']:
            return [IsMunicipalidadOrAdmin()]
        return [permissions.IsAuthenticatedOrReadOnly()]

    def get_serializer_class(self):
        if self.action in ['create']:
            return EnvironmentalReportCreateSerializer
        return EnvironmentalReportSerializer

    def get_queryset(self):
        user = self.request.user
        if not user or not user.is_authenticated:
            # Usuarios anónimos solo pueden ver mediante endpoints específicos o nada
            return EnvironmentalReport.objects.none()
        if user.is_staff or getattr(user, 'role', '') in ['administrador', 'municipalidad']:
            return EnvironmentalReport.objects.prefetch_related('evidences', 'user', 'route').all()
        return EnvironmentalReport.objects.filter(user=user).prefetch_related('evidences', 'route')

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        report = serializer.save()
        response_serializer = EnvironmentalReportSerializer(report, context={'request': request})
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)


class MyReportsListView(generics.ListAPIView):
    serializer_class = EnvironmentalReportSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['category', 'status']
    ordering_fields = ['captured_at', 'created_at']

    @extend_schema(
        summary="Listar reportes del usuario autenticado",
        description="Retorna la lista histórica de reportes creados por el usuario en sesión."
    )
    def get_queryset(self):
        if getattr(self, 'swagger_fake_view', False):
            return EnvironmentalReport.objects.none()
        return EnvironmentalReport.objects.filter(user=self.request.user).prefetch_related('evidences', 'route')


class SyncBatchView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        summary="Sincronización en lote de eco-reportes offline",
        description="Recibe una lista de reportes capturados offline. Es idempotente respecto a local_uuid.",
        request=SyncBatchRequestSerializer,
        responses={200: SyncBatchResponseSerializer}
    )
    @transaction.atomic
    def post(self, request):
        serializer = SyncBatchRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        reports_data = serializer.validated_data.get('reports', [])

        results = []
        for item in reports_data:
            local_uuid = item.get('local_uuid')
            try:
                report = EnvironmentalReport.objects.filter(
                    local_uuid=local_uuid,
                    user=request.user,
                ).first()
                if not report:
                    # Evitar colisión si otro usuario ya registró ese local_uuid
                    if EnvironmentalReport.objects.filter(local_uuid=local_uuid).exists():
                        import uuid as uuid_lib
                        local_uuid = f"{local_uuid}-{str(uuid_lib.uuid4())[:8]}"

                    route_uuid = item.get('route_uuid')
                    route = None
                    if route_uuid:
                        route = Route.objects.filter(uuid=route_uuid).first()

                    report = EnvironmentalReport.objects.create(
                        local_uuid=local_uuid,
                        user=request.user,
                        route=route,
                        category=item.get('category'),
                        description=item.get('description'),
                        latitude=item.get('latitude'),
                        longitude=item.get('longitude'),
                        accuracy_meters=item.get('accuracy_meters'),
                        captured_at=item.get('captured_at') or timezone.now()
                    )
                    msg = "Reporte sincronizado correctamente"
                else:
                    msg = "Reporte ya existía en el servidor (idempotente)"

                from apps.common.rust_bridge import rust_sign_eco_report
                sig_data = rust_sign_eco_report(
                    str(local_uuid),
                    str(report.category),
                    float(report.latitude),
                    float(report.longitude),
                    report.captured_at.isoformat() if report.captured_at else "",
                )
                verif_code = sig_data.get('verification_code') if sig_data else None

                results.append({
                    'local_uuid': local_uuid,
                    'success': True,
                    'server_uuid': report.uuid,
                    'status': report.status,
                    'message': msg,
                    'verification_code': verif_code,
                })
            except Exception as e:
                results.append({
                    'local_uuid': local_uuid,
                    'success': False,
                    'server_uuid': None,
                    'status': 'error',
                    'message': f"Error al procesar: {str(e)}"
                })

        return Response({'results': results}, status=status.HTTP_200_OK)


class ReportEvidenceCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    serializer_class = ReportEvidenceSerializer

    @extend_schema(
        summary="Adjuntar evidencia fotográfica a un reporte",
        description="Sube una fotografía de evidencia para un reporte ambiental existente.",
        responses={201: ReportEvidenceSerializer}
    )
    def post(self, request, uuid):
        report = EnvironmentalReport.objects.filter(uuid=uuid).first()
        if not report:
            return Response({'detail': 'Reporte no encontrado.'}, status=status.HTTP_404_NOT_FOUND)

        is_authority = (
            request.user.is_staff
            or getattr(request.user, 'role', '') in ['administrador', 'municipalidad', 'guardaparque']
        )
        if report.user_id != request.user.id and not is_authority:
            return Response(
                {'detail': 'No tiene permisos para adjuntar evidencia a un reporte de otro usuario.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        if 'image' not in request.FILES:
            return Response({'image': 'Archivo de imagen requerido.'}, status=status.HTTP_400_BAD_REQUEST)

        uploaded_image = request.FILES['image']
        allowed_extensions = ('.jpg', '.jpeg', '.png', '.webp', '.heic')
        file_name_lower = (uploaded_image.name or '').lower()
        if not file_name_lower.endswith(allowed_extensions):
            return Response(
                {'image': 'Formato de archivo no permitido. Use JPG, PNG, WEBP o HEIC.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if uploaded_image.size > 15 * 1024 * 1024:
            return Response(
                {'image': 'La imagen excede el tamaño máximo permitido de 15 MB.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        evidence = ReportEvidence.objects.create(
            report=report,
            image=uploaded_image
        )
        serializer = ReportEvidenceSerializer(evidence, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class AdminReportViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = EnvironmentalReport.objects.prefetch_related('evidences', 'user', 'route').all()
    serializer_class = EnvironmentalReportSerializer
    lookup_field = 'uuid'
    permission_classes = [IsMunicipalidadOrAdmin]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['category', 'status', 'route__uuid']
    search_fields = ['description', 'admin_notes', 'user__full_name', 'user__email']
    ordering_fields = ['captured_at', 'created_at', 'status']

    @extend_schema(
        summary="Actualizar estado de reporte (Administración)",
        request=AdminReportStatusSerializer,
        responses={200: EnvironmentalReportSerializer}
    )
    def partial_update(self, request, uuid=None):
        report = self.get_object()
        serializer = AdminReportStatusSerializer(report, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(EnvironmentalReportSerializer(report, context={'request': request}).data)

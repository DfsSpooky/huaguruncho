from django.db.models import Sum
from django.utils import timezone
from rest_framework import viewsets, permissions, generics, views
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from drf_spectacular.utils import extend_schema, extend_schema_view
from .utils.gpx_parser import parse_gpx_content
from .models import (
    Route,
    TourScene,
    Hotspot,
    PointOfInterest,
    SafetyRecommendation,
    BiodiversitySpecies,
    MountainWeatherStation,
    WeatherAlert,
    AudioGuide,
    CommunityService,
    EmergencyContact,
    CommunityPost,
    GuardianBadge,
    TrailPassportStamp,
    MunicipalNotice,
    TrekkingExpedition,
    CommunityServiceReview,
    CheckpointVisitorLog,
)
from apps.common.permissions import IsMunicipalidadOrAdmin
from django.db import transaction
from .serializers import (
    RouteListSerializer,
    RouteDetailSerializer,
    TourSceneSerializer,
    HotspotSerializer,
    PointOfInterestSerializer,
    SafetyRecommendationSerializer,
    BiodiversitySpeciesSerializer,
    MountainWeatherStationSerializer,
    WeatherAlertSerializer,
    AudioGuideSerializer,
    CommunityServiceSerializer,
    EmergencyContactSerializer,
    CommunityPostSerializer,
    GuardianBadgeSerializer,
    TrailPassportStampSerializer,
    MunicipalNoticeSerializer,
    TrekkingExpeditionSerializer,
    CommunityServiceReviewSerializer,
    CheckpointVisitorLogSerializer,
    CheckpointSyncBatchRequestSerializer,
    CheckpointSyncBatchResponseSerializer,
    AnalyticsOverviewSerializer,
)


@extend_schema_view(
    list=extend_schema(summary="Listar rutas turísticas activas"),
    retrieve=extend_schema(summary="Obtener detalle de ruta con sus escenas 360 y puntos de interés")
)
class RouteViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Route.objects.filter(is_active=True).prefetch_related('scenes__hotspots', 'points_of_interest')
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['difficulty']
    search_fields = ['name', 'description']
    ordering_fields = ['distance_km', 'estimated_duration_minutes', 'name']

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return RouteDetailSerializer
        return RouteListSerializer

    @extend_schema(
        summary="Listar escenas 360 asociadas a una ruta",
        responses={200: TourSceneSerializer(many=True)}
    )
    @action(detail=True, methods=['get'])
    def scenes(self, request, uuid=None):
        route = self.get_object()
        scenes = route.scenes.filter(is_active=True).prefetch_related('hotspots')
        serializer = TourSceneSerializer(scenes, many=True, context={'request': request})
        return Response(serializer.data)

    @extend_schema(
        summary="Listar puntos de interés (POIs) asociados a una ruta",
        responses={200: PointOfInterestSerializer(many=True)}
    )
    @action(detail=True, methods=['get'])
    def points_of_interest(self, request, uuid=None):
        route = self.get_object()
        pois = route.points_of_interest.filter(is_active=True)
        serializer = PointOfInterestSerializer(pois, many=True, context={'request': request})
        return Response(serializer.data)

    @extend_schema(
        summary="Subir y procesar archivo GPX de Wikiloc / Garmin",
    )
    @action(
        detail=True,
        methods=['post'],
        url_path='upload-gpx',
        permission_classes=[IsMunicipalidadOrAdmin],
    )
    def upload_gpx(self, request, uuid=None):
        route = self.get_object()
        gpx_file = request.FILES.get('gpx_file')
        gpx_content = request.data.get('gpx_content')

        if not gpx_file and not gpx_content:
            return Response({'error': 'Debe adjuntar un archivo gpx_file o texto gpx_content.'}, status=400)

        try:
            if gpx_file:
                raw_text = gpx_file.read().decode('utf-8', errors='ignore')
                route.gpx_file = gpx_file
            else:
                raw_text = str(gpx_content)

            res = parse_gpx_content(raw_text)
            if not res.get('success'):
                return Response({'error': res.get('error', 'Error al procesar GPX')}, status=400)

            route.geojson_track = res.get('geojson_track')
            route.elevation_profile = res.get('elevation_profile')
            route.elevation_gain_m = res.get('elevation_gain_m', 0.0)
            route.elevation_loss_m = res.get('elevation_loss_m', 0.0)
            route.max_altitude_m = int(res.get('max_altitude_m', 0))
            route.min_altitude_m = int(res.get('min_altitude_m', 0))
            if res.get('total_distance_km'):
                route.distance_km = res.get('total_distance_km')
            route.save()

            # Importar waypoints como POIs opcionalmente
            import_waypoints = request.data.get('import_waypoints', True)
            created_pois = 0
            if import_waypoints and res.get('waypoints'):
                for idx, wpt in enumerate(res.get('waypoints'), start=1):
                    PointOfInterest.objects.get_or_create(
                        route=route,
                        name=wpt.get('name', f'Punto {idx}'),
                        defaults={
                            'latitude': wpt.get('latitude'),
                            'longitude': wpt.get('longitude'),
                            'altitude_masl': int(wpt.get('altitude_m', 0)),
                            'description': wpt.get('description', ''),
                            'category': PointOfInterest.POICategory.MIRADOR,
                            'order': idx,
                        }
                    )
                    created_pois += 1

            return Response({
                'success': True,
                'message': 'Ruta GPX de Wikiloc importada y procesada correctamente.',
                'distance_km': route.distance_km,
                'elevation_gain_m': route.elevation_gain_m,
                'max_altitude_m': route.max_altitude_m,
                'min_altitude_m': route.min_altitude_m,
                'points_count': res.get('point_count', 0),
                'waypoints_imported': created_pois,
            })
        except Exception as e:
            return Response({'error': f'Error interno al procesar GPX: {str(e)}'}, status=500)

    @extend_schema(
        summary="Obtener datos completos para el Tour 360 Studio (Mapa OSM + Visor 360)",
    )
    @action(detail=True, methods=['get'], url_path='studio-data')
    def studio_data(self, request, uuid=None):
        route = self.get_object()
        scenes = route.scenes.filter(is_active=True).order_by('sequence').prefetch_related('hotspots')
        pois = route.points_of_interest.filter(is_active=True).order_by('order')

        scenes_data = TourSceneSerializer(scenes, many=True, context={'request': request}).data
        pois_data = PointOfInterestSerializer(pois, many=True, context={'request': request}).data

        return Response({
            'route': {
                'uuid': str(route.uuid),
                'name': route.name,
                'distance_km': float(route.distance_km),
                'elevation_gain_m': float(route.elevation_gain_m),
                'max_altitude_m': route.max_altitude_m,
                'min_altitude_m': route.min_altitude_m,
                'geojson_track': route.geojson_track,
                'elevation_profile': route.elevation_profile,
            },
            'scenes': scenes_data,
            'points_of_interest': pois_data,
        })

    @extend_schema(
        summary="Generar automáticamente enlaces de navegación Street View (Avanzar / Retroceder) entre escenas consecutivas",
    )
    @action(
        detail=True,
        methods=['post'],
        url_path='auto-link-street-view',
        permission_classes=[IsMunicipalidadOrAdmin],
    )
    def auto_link_street_view(self, request, uuid=None):
        route = self.get_object()
        scenes = list(route.scenes.filter(is_active=True).order_by('sequence'))

        if len(scenes) < 2:
            return Response({'message': 'Se requieren al menos 2 escenas para generar enlaces Street View.'}, status=400)

        created_links = 0
        for i in range(len(scenes) - 1):
            curr_scene = scenes[i]
            next_scene = scenes[i + 1]

            # Hotspot hacia adelante
            Hotspot.objects.update_or_create(
                source_scene=curr_scene,
                target_scene=next_scene,
                type=Hotspot.HotspotType.NAVIGATION,
                defaults={
                    'title': f'Avanzar hacia {next_scene.title}',
                    'content': f'Continuar sendero hacia {next_scene.title}',
                    'yaw': 0.0,
                    'pitch': -5.0,
                    'icon': 'arrow_forward',
                }
            )

            # Hotspot hacia atrás
            Hotspot.objects.update_or_create(
                source_scene=next_scene,
                target_scene=curr_scene,
                type=Hotspot.HotspotType.NAVIGATION,
                defaults={
                    'title': f'Retroceder hacia {curr_scene.title}',
                    'content': f'Regresar sendero hacia {curr_scene.title}',
                    'yaw': 180.0,
                    'pitch': -5.0,
                    'icon': 'arrow_back',
                }
            )
            created_links += 2

        return Response({
            'success': True,
            'message': f'Se generaron {created_links} enlaces de navegación Street View entre {len(scenes)} escenas.',
            'scenes_linked': len(scenes),
        })


@extend_schema_view(
    retrieve=extend_schema(summary="Obtener detalle de escena 360 con sus hotspots")
)
class TourSceneViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = TourScene.objects.filter(is_active=True).prefetch_related('hotspots', 'route')
    serializer_class = TourSceneSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        summary="Listar hotspots de una escena específica",
        responses={200: HotspotSerializer(many=True)}
    )
    @action(detail=True, methods=['get'])
    def hotspots(self, request, uuid=None):
        scene = self.get_object()
        hotspots = scene.hotspots.all()
        serializer = HotspotSerializer(hotspots, many=True, context={'request': request})
        return Response(serializer.data)


class HotspotViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Hotspot.objects.select_related('source_scene', 'target_scene')
    serializer_class = HotspotSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]


@extend_schema(
    summary="Listar recomendaciones de seguridad y sostenibilidad",
    description="Retorna la lista completa de recomendaciones para el turista altoandino."
)
class SafetyRecommendationListView(generics.ListAPIView):
    queryset = SafetyRecommendation.objects.filter(is_active=True).order_by('category', 'order')
    serializer_class = SafetyRecommendationSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['category']
    pagination_class = None


@extend_schema_view(
    list=extend_schema(summary="Listar catálogo de biodiversidad altoandina"),
    retrieve=extend_schema(summary="Obtener detalle de una especie de flora o fauna")
)
class BiodiversitySpeciesViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = BiodiversitySpecies.objects.filter(is_active=True).order_by('order', 'name')
    serializer_class = BiodiversitySpeciesSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['category', 'conservation_status', 'is_endemic']
    search_fields = ['name', 'quechua_name', 'scientific_name', 'summary']
    ordering_fields = ['order', 'name', 'category']
    pagination_class = None


@extend_schema_view(
    list=extend_schema(summary="Listar estaciones meteorológicas por piso altitudinal"),
    retrieve=extend_schema(summary="Obtener clima detallado de una estación/sector")
)
class MountainWeatherStationViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = MountainWeatherStation.objects.filter(is_active=True).order_by('altitude_masl', 'order')
    serializer_class = MountainWeatherStationSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['risk_level']
    ordering_fields = ['altitude_masl', 'order']
    pagination_class = None

    def list(self, request, *args, **kwargs):
        # Auto-sincronización con telemetría de Open-Meteo (Yanacancha -5.5°C) si es la primera vez o pasaron >15 min
        from .services.weather_service import sync_weather_stations
        from django.utils import timezone
        from datetime import timedelta

        latest_station = MountainWeatherStation.objects.order_by('-updated_at').first()
        should_sync = not latest_station or (timezone.now() - latest_station.updated_at > timedelta(minutes=15))
        if should_sync:
            try:
                sync_weather_stations()
            except Exception:
                pass

        return super().list(request, *args, **kwargs)

    @action(detail=False, methods=['get', 'post'], url_path='refresh')
    def refresh(self, request):
        """Forzar actualización en tiempo real desde la API meteorológica"""
        from .services.weather_service import sync_weather_stations
        sync_result = sync_weather_stations(force_refresh=True)
        stations = self.get_queryset()
        serializer = self.get_serializer(stations, many=True)
        return Response({
            'meta': sync_result,
            'stations': serializer.data,
        })


@extend_schema_view(
    list=extend_schema(summary="Listar alertas meteorológicas activas de montaña"),
    retrieve=extend_schema(summary="Obtener detalle de una alerta meteorológica")
)
class WeatherAlertViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = WeatherAlert.objects.filter(is_active=True).order_by('-valid_from')
    serializer_class = WeatherAlertSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['severity']
    pagination_class = None


@extend_schema_view(
    list=extend_schema(summary="Listar audioguías y relatos culturales bilingües"),
    retrieve=extend_schema(summary="Obtener detalle de audioguía con transcripciones en Español y Quechua")
)
class AudioGuideViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = AudioGuide.objects.filter(is_active=True).order_by('order', 'title_es')
    serializer_class = AudioGuideSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, SearchFilter]
    filterset_fields = ['category']
    search_fields = ['title_es', 'title_qu', 'location_name', 'transcript_es', 'transcript_qu']
    pagination_class = None


@extend_schema_view(
    list=extend_schema(summary="Listar servicios y emprendimientos comunitarios de Huachón"),
    retrieve=extend_schema(summary="Obtener detalle de servicio comunitario")
)
class CommunityServiceViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = CommunityService.objects.filter(is_active=True).order_by('category', 'order', 'name')
    serializer_class = CommunityServiceSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, SearchFilter]
    filterset_fields = ['category']
    search_fields = ['name', 'location_address', 'services_description', 'badge_text']
    pagination_class = None


@extend_schema_view(
    list=extend_schema(summary="Listar contactos de emergencia SOS y brigadas de rescate"),
    retrieve=extend_schema(summary="Obtener detalle de contacto de emergencia")
)
class EmergencyContactViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = EmergencyContact.objects.filter(is_active=True).order_by('priority_order', 'title')
    serializer_class = EmergencyContactSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]
    pagination_class = None


@extend_schema_view(
    list=extend_schema(summary="Listar publicaciones aprobadas del muro comunitario"),
    retrieve=extend_schema(summary="Obtener detalle de publicación comunitaria"),
    create=extend_schema(summary="Crear nueva publicación en el muro comunitario (pasa a moderación)")
)
class CommunityPostViewSet(viewsets.ModelViewSet):
    queryset = CommunityPost.objects.filter(is_active=True, is_approved=True).order_by('-created_at')
    serializer_class = CommunityPostSerializer
    lookup_field = 'uuid'
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['category', 'lnt_verified']
    search_fields = ['author_name', 'location_name', 'content']
    ordering_fields = ['-created_at', '-munay_count']

    def get_permissions(self):
        if self.action in ['create']:
            return [permissions.IsAuthenticated()]
        elif self.action in ['update', 'partial_update', 'destroy']:
            return [IsMunicipalidadOrAdmin()]
        return [permissions.AllowAny()]

    def perform_create(self, serializer):
        user = self.request.user
        author_name = serializer.validated_data.get('author_name') or (
            user.full_name if user and user.is_authenticated else 'Excursionista'
        )
        serializer.save(author_name=author_name)


@extend_schema_view(
    list=extend_schema(summary="Listar puntos de interés georreferenciados (POIs)"),
    retrieve=extend_schema(summary="Obtener detalle de punto de interés")
)
class PointOfInterestViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = PointOfInterest.objects.filter(is_active=True).order_by('order', 'name')
    serializer_class = PointOfInterestSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, SearchFilter]
    filterset_fields = ['category', 'route']
    search_fields = ['name', 'description']
    pagination_class = None


@extend_schema_view(
    list=extend_schema(summary="Listar medallas y logros ecológicos de Guardián Glacial"),
    retrieve=extend_schema(summary="Obtener detalle de medalla")
)
class GuardianBadgeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = GuardianBadge.objects.filter(is_active=True).order_by('order', 'tier')
    serializer_class = GuardianBadgeSerializer
    lookup_field = 'slug'
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['tier']
    pagination_class = None


@extend_schema_view(
    list=extend_schema(summary="Listar sellos del Pasaporte de Montaña por ruta"),
    retrieve=extend_schema(summary="Obtener detalle de sello de pasaporte")
)
class TrailPassportStampViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = TrailPassportStamp.objects.filter(is_active=True).order_by('order')
    serializer_class = TrailPassportStampSerializer
    lookup_field = 'uuid'
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['route']
    pagination_class = None


class AnalyticsOverviewAPIView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        summary="Obtener métricas globales de turismo, conservación y comunidad",
        responses={200: AnalyticsOverviewSerializer}
    )
    def get(self, request):
        from ..environmental_reports.models import EnvironmentalReport

        total_routes = Route.objects.filter(is_active=True).count()
        total_km = Route.objects.filter(is_active=True).aggregate(t=Sum('distance_km'))['t'] or 0.0
        total_scenes = TourScene.objects.filter(is_active=True).count()
        total_pois = PointOfInterest.objects.filter(is_active=True).count()
        total_species = BiodiversitySpecies.objects.filter(is_active=True).count()
        total_stations = MountainWeatherStation.objects.filter(is_active=True).count()
        total_services = CommunityService.objects.filter(is_active=True).count()
        total_badges = GuardianBadge.objects.filter(is_active=True).count()
        total_stamps = TrailPassportStamp.objects.filter(is_active=True).count()

        total_reports = EnvironmentalReport.objects.count()
        resolved_reports = EnvironmentalReport.objects.filter(status='SOLUCIONADO').count()
        pending_reports = EnvironmentalReport.objects.filter(status='RECIBIDO').count()
        res_rate = round((resolved_reports / total_reports * 100), 1) if total_reports > 0 else 100.0

        from apps.common.rust_bridge import is_rust_engine_available, rust_engine_version

        return Response({
            'engine': {
                'rust_native_active': is_rust_engine_available(),
                'rust_version': rust_engine_version(),
            },
            'tourism': {
                'total_routes': total_routes,
                'total_distance_km': float(total_km),
                'total_360_scenes': total_scenes,
                'total_pois': total_pois,
                'total_weather_stations': total_stations,
                'total_community_services': total_services,
            },
            'conservation': {
                'total_species': total_species,
                'total_reports': total_reports,
                'resolved_reports': resolved_reports,
                'pending_reports': pending_reports,
                'resolution_rate_percent': res_rate,
            },
            'gamification': {
                'total_badges': total_badges,
                'total_passport_stamps': total_stamps,
            }
        })


@extend_schema_view(
    list=extend_schema(summary="Listar avisos y comunicados oficiales de la Municipalidad de Huachón"),
    retrieve=extend_schema(summary="Detalle de un comunicado municipal"),
)
class MunicipalNoticeViewSet(viewsets.ModelViewSet):
    queryset = MunicipalNotice.objects.filter(is_active=True)
    serializer_class = MunicipalNoticeSerializer
    lookup_field = 'uuid'
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['category', 'priority']
    search_fields = ['title', 'subtitle', 'full_text', 'department']
    ordering_fields = ['published_at', 'priority']
    ordering = ['-published_at']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [IsMunicipalidadOrAdmin()]


@extend_schema_view(
    list=extend_schema(summary="Listar expediciones registradas"),
    retrieve=extend_schema(summary="Detalle de una expedición"),
    create=extend_schema(summary="Registrar salida de expedición de alta montaña"),
)
class TrekkingExpeditionViewSet(viewsets.ModelViewSet):
    queryset = TrekkingExpedition.objects.all()
    serializer_class = TrekkingExpeditionSerializer
    lookup_field = 'uuid'
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['status', 'route']
    search_fields = ['tourist_name', 'tourist_phone', 'guide_name', 'emergency_contact_name']
    ordering_fields = ['departure_datetime', 'expected_return_datetime', 'created_at']
    ordering = ['-departure_datetime']
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        if self.action in ['destroy', 'update', 'partial_update']:
            return [IsMunicipalidadOrAdmin()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        if getattr(self, 'swagger_fake_view', False):
            return TrekkingExpedition.objects.none()
        user = self.request.user
        if not user or not user.is_authenticated:
            return TrekkingExpedition.objects.none()
        if user.is_staff or getattr(user, 'role', '') in ['administrador', 'municipalidad', 'guardaparque']:
            return TrekkingExpedition.objects.select_related('route', 'user').all()
        return TrekkingExpedition.objects.select_related('route', 'user').filter(user=user)

    def perform_create(self, serializer):
        user = self.request.user if self.request.user.is_authenticated else None
        tourist_name = serializer.validated_data.get('tourist_name') or (
            user.full_name if user else ''
        )
        tourist_phone = serializer.validated_data.get('tourist_phone') or (
            getattr(user, 'phone', '') if user else ''
        )
        serializer.save(
            user=user,
            tourist_name=tourist_name,
            tourist_phone=tourist_phone,
        )

    @action(detail=True, methods=['post'], url_path='check-out')
    def check_out(self, request, uuid=None):
        """
        Registra el retorno seguro del grupo de montaña (Check-out).
        """
        expedition = self.get_object()
        expedition.status = TrekkingExpedition.Status.RETORNADA
        expedition.actual_return_datetime = timezone.now()
        expedition.save(update_fields=['status', 'actual_return_datetime', 'updated_at'])
        return Response({
            'status': 'success',
            'message': 'Check-out registrado con éxito. ¡Bienvenido de vuelta a Huachón sano y salvo!',
            'expedition': TrekkingExpeditionSerializer(expedition).data
        })


@extend_schema_view(
    list=extend_schema(summary="Listar reseñas de servicios comunitarios"),
    create=extend_schema(summary="Publicar una reseña o calificación de un servicio"),
)
class CommunityServiceReviewViewSet(viewsets.ModelViewSet):
    queryset = CommunityServiceReview.objects.filter(is_approved=True)
    serializer_class = CommunityServiceReviewSerializer
    lookup_field = 'uuid'
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['service', 'rating']
    ordering_fields = ['created_at', 'rating']
    ordering = ['-created_at']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        elif self.action in ['create']:
            return [permissions.IsAuthenticated()]
        return [IsMunicipalidadOrAdmin()]

    def perform_create(self, serializer):
        user = self.request.user if self.request.user.is_authenticated else None
        author_name = serializer.validated_data.get('author_name') or (
            user.full_name if user else 'Excursionista'
        )
        serializer.save(user=user, author_name=author_name)


@extend_schema_view(
    list=extend_schema(summary="Listar registros del puesto de control (Guardaparques)"),
    create=extend_schema(summary="Registrar entrada de visitante y declaración de residuos"),
    retrieve=extend_schema(summary="Detalle de registro de puesto de control"),
)
class CheckpointVisitorLogViewSet(viewsets.ModelViewSet):
    """
    Control de acceso y retorno obligatorio de residuos sólidos en el Nevado Huaguruncho.
    Restringido exclusivamente a Guardaparques, Personal Municipal y Administradores.
    """
    queryset = CheckpointVisitorLog.objects.all()
    serializer_class = CheckpointVisitorLogSerializer
    lookup_field = 'uuid'
    permission_classes = [IsMunicipalidadOrAdmin]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['status', 'waste_compliance_status']
    search_fields = ['visitor_name', 'document_number', 'guide_name', 'phone']
    ordering_fields = ['entry_datetime', 'exit_datetime', 'total_items_in']
    ordering = ['-entry_datetime']

    def perform_create(self, serializer):
        user = self.request.user if self.request.user.is_authenticated else None
        serializer.save(created_by=user)

    @extend_schema(
        summary="Registrar salida de visitante e inspección de residuos (Check-out)",
        description="Verifica los residuos devueltos por el visitante y actualiza el estado de cumplimiento."
    )
    @action(detail=True, methods=['post'], url_path='check-out')
    def check_out(self, request, uuid=None):
        from apps.common.rust_bridge import rust_audit_huella_cero

        entry = self.get_object()
        data = request.data
        entry.exit_datetime = data.get('exit_datetime') or timezone.now()
        entry.exit_ranger_name = data.get('exit_ranger_name') or (request.user.full_name if request.user.is_authenticated else '')
        entry.plastic_bottles_out = int(data.get('plastic_bottles_out', entry.plastic_bottles_out))
        entry.cans_out = int(data.get('cans_out', entry.cans_out))
        entry.plastic_wrappers_out = int(data.get('plastic_wrappers_out', entry.plastic_wrappers_out))
        entry.plastic_bags_out = int(data.get('plastic_bags_out', entry.plastic_bags_out))
        entry.batteries_out = int(data.get('batteries_out', entry.batteries_out))
        entry.gas_canisters_out = int(data.get('gas_canisters_out', entry.gas_canisters_out))
        entry.total_items_out = entry.calculate_total_out()
        entry.notes = data.get('notes', entry.notes)
        entry.status = CheckpointVisitorLog.Status.RETORNADO

        audit = rust_audit_huella_cero({
            'local_uuid': entry.local_uuid or str(entry.uuid),
            'document_number': entry.document_number,
            'plastic_bottles_in': entry.plastic_bottles_in,
            'cans_in': entry.cans_in,
            'plastic_wrappers_in': entry.plastic_wrappers_in,
            'plastic_bags_in': entry.plastic_bags_in,
            'batteries_in': entry.batteries_in,
            'gas_canisters_in': entry.gas_canisters_in,
            'plastic_bottles_out': entry.plastic_bottles_out,
            'cans_out': entry.cans_out,
            'plastic_wrappers_out': entry.plastic_wrappers_out,
            'plastic_bags_out': entry.plastic_bags_out,
            'batteries_out': entry.batteries_out,
            'gas_canisters_out': entry.gas_canisters_out,
        })

        compliance = data.get('waste_compliance_status')
        if compliance:
            entry.waste_compliance_status = compliance
        elif audit and audit.get('waste_compliance_status'):
            entry.waste_compliance_status = audit['waste_compliance_status']
        else:
            if entry.total_items_out >= entry.total_items_in:
                if entry.total_items_out > entry.total_items_in:
                    entry.waste_compliance_status = CheckpointVisitorLog.WasteStatus.EXTRA_COLLECTED
                else:
                    entry.waste_compliance_status = CheckpointVisitorLog.WasteStatus.COMPLIANT
            else:
                entry.waste_compliance_status = CheckpointVisitorLog.WasteStatus.INFRACTION

        seal = audit.get('cryptographic_seal') if audit else None
        if seal and seal not in (entry.notes or ''):
            entry.notes = f"{entry.notes} [Sello Rust: {seal}]".strip()

        entry.save()
        return Response({
            'status': 'success',
            'message': 'Descenso y retorno de residuos verificado con éxito.',
            'cryptographic_seal': seal,
            'entry': CheckpointVisitorLogSerializer(entry).data
        })


class CheckpointSyncBatchView(views.APIView):
    """
    Endpoint de sincronización en lote offline para la garita de guardaparques.
    Idempotente respecto a local_uuid.
    """
    permission_classes = [IsMunicipalidadOrAdmin]

    @extend_schema(
        summary="Sincronización en lote offline de registros de guardabosques",
        request=CheckpointSyncBatchRequestSerializer,
        responses={200: CheckpointSyncBatchResponseSerializer}
    )
    @transaction.atomic
    def post(self, request):
        from apps.common.rust_bridge import rust_audit_huella_cero

        serializer = CheckpointSyncBatchRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        entries_data = serializer.validated_data.get('entries', [])

        results = []
        for item in entries_data:
            local_uuid = item.get('local_uuid')
            entry = CheckpointVisitorLog.objects.filter(local_uuid=local_uuid).first()
            audit = rust_audit_huella_cero(item) if item.get('exit_datetime') else None
            seal = audit.get('cryptographic_seal') if audit else None

            if not entry:
                notes_val = item.get('notes', '')
                if seal and seal not in notes_val:
                    notes_val = f"{notes_val} [Sello Rust: {seal}]".strip()

                entry = CheckpointVisitorLog.objects.create(
                    local_uuid=local_uuid,
                    checkpoint_name=item.get('checkpoint_name', 'Garita de Control Huaguruncho - Abra Huachón'),
                    created_by=request.user if request.user.is_authenticated else None,
                    visitor_name=item.get('visitor_name'),
                    document_type=item.get('document_type', 'DNI'),
                    document_number=item.get('document_number'),
                    phone=item.get('phone', ''),
                    group_size=item.get('group_size', 1),
                    route_name=item.get('route_name', 'Nevado Huaguruncho - Ruta Glaciar'),
                    guide_name=item.get('guide_name', ''),
                    entry_datetime=item.get('entry_datetime'),
                    entry_ranger_name=item.get('entry_ranger_name', ''),
                    # Residuos entrada
                    plastic_bottles_in=item.get('plastic_bottles_in', 0),
                    cans_in=item.get('cans_in', 0),
                    plastic_wrappers_in=item.get('plastic_wrappers_in', 0),
                    plastic_bags_in=item.get('plastic_bags_in', 0),
                    batteries_in=item.get('batteries_in', 0),
                    gas_canisters_in=item.get('gas_canisters_in', 0),
                    other_waste_details_in=item.get('other_waste_details_in', ''),
                    total_items_in=item.get('total_items_in', 0),
                    # Residuos salida (si ya se hizo checkout offline)
                    exit_datetime=item.get('exit_datetime'),
                    exit_ranger_name=item.get('exit_ranger_name', ''),
                    plastic_bottles_out=item.get('plastic_bottles_out', 0),
                    cans_out=item.get('cans_out', 0),
                    plastic_wrappers_out=item.get('plastic_wrappers_out', 0),
                    plastic_bags_out=item.get('plastic_bags_out', 0),
                    batteries_out=item.get('batteries_out', 0),
                    gas_canisters_out=item.get('gas_canisters_out', 0),
                    total_items_out=item.get('total_items_out', 0),
                    waste_compliance_status=item.get('waste_compliance_status', 'pending_checkout'),
                    status=item.get('status', 'en_montana'),
                    notes=notes_val,
                )
                action_taken = 'created'
            else:
                # Actualizar si hay datos más recientes (ej. checkout registrado offline)
                if item.get('exit_datetime') and not entry.exit_datetime:
                    entry.exit_datetime = item.get('exit_datetime')
                    entry.exit_ranger_name = item.get('exit_ranger_name', entry.exit_ranger_name)
                    entry.plastic_bottles_out = item.get('plastic_bottles_out', entry.plastic_bottles_out)
                    entry.cans_out = item.get('cans_out', entry.cans_out)
                    entry.plastic_wrappers_out = item.get('plastic_wrappers_out', entry.plastic_wrappers_out)
                    entry.plastic_bags_out = item.get('plastic_bags_out', entry.plastic_bags_out)
                    entry.batteries_out = item.get('batteries_out', entry.batteries_out)
                    entry.gas_canisters_out = item.get('gas_canisters_out', entry.gas_canisters_out)
                    entry.total_items_out = item.get('total_items_out', entry.total_items_out)
                    entry.waste_compliance_status = item.get('waste_compliance_status', entry.waste_compliance_status)
                    entry.status = item.get('status', entry.status)
                    if item.get('notes'):
                        entry.notes = item.get('notes')
                    if seal and seal not in (entry.notes or ''):
                        entry.notes = f"{entry.notes} [Sello Rust: {seal}]".strip()
                    entry.save()
                    action_taken = 'updated'
                else:
                    action_taken = 'unchanged'

            results.append({
                'local_uuid': local_uuid,
                'server_uuid': str(entry.uuid),
                'status': 'synced',
                'action': action_taken,
                'cryptographic_seal': seal,
            })

        return Response({
            'processed': len(results),
            'results': results,
        })





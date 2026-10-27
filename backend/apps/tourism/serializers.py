from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
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


class HotspotSerializer(serializers.ModelSerializer):
    target_scene_uuid = serializers.UUIDField(source='target_scene.uuid', read_only=True, allow_null=True)
    source_scene_uuid = serializers.UUIDField(source='source_scene.uuid', read_only=True)
    type_display = serializers.CharField(source='get_type_display', read_only=True)
    media_image_url = serializers.SerializerMethodField()

    class Meta:
        model = Hotspot
        fields = (
            'id',
            'uuid',
            'source_scene_uuid',
            'target_scene_uuid',
            'type',
            'type_display',
            'yaw',
            'pitch',
            'target_yaw',
            'target_pitch',
            'title',
            'content',
            'media_image_url',
            'audio_url',
            'icon',
        )

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_media_image_url(self, obj):
        request = self.context.get('request')
        if obj.media_image and hasattr(obj.media_image, 'url'):
            return request.build_absolute_uri(obj.media_image.url) if request else obj.media_image.url
        return None


class TourSceneSerializer(serializers.ModelSerializer):
    route_uuid = serializers.UUIDField(source='route.uuid', read_only=True)
    hotspots = HotspotSerializer(many=True, read_only=True)
    panorama_image_url = serializers.SerializerMethodField()
    thumbnail_url = serializers.SerializerMethodField()

    class Meta:
        model = TourScene
        fields = (
            'id',
            'uuid',
            'route_uuid',
            'title',
            'description',
            'panorama_image_url',
            'thumbnail_url',
            'latitude',
            'longitude',
            'altitude_masl',
            'heading',
            'initial_yaw',
            'initial_pitch',
            'is_control_point',
            'sequence',
            'is_active',
            'hotspots',
        )

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_panorama_image_url(self, obj):
        request = self.context.get('request')
        if obj.panorama_image and hasattr(obj.panorama_image, 'url'):
            return request.build_absolute_uri(obj.panorama_image.url) if request else obj.panorama_image.url
        return None

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_thumbnail_url(self, obj):
        request = self.context.get('request')
        if obj.thumbnail and hasattr(obj.thumbnail, 'url'):
            return request.build_absolute_uri(obj.thumbnail.url) if request else obj.thumbnail.url
        return None


class PointOfInterestSerializer(serializers.ModelSerializer):
    category_display = serializers.CharField(source='get_category_display', read_only=True)
    route_uuid = serializers.UUIDField(source='route.uuid', read_only=True, allow_null=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = PointOfInterest
        fields = (
            'id',
            'uuid',
            'route_uuid',
            'name',
            'category',
            'category_display',
            'altitude_masl',
            'latitude',
            'longitude',
            'description',
            'image_url',
            'order',
            'is_active',
        )

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None


class RouteListSerializer(serializers.ModelSerializer):
    difficulty_display = serializers.CharField(source='get_difficulty_display', read_only=True)
    scenes_count = serializers.IntegerField(source='scenes.count', read_only=True)
    cover_image_url = serializers.SerializerMethodField()
    gpx_file_url = serializers.SerializerMethodField()

    class Meta:
        model = Route
        fields = (
            'id',
            'uuid',
            'name',
            'slug',
            'description',
            'difficulty',
            'difficulty_display',
            'distance_km',
            'estimated_duration_minutes',
            'safety_recommendations',
            'cover_image_url',
            'gpx_file_url',
            'elevation_gain_m',
            'elevation_loss_m',
            'max_altitude_m',
            'min_altitude_m',
            'is_active',
            'scenes_count',
        )

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_cover_image_url(self, obj):
        request = self.context.get('request')
        if obj.cover_image and hasattr(obj.cover_image, 'url'):
            return request.build_absolute_uri(obj.cover_image.url) if request else obj.cover_image.url
        return None

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_gpx_file_url(self, obj):
        request = self.context.get('request')
        if obj.gpx_file and hasattr(obj.gpx_file, 'url'):
            return request.build_absolute_uri(obj.gpx_file.url) if request else obj.gpx_file.url
        return None


class RouteDetailSerializer(RouteListSerializer):
    scenes = TourSceneSerializer(many=True, read_only=True)
    points_of_interest = PointOfInterestSerializer(many=True, read_only=True)

    class Meta(RouteListSerializer.Meta):
        fields = RouteListSerializer.Meta.fields + ('scenes', 'points_of_interest', 'geojson_track', 'elevation_profile')


class SafetyRecommendationSerializer(serializers.ModelSerializer):
    category_display = serializers.CharField(source='get_category_display', read_only=True)

    class Meta:
        model = SafetyRecommendation
        fields = (
            'id',
            'category',
            'category_display',
            'title',
            'description',
            'order',
            'is_active',
        )


class BiodiversitySpeciesSerializer(serializers.ModelSerializer):
    category_display = serializers.CharField(source='get_category_display', read_only=True)
    conservation_status_display = serializers.CharField(source='get_conservation_status_display', read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = BiodiversitySpecies
        fields = (
            'id',
            'uuid',
            'name',
            'quechua_name',
            'scientific_name',
            'category',
            'category_display',
            'altitude_range',
            'conservation_status',
            'conservation_status_display',
            'is_endemic',
            'image_url',
            'summary',
            'ecological_role',
            'conservation_tip',
            'order',
            'is_active',
        )

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None


class MountainWeatherStationSerializer(serializers.ModelSerializer):
    risk_level_display = serializers.CharField(source='get_risk_level_display', read_only=True)

    class Meta:
        model = MountainWeatherStation
        fields = (
            'id',
            'uuid',
            'name',
            'altitude_masl',
            'temp_day_celsius',
            'temp_night_celsius',
            'condition',
            'weather_icon',
            'wind_kmh',
            'wind_gusts_kmh',
            'wind_chill_celsius',
            'uv_index',
            'uv_level',
            'humidity_percentage',
            'pressure_hpa',
            'risk_level',
            'risk_level_display',
            'alert_advisory',
            'order',
            'is_active',
            'updated_at',
        )


class WeatherAlertSerializer(serializers.ModelSerializer):
    severity_display = serializers.CharField(source='get_severity_display', read_only=True)

    class Meta:
        model = WeatherAlert
        fields = (
            'id',
            'uuid',
            'title',
            'severity',
            'severity_display',
            'description',
            'affected_sector',
            'valid_from',
            'valid_until',
            'is_active',
        )


class AudioGuideSerializer(serializers.ModelSerializer):
    category_display = serializers.CharField(source='get_category_display', read_only=True)
    audio_file_url = serializers.SerializerMethodField()

    class Meta:
        model = AudioGuide
        fields = (
            'id',
            'uuid',
            'title_es',
            'title_qu',
            'category',
            'category_display',
            'location_name',
            'duration_formatted',
            'audio_file_url',
            'audio_url',
            'transcript_es',
            'transcript_qu',
            'didactic_glossary',
            'order',
            'is_active',
        )

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_audio_file_url(self, obj):
        request = self.context.get('request')
        if obj.audio_file and hasattr(obj.audio_file, 'url'):
            return request.build_absolute_uri(obj.audio_file.url) if request else obj.audio_file.url
        return obj.audio_url if obj.audio_url else None


class CommunityServiceReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommunityServiceReview
        fields = (
            'id',
            'uuid',
            'service',
            'user',
            'author_name',
            'rating',
            'comment',
            'created_at',
        )
        read_only_fields = ('is_approved',)


class CommunityServiceSerializer(serializers.ModelSerializer):
    category_display = serializers.CharField(source='get_category_display', read_only=True)
    image_url = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()
    reviews_count = serializers.SerializerMethodField()
    reviews = serializers.SerializerMethodField()

    class Meta:
        model = CommunityService
        fields = (
            'id',
            'uuid',
            'name',
            'category',
            'category_display',
            'contact_phone',
            'whatsapp_number',
            'location_address',
            'price_range',
            'badge_text',
            'experience_years',
            'services_description',
            'image_url',
            'average_rating',
            'reviews_count',
            'reviews',
            'order',
            'is_active',
        )

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None

    @extend_schema_field(serializers.FloatField())
    def get_average_rating(self, obj):
        approved_reviews = obj.reviews.filter(is_approved=True)
        if not approved_reviews.exists():
            return 5.0
        total = sum(r.rating for r in approved_reviews)
        return round(total / approved_reviews.count(), 1)

    @extend_schema_field(serializers.IntegerField())
    def get_reviews_count(self, obj):
        return obj.reviews.filter(is_approved=True).count()

    @extend_schema_field(CommunityServiceReviewSerializer(many=True))
    def get_reviews(self, obj):
        reviews = obj.reviews.filter(is_approved=True)[:10]
        return CommunityServiceReviewSerializer(reviews, many=True).data


class EmergencyContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyContact
        fields = (
            'id',
            'uuid',
            'title',
            'short_phone',
            'full_number',
            'description',
            'icon',
            'priority_order',
            'is_active',
        )


class CommunityPostSerializer(serializers.ModelSerializer):
    category_display = serializers.CharField(source='get_category_display', read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = CommunityPost
        fields = (
            'id',
            'uuid',
            'author_name',
            'author_role',
            'category',
            'category_display',
            'location_name',
            'content',
            'image_url',
            'munay_count',
            'lnt_verified',
            'is_approved',
            'created_at',
        )

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None


class GuardianBadgeSerializer(serializers.ModelSerializer):
    tier_display = serializers.CharField(source='get_tier_display', read_only=True)

    class Meta:
        model = GuardianBadge
        fields = (
            'id',
            'uuid',
            'slug',
            'title',
            'quechua_title',
            'description',
            'tier',
            'tier_display',
            'icon',
            'xp_points',
            'order',
            'is_active',
        )


class TrailPassportStampSerializer(serializers.ModelSerializer):
    route_name = serializers.CharField(source='route.name', read_only=True)

    class Meta:
        model = TrailPassportStamp
        fields = (
            'id',
            'uuid',
            'route',
            'route_name',
            'name',
            'quechua_name',
            'altitude_masl',
            'latitude',
            'longitude',
            'landmark_icon',
            'secret_code',
            'order',
            'is_active',
        )


class MunicipalNoticeSerializer(serializers.ModelSerializer):
    category_display = serializers.CharField(source='get_category_display', read_only=True)
    priority_display = serializers.CharField(source='get_priority_display', read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = MunicipalNotice
        fields = (
            'id',
            'uuid',
            'title',
            'subtitle',
            'category',
            'category_display',
            'priority',
            'priority_display',
            'department',
            'icon',
            'image_url',
            'full_text',
            'recommendations',
            'published_at',
            'valid_until',
            'is_active',
        )

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None


class TrekkingExpeditionSerializer(serializers.ModelSerializer):
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    route_name = serializers.CharField(source='route.name', read_only=True)

    class Meta:
        model = TrekkingExpedition
        fields = (
            'id',
            'uuid',
            'user',
            'tourist_name',
            'tourist_phone',
            'emergency_contact_name',
            'emergency_contact_phone',
            'route',
            'route_name',
            'group_size',
            'guide_name',
            'departure_datetime',
            'expected_return_datetime',
            'actual_return_datetime',
            'status',
            'status_display',
            'health_notes',
            'gear_checklist_verified',
            'admin_notes',
            'created_at',
        )
        read_only_fields = ('actual_return_datetime',)


class CheckpointVisitorLogSerializer(serializers.ModelSerializer):
    waste_compliance_status_display = serializers.CharField(source='get_waste_compliance_status_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = CheckpointVisitorLog
        fields = (
            'id',
            'uuid',
            'local_uuid',
            'checkpoint_name',
            'visitor_name',
            'document_type',
            'document_number',
            'phone',
            'group_size',
            'route_name',
            'guide_name',
            'entry_datetime',
            'entry_ranger_name',
            # Residuos subida
            'plastic_bottles_in',
            'cans_in',
            'plastic_wrappers_in',
            'plastic_bags_in',
            'batteries_in',
            'gas_canisters_in',
            'other_waste_details_in',
            'total_items_in',
            # Residuos bajada
            'exit_datetime',
            'exit_ranger_name',
            'plastic_bottles_out',
            'cans_out',
            'plastic_wrappers_out',
            'plastic_bags_out',
            'batteries_out',
            'gas_canisters_out',
            'total_items_out',
            'waste_compliance_status',
            'waste_compliance_status_display',
            'status',
            'status_display',
            'notes',
            'created_at',
            'updated_at',
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at')


class CheckpointSyncBatchItemSerializer(serializers.Serializer):
    local_uuid = serializers.CharField(max_length=64)
    checkpoint_name = serializers.CharField(required=False, default='Garita de Control Huaguruncho - Abra Huachón')
    visitor_name = serializers.CharField(max_length=150)
    document_type = serializers.CharField(required=False, default='DNI')
    document_number = serializers.CharField(max_length=50)
    phone = serializers.CharField(required=False, allow_blank=True, default='')
    group_size = serializers.IntegerField(required=False, default=1)
    route_name = serializers.CharField(required=False, default='Nevado Huaguruncho - Ruta Glaciar')
    guide_name = serializers.CharField(required=False, allow_blank=True, default='')
    entry_datetime = serializers.DateTimeField()
    entry_ranger_name = serializers.CharField(required=False, allow_blank=True, default='')
    # Residuos entrada
    plastic_bottles_in = serializers.IntegerField(required=False, default=0)
    cans_in = serializers.IntegerField(required=False, default=0)
    plastic_wrappers_in = serializers.IntegerField(required=False, default=0)
    plastic_bags_in = serializers.IntegerField(required=False, default=0)
    batteries_in = serializers.IntegerField(required=False, default=0)
    gas_canisters_in = serializers.IntegerField(required=False, default=0)
    other_waste_details_in = serializers.CharField(required=False, allow_blank=True, default='')
    total_items_in = serializers.IntegerField(required=False, default=0)
    # Residuos salida
    exit_datetime = serializers.DateTimeField(required=False, allow_null=True)
    exit_ranger_name = serializers.CharField(required=False, allow_blank=True, default='')
    plastic_bottles_out = serializers.IntegerField(required=False, default=0)
    cans_out = serializers.IntegerField(required=False, default=0)
    plastic_wrappers_out = serializers.IntegerField(required=False, default=0)
    plastic_bags_out = serializers.IntegerField(required=False, default=0)
    batteries_out = serializers.IntegerField(required=False, default=0)
    gas_canisters_out = serializers.IntegerField(required=False, default=0)
    total_items_out = serializers.IntegerField(required=False, default=0)
    waste_compliance_status = serializers.CharField(required=False, default='pending_checkout')
    status = serializers.CharField(required=False, default='en_montana')
    notes = serializers.CharField(required=False, allow_blank=True, default='')


class CheckpointSyncBatchRequestSerializer(serializers.Serializer):
    entries = CheckpointSyncBatchItemSerializer(many=True)


class CheckpointSyncBatchResultSerializer(serializers.Serializer):
    local_uuid = serializers.CharField()
    server_uuid = serializers.CharField()
    status = serializers.CharField()
    action = serializers.CharField()  # 'created' or 'updated'


class CheckpointSyncBatchResponseSerializer(serializers.Serializer):
    processed = serializers.IntegerField()
    results = CheckpointSyncBatchResultSerializer(many=True)


class AnalyticsOverviewEngineSerializer(serializers.Serializer):
    rust_native_active = serializers.BooleanField()
    rust_version = serializers.CharField()


class AnalyticsOverviewTourismSerializer(serializers.Serializer):
    total_routes = serializers.IntegerField()
    total_distance_km = serializers.FloatField()
    total_360_scenes = serializers.IntegerField()
    total_pois = serializers.IntegerField()
    total_weather_stations = serializers.IntegerField()
    total_community_services = serializers.IntegerField()


class AnalyticsOverviewConservationSerializer(serializers.Serializer):
    total_species = serializers.IntegerField()
    total_reports = serializers.IntegerField()
    resolved_reports = serializers.IntegerField()
    pending_reports = serializers.IntegerField()
    resolution_rate_percent = serializers.FloatField()


class AnalyticsOverviewGamificationSerializer(serializers.Serializer):
    total_badges = serializers.IntegerField()
    total_passport_stamps = serializers.IntegerField()


class AnalyticsOverviewSerializer(serializers.Serializer):
    engine = AnalyticsOverviewEngineSerializer()
    tourism = AnalyticsOverviewTourismSerializer()
    conservation = AnalyticsOverviewConservationSerializer()
    gamification = AnalyticsOverviewGamificationSerializer()




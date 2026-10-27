from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from apps.accounts.serializers import UserSerializer
from .models import EnvironmentalReport, ReportEvidence
from apps.tourism.models import Route


class ReportEvidenceSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = ReportEvidence
        fields = ('id', 'image', 'image_url', 'created_at')
        read_only_fields = ('id', 'created_at')

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None


class EnvironmentalReportSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    category_display = serializers.CharField(source='get_category_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    route_name = serializers.CharField(source='route.name', read_only=True, allow_null=True)
    evidences = ReportEvidenceSerializer(many=True, read_only=True)

    class Meta:
        model = EnvironmentalReport
        fields = (
            'id',
            'uuid',
            'local_uuid',
            'user',
            'route',
            'route_name',
            'category',
            'category_display',
            'description',
            'latitude',
            'longitude',
            'accuracy_meters',
            'captured_at',
            'status',
            'status_display',
            'admin_notes',
            'synced_at',
            'created_at',
            'evidences',
        )
        read_only_fields = ('id', 'uuid', 'status', 'admin_notes', 'synced_at', 'created_at')


class EnvironmentalReportCreateSerializer(serializers.ModelSerializer):
    route_uuid = serializers.UUIDField(required=False, allow_null=True, write_only=True)

    class Meta:
        model = EnvironmentalReport
        fields = (
            'local_uuid',
            'route_uuid',
            'category',
            'description',
            'latitude',
            'longitude',
            'accuracy_meters',
            'captured_at',
        )

    def create(self, validated_data):
        route_uuid = validated_data.pop('route_uuid', None)
        if route_uuid:
            try:
                validated_data['route'] = Route.objects.get(uuid=route_uuid)
            except Route.DoesNotExist:
                pass

        user = self.context['request'].user if self.context['request'].user.is_authenticated else None
        validated_data['user'] = user

        # Idempotencia: Si ya existe local_uuid, retornarlo en lugar de crear duplicado
        local_uuid = validated_data.get('local_uuid')
        existing = EnvironmentalReport.objects.filter(local_uuid=local_uuid).first()
        if existing:
            return existing

        return super().create(validated_data)


class SyncBatchItemSerializer(serializers.Serializer):
    local_uuid = serializers.CharField(max_length=64)
    route_uuid = serializers.UUIDField(required=False, allow_null=True)
    category = serializers.ChoiceField(choices=EnvironmentalReport.Category.choices)
    description = serializers.CharField()
    latitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False, allow_null=True)
    longitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False, allow_null=True)
    accuracy_meters = serializers.FloatField(required=False, allow_null=True)
    captured_at = serializers.DateTimeField(required=False)


class SyncBatchRequestSerializer(serializers.Serializer):
    reports = SyncBatchItemSerializer(many=True)


class SyncBatchResultSerializer(serializers.Serializer):
    local_uuid = serializers.CharField()
    success = serializers.BooleanField()
    server_uuid = serializers.UUIDField(allow_null=True)
    status = serializers.CharField()
    message = serializers.CharField()


class SyncBatchResponseSerializer(serializers.Serializer):
    results = SyncBatchResultSerializer(many=True)


class AdminReportStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = EnvironmentalReport
        fields = ('status', 'admin_notes')

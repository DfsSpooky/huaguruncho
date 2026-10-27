from rest_framework import serializers
from .models import OfflinePackage


class OfflinePackageSerializer(serializers.ModelSerializer):
    route_uuid = serializers.UUIDField(source='route.uuid', read_only=True)
    package_uuid = serializers.UUIDField(source='uuid', read_only=True)
    manifest = serializers.JSONField(source='manifest_json', read_only=True)

    class Meta:
        model = OfflinePackage
        fields = (
            'package_uuid',
            'route_uuid',
            'version',
            'size_bytes',
            'is_published',
            'published_at',
            'manifest',
        )

from django.db import models
from django.utils import timezone
from apps.common.models import UUIDModel, TimeStampedModel
from apps.tourism.models import Route


class OfflinePackage(UUIDModel, TimeStampedModel):
    route = models.OneToOneField(
        Route,
        on_delete=models.CASCADE,
        related_name='offline_package',
        verbose_name='Ruta Turística'
    )
    version = models.PositiveIntegerField(
        default=1,
        verbose_name='Versión del Paquete'
    )
    manifest_json = models.JSONField(
        default=dict,
        verbose_name='Manifiesto de Contenido (JSON)'
    )
    size_bytes = models.BigIntegerField(
        default=0,
        verbose_name='Tamaño Total Estimado (Bytes)'
    )
    is_published = models.BooleanField(
        default=True,
        verbose_name='Publicado / Disponible para Descarga'
    )
    published_at = models.DateTimeField(
        default=timezone.now,
        verbose_name='Fecha de Publicación'
    )

    class Meta:
        verbose_name = 'Paquete de Contenido Offline'
        verbose_name_plural = 'Paquetes de Contenido Offline'
        ordering = ['-published_at']

    def __str__(self):
        return f"Paquete Offline: {self.route.name} (v{self.version})"

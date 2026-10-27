from django.db import models
from django.conf import settings
from django.utils import timezone
from apps.common.models import UUIDModel, TimeStampedModel
from apps.tourism.models import Route


class EnvironmentalReport(UUIDModel, TimeStampedModel):
    class Category(models.TextChoices):
        BASURA = 'basura', 'Acumulación de Basura / Residuos'
        INCENDIO = 'incendio', 'Foco de Incendio / Quema'
        ACCIDENTE = 'accidente', 'Accidente o Persona en Riesgo'
        SENALIZACION = 'senalizacion_danada', 'Señalización Turística Dañada'
        FLORA_FAUNA = 'flora_fauna_afectada', 'Flora o Fauna Afectada'
        OTRO = 'otro', 'Otro Incidente Ambiental'

    class Status(models.TextChoices):
        PENDIENTE = 'pendiente', 'Pendiente de Revisión'
        RECIBIDO = 'recibido', 'Recibido por Central'
        EN_REVISION = 'en_revision', 'En Inspección / Verificación'
        ATENDIDO = 'atendido', 'Atendido / Solucionado'
        CERRADO = 'cerrado', 'Cerrado'

    local_uuid = models.CharField(
        max_length=64,
        unique=True,
        db_index=True,
        verbose_name='UUID Local Móvil (Idempotencia)'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name='environmental_reports',
        verbose_name='Usuario Reportante'
    )
    route = models.ForeignKey(
        Route,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name='reports',
        verbose_name='Ruta Cercana'
    )
    category = models.CharField(
        max_length=30,
        choices=Category.choices,
        default=Category.BASURA,
        verbose_name='Categoría del Incidente',
        db_index=True
    )
    description = models.TextField(
        verbose_name='Descripción del Incidente'
    )
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name='Latitud GPS'
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name='Longitud GPS'
    )
    accuracy_meters = models.FloatField(
        blank=True,
        null=True,
        verbose_name='Precisión GPS (metros)'
    )
    captured_at = models.DateTimeField(
        default=timezone.now,
        verbose_name='Fecha y Hora de Captura Local',
        db_index=True
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.RECIBIDO,
        verbose_name='Estado del Reporte',
        db_index=True
    )
    admin_notes = models.TextField(
        blank=True,
        verbose_name='Notas de Atención / Autoridad'
    )
    synced_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name='Fecha de Sincronización con Servidor'
    )

    class Meta:
        verbose_name = 'Eco-Reporte Ambiental'
        verbose_name_plural = 'Eco-Reportes Ambientales'
        ordering = ['-captured_at']
        indexes = [
            models.Index(fields=['status', 'category']),
            models.Index(fields=['created_at']),
            models.Index(fields=['local_uuid']),
        ]

    def __str__(self):
        return f"Reporte #{self.id} [{self.get_category_display()}] - {self.get_status_display()}"


class ReportEvidence(models.Model):
    report = models.ForeignKey(
        EnvironmentalReport,
        on_delete=models.CASCADE,
        related_name='evidences',
        verbose_name='Reporte Asociado'
    )
    image = models.ImageField(
        upload_to='reports/evidences/%Y/%m/',
        verbose_name='Fotografía de Evidencia'
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name='Fecha de Carga'
    )

    class Meta:
        verbose_name = 'Evidencia Fotográfica'
        verbose_name_plural = 'Evidencias Fotográficas'
        ordering = ['-created_at']

    def __str__(self):
        return f"Evidencia para Reporte #{self.report_id}"

from django.contrib import admin
from django.utils.html import format_html
from .models import EnvironmentalReport, ReportEvidence


class ReportEvidenceInline(admin.TabularInline):
    model = ReportEvidence
    extra = 0
    readonly_fields = ('image_thumb', 'created_at')
    fields = ('image', 'image_thumb', 'created_at')

    @admin.display(description='Miniatura')
    def image_thumb(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="max-height: 80px; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.2);" />',
                obj.image.url
            )
        return "Sin imagen"


@admin.register(EnvironmentalReport)
class EnvironmentalReportAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'first_evidence_thumb',
        'category_badge',
        'status_badge',
        'user_display',
        'route',
        'map_link',
        'captured_at',
        'created_at'
    )
    list_filter = ('status', 'category', 'route', 'created_at', 'captured_at')
    search_fields = ('description', 'admin_notes', 'user__email', 'user__full_name', 'local_uuid')
    readonly_fields = ('uuid', 'local_uuid', 'synced_at', 'map_link_detail', 'created_at', 'updated_at')
    inlines = [ReportEvidenceInline]
    actions = ['marcar_en_revision', 'marcar_atendido', 'marcar_cerrado', 'marcar_recibido']

    fieldsets = (
        ('Detalle del Incidente Ambiental', {
            'fields': (
                ('category', 'status'),
                ('user', 'route'),
                'description',
                'admin_notes',
            )
        }),
        ('Geolocalización GPS y Registro Móvil', {
            'fields': (
                ('latitude', 'longitude', 'accuracy_meters'),
                'map_link_detail',
                ('captured_at', 'synced_at'),
            )
        }),
        ('Identificadores de Auditoría e Idempotencia', {
            'classes': ('collapse',),
            'fields': ('uuid', 'local_uuid', 'created_at', 'updated_at')
        }),
    )

    @admin.display(description='Evidencia')
    def first_evidence_thumb(self, obj):
        first_ev = obj.evidences.first()
        if first_ev and first_ev.image:
            return format_html(
                '<img src="{}" style="width: 48px; height: 48px; object-fit: cover; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.15); border: 1px solid rgba(0,0,0,0.08);" />',
                first_ev.image.url
            )
        return format_html('<span class="hp-thumb-empty" title="Sin fotografía de evidencia">📷</span>')

    @admin.display(description='Categoría')
    def category_badge(self, obj):
        config = {
            EnvironmentalReport.Category.BASURA: ('#FEE2E2', '#991B1B', '🗑️'),
            EnvironmentalReport.Category.INCENDIO: ('#FEE2E2', '#DC2626', '🔥'),
            EnvironmentalReport.Category.ACCIDENTE: ('#FFEDD5', '#C2410C', '🚨'),
            EnvironmentalReport.Category.SENALIZACION: ('#FEF3C7', '#B45309', '🪧'),
            EnvironmentalReport.Category.FLORA_FAUNA: ('#DCFCE7', '#15803D', '🌿'),
            EnvironmentalReport.Category.OTRO: ('#F1F5F9', '#475569', 'ℹ️'),
        }
        bg, fg, icon = config.get(obj.category, ('#F1F5F9', '#475569', '📋'))
        return format_html(
            '<span class="hp-badge" style="background: {}; color: {};">{} {}</span>',
            bg, fg, icon, obj.get_category_display()
        )

    @admin.display(description='Estado')
    def status_badge(self, obj):
        config = {
            EnvironmentalReport.Status.PENDIENTE: ('#F1F5F9', '#475569', '⏳'),
            EnvironmentalReport.Status.RECIBIDO: ('#E0F7FA', '#00838F', '📥'),
            EnvironmentalReport.Status.EN_REVISION: ('#FEF3C7', '#B45309', '🔍'),
            EnvironmentalReport.Status.ATENDIDO: ('#DCFCE7', '#15803D', '✅'),
            EnvironmentalReport.Status.CERRADO: ('#E2E8F0', '#334155', '🔒'),
        }
        bg, fg, icon = config.get(obj.status, ('#F1F5F9', '#475569', '•'))
        return format_html(
            '<span class="hp-badge" style="background: {}; color: {};">{} {}</span>',
            bg, fg, icon, obj.get_status_display()
        )

    @admin.display(description='Reportante')
    def user_display(self, obj):
        if obj.user:
            return f"{obj.user.full_name} ({obj.user.email})"
        return "Anónimo / Modo Offline"

    @admin.display(description='Ubicación GPS')
    def map_link(self, obj):
        if obj.latitude and obj.longitude:
            return format_html(
                '<a href="https://www.google.com/maps?q={},{}"" target="_blank" style="color: #1976D2; font-weight: 600; text-decoration: none;">📍 Ver Mapa</a>',
                obj.latitude, obj.longitude
            )
        return format_html('<span style="color: #999;">Sin GPS</span>')

    @admin.display(description='Ubicación en Mapa Satelital')
    def map_link_detail(self, obj):
        if obj.latitude and obj.longitude:
            return format_html(
                '<a href="https://www.google.com/maps?q={},{}"" target="_blank" class="button" style="background: #1976D2; color: #fff; padding: 6px 12px; border-radius: 4px; text-decoration: none;">🗺️ Abrir Coordenadas en Google Maps ({}, {})</a>',
                obj.latitude, obj.longitude, obj.latitude, obj.longitude
            )
        return "Sin coordenadas GPS registradas"

    @admin.action(description='Cambiar estado a: Recibido por Central')
    def marcar_recibido(self, request, queryset):
        count = queryset.update(status=EnvironmentalReport.Status.RECIBIDO)
        self.message_user(request, f"Se actualizaron {count} reportes a estado RECIBIDO.")

    @admin.action(description='Cambiar estado a: En Inspección / Revisión')
    def marcar_en_revision(self, request, queryset):
        count = queryset.update(status=EnvironmentalReport.Status.EN_REVISION)
        self.message_user(request, f"Se actualizaron {count} reportes a estado EN REVISIÓN.")

    @admin.action(description='Cambiar estado a: Atendido / Solucionado')
    def marcar_atendido(self, request, queryset):
        count = queryset.update(status=EnvironmentalReport.Status.ATENDIDO)
        self.message_user(request, f"Se actualizaron {count} reportes a estado ATENDIDO.")

    @admin.action(description='Cambiar estado a: Cerrado')
    def marcar_cerrado(self, request, queryset):
        count = queryset.update(status=EnvironmentalReport.Status.CERRADO)
        self.message_user(request, f"Se cerraron {count} reportes.")


@admin.register(ReportEvidence)
class ReportEvidenceAdmin(admin.ModelAdmin):
    list_display = ('id', 'evidence_preview', 'report_link', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('report__description', 'report__user__email', 'report__user__full_name')
    readonly_fields = ('evidence_preview_large', 'created_at')

    @admin.display(description='Foto')
    def evidence_preview(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 6px;" />',
                obj.image.url
            )
        return "Sin foto"

    @admin.display(description='Vista Previa')
    def evidence_preview_large(self, obj):
        if obj.image:
            return format_html('<img src="{}" style="max-height: 300px; border-radius: 8px;" />', obj.image.url)
        return "Sin fotografía adjunta"

    @admin.display(description='Reporte Asociado')
    def report_link(self, obj):
        return f"Reporte #{obj.report.id} - {obj.report.get_category_display()}"

from django.contrib import admin
from django.utils.html import format_html
from .models import OfflinePackage
from .services import update_or_create_offline_package


@admin.register(OfflinePackage)
class OfflinePackageAdmin(admin.ModelAdmin):
    list_display = ('route', 'version_display', 'formatted_size', 'status_badge', 'published_at', 'updated_at')
    list_filter = ('is_published', 'published_at')
    search_fields = ('route__name',)
    readonly_fields = ('uuid', 'formatted_size', 'created_at', 'updated_at')
    actions = ['regenerar_manifiesto', 'publicar_paquetes', 'despublicar_paquetes']

    @admin.display(description='Versión')
    def version_display(self, obj):
        return format_html('<span style="font-weight: 700; color: #1565C0;">v{}</span>', obj.version)

    @admin.display(description='Tamaño Estimado')
    def formatted_size(self, obj):
        bytes_val = obj.size_bytes or 0
        if bytes_val >= 1024 * 1024:
            return f"{bytes_val / (1024 * 1024):.2f} MB"
        elif bytes_val >= 1024:
            return f"{bytes_val / 1024:.1f} KB"
        return f"{bytes_val} Bytes"

    @admin.display(description='Estado')
    def status_badge(self, obj):
        if obj.is_published:
            return format_html('<span style="background: #2E7D32; color: #fff; padding: 3px 8px; border-radius: 10px; font-size: 11px; font-weight: 600;">Publicado</span>')
        return format_html('<span style="background: #757575; color: #fff; padding: 3px 8px; border-radius: 10px; font-size: 11px;">Borrador</span>')

    @admin.action(description='Regenerar manifiesto y subir versión')
    def regenerar_manifiesto(self, request, queryset):
        for pkg in queryset:
            update_or_create_offline_package(pkg.route, request)
        self.message_user(request, f"Se regeneraron con éxito {queryset.count()} paquetes offline.")

    @admin.action(description='Publicar paquetes seleccionados')
    def publicar_paquetes(self, request, queryset):
        queryset.update(is_published=True)

    @admin.action(description='Despublicar paquetes seleccionados')
    def despublicar_paquetes(self, request, queryset):
        queryset.update(is_published=False)

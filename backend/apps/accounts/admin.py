from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.html import format_html
from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('email', 'full_name', 'role_badge', 'whatsapp_link', 'is_active', 'is_staff', 'date_joined')
    list_filter = ('role', 'is_active', 'is_staff', 'date_joined')
    search_fields = ('email', 'full_name', 'phone')
    ordering = ('-date_joined',)
    actions = ['marcar_como_guia', 'marcar_como_municipalidad', 'activar_usuarios', 'desactivar_usuarios']

    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Información Personal', {'fields': ('full_name', 'phone', 'role', 'whatsapp_detail_link')}),
        ('Permisos', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Fechas Importantes', {'fields': ('date_joined', 'updated_at')}),
    )

    readonly_fields = ('date_joined', 'updated_at', 'whatsapp_detail_link')

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'full_name', 'phone', 'role', 'password', 'is_staff', 'is_active'),
        }),
    )

    @admin.display(description='Rol')
    def role_badge(self, obj):
        colors = {
            User.Role.ADMINISTRADOR: '#4A148C',   # Deep purple
            User.Role.MUNICIPALIDAD: '#0D47A1',   # Navy blue
            User.Role.GUIA: '#1B5E20',           # Forest green
            User.Role.TURISTA: '#455A64',        # Slate grey
        }
        color = colors.get(obj.role, '#666')
        return format_html(
            '<span style="background-color: {}; color: #fff; padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600;">{}</span>',
            color,
            obj.get_role_display()
        )

    @admin.display(description='WhatsApp')
    def whatsapp_link(self, obj):
        if obj.phone:
            clean = obj.phone.replace(' ', '').replace('+', '').replace('-', '')
            return format_html(
                '<a href="https://wa.me/{}" target="_blank" style="color: #2E7D32; font-weight: 600; text-decoration: none;">💬 {}</a>',
                clean, obj.phone
            )
        return format_html('<span style="color: #999;">-</span>')

    @admin.display(description='Enlace Directo WhatsApp')
    def whatsapp_detail_link(self, obj):
        if obj.phone:
            clean = obj.phone.replace(' ', '').replace('+', '').replace('-', '')
            return format_html(
                '<a href="https://wa.me/{}" target="_blank" class="button" style="background: #2E7D32; color: #fff; padding: 5px 10px; border-radius: 4px; text-decoration: none;">💬 Abrir Chat con {}</a>',
                clean, obj.full_name
            )
        return "Sin teléfono registrado"

    @admin.action(description='Asignar Rol: Guía Autorizado')
    def marcar_como_guia(self, request, queryset):
        count = queryset.update(role=User.Role.GUIA)
        self.message_user(request, f"Se asignó rol de Guía Autorizado a {count} usuarios.")

    @admin.action(description='Asignar Rol: Personal Municipal / Guardaparque')
    def marcar_como_municipalidad(self, request, queryset):
        count = queryset.update(role=User.Role.MUNICIPALIDAD, is_staff=True)
        self.message_user(request, f"Se asignó rol Municipal/Guardaparque a {count} usuarios con acceso staff.")

    @admin.action(description='Activar usuarios seleccionados')
    def activar_usuarios(self, request, queryset):
        count = queryset.update(is_active=True)
        self.message_user(request, f"Se activaron {count} usuarios.")

    @admin.action(description='Desactivar usuarios seleccionados')
    def desactivar_usuarios(self, request, queryset):
        count = queryset.update(is_active=False)
        self.message_user(request, f"Se desactivaron {count} usuarios.")

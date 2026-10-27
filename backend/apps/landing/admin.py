from django.contrib import admin
from django.utils.html import mark_safe
from .models import (
    LandingHeroConfig,
    LandingMetric,
    LandingFeature,
    LandingWaypoint,
    LandingExperience,
    LandingFAQ,
    LandingAudioGuide
)


@admin.register(LandingHeroConfig)
class LandingHeroConfigAdmin(admin.ModelAdmin):
    list_display = (
        'title_line_1',
        'title_line_2',
        'apk_version',
        'enable_snow_effect',
        'is_active',
        'preview_background',
        'updated_at'
    )
    list_editable = ('is_active', 'enable_snow_effect')
    fieldsets = (
        ('1. Encabezado Principal & Textos Hero', {
            'fields': (
                'title_line_1',
                'title_line_2',
                'subtitle',
                'season_badge',
            )
        }),
        ('2. Imagen de Fondo del Nevado & Efectos', {
            'fields': (
                'hero_background_image',
                'enable_snow_effect',
            )
        }),
        ('3. Tiendas de Aplicaciones & Descargas', {
            'fields': (
                'app_store_url',
                'google_play_url',
                'ios_testflight_url',
                'apk_file',
                'apk_version',
                'apk_size_mb',
                'qr_code_image',
            )
        }),
        ('4. Control de Publicación', {
            'fields': ('is_active',)
        }),
    )

    def preview_background(self, obj):
        if obj.hero_background_image:
            return mark_safe(f'<img src="{obj.hero_background_image.url}" style="width: 80px; height: 45px; object-fit: cover; border-radius: 6px;" />')
        return "Por defecto"
    preview_background.short_description = "Fondo Nevado"


@admin.register(LandingMetric)
class LandingMetricAdmin(admin.ModelAdmin):
    list_display = ('value', 'label', 'color_class', 'order', 'is_active')
    list_editable = ('order', 'is_active', 'color_class')
    search_fields = ('value', 'label')


@admin.register(LandingFeature)
class LandingFeatureAdmin(admin.ModelAdmin):
    list_display = ('title', 'icon_name', 'icon_color', 'badge_text', 'order', 'is_active')
    list_editable = ('order', 'is_active')
    search_fields = ('title', 'description', 'badge_text')


@admin.register(LandingWaypoint)
class LandingWaypointAdmin(admin.ModelAdmin):
    list_display = ('name', 'altitude_m', 'distance_km', 'description', 'badge_color', 'order')
    list_editable = ('order', 'altitude_m', 'distance_km', 'badge_color')
    search_fields = ('name', 'description')


@admin.register(LandingExperience)
class LandingExperienceAdmin(admin.ModelAdmin):
    list_display = ('icon_or_emoji', 'title', 'highlight_tag', 'order', 'is_active')
    list_editable = ('order', 'is_active')
    search_fields = ('title', 'description')


@admin.register(LandingFAQ)
class LandingFAQAdmin(admin.ModelAdmin):
    list_display = ('question', 'order', 'is_active')
    list_editable = ('order', 'is_active')
    search_fields = ('question', 'answer')


@admin.register(LandingAudioGuide)
class LandingAudioGuideAdmin(admin.ModelAdmin):
    list_display = ('title', 'narrator', 'languages', 'duration_text', 'is_active')
    list_editable = ('is_active',)
    search_fields = ('title', 'narrator', 'transcript')

import json
from django.core.serializers.json import DjangoJSONEncoder
from django.contrib import admin
from django.http import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404, render
from django.urls import path, reverse
from django.utils.html import format_html
from apps.tourism.utils.gpx_parser import parse_gpx_content
from .serializers import TourSceneSerializer, PointOfInterestSerializer
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


class HotspotInline(admin.TabularInline):
    model = Hotspot
    fk_name = 'source_scene'
    extra = 1
    fields = ('title', 'type', 'yaw', 'pitch', 'target_scene', 'icon')


class TourSceneInline(admin.TabularInline):
    model = TourScene
    extra = 1
    fields = ('sequence', 'title', 'latitude', 'longitude', 'is_active')
    show_change_link = True


class PointOfInterestInline(admin.TabularInline):
    model = PointOfInterest
    extra = 1
    fields = ('name', 'category', 'altitude_masl', 'order', 'is_active')
    show_change_link = True


@admin.register(Route)
class RouteAdmin(admin.ModelAdmin):
    list_display = (
        'cover_preview',
        'name',
        'difficulty_badge',
        'distance_km',
        'scenes_count',
        'studio_action',
        'is_active',
        'created_at'
    )
    list_display_links = ('cover_preview', 'name')
    list_filter = ('difficulty', 'is_active', 'created_at')
    search_fields = ('name', 'description', 'safety_recommendations')
    prepopulated_fields = {'slug': ('name',)}
    inlines = [TourSceneInline, PointOfInterestInline]
    readonly_fields = ('uuid', 'cover_preview_large', 'studio_action_large', 'created_at', 'updated_at')
    actions = ['activar_rutas', 'desactivar_rutas']

    fieldsets = (
        ('Identificación y Generalidades', {
            'fields': ('name', 'slug', 'description', 'cover_image', 'cover_preview_large', 'studio_action_large', 'is_active')
        }),
        ('Métricas de Trekking & Wikiloc GPX', {
            'fields': (
                'difficulty',
                'distance_km',
                'estimated_duration_minutes',
                'gpx_file',
                'elevation_gain_m',
                'elevation_loss_m',
                'max_altitude_m',
                'min_altitude_m',
                'safety_recommendations'
            )
        }),
        ('Datos GeoJSON & Perfil Altimétrico', {
            'classes': ('collapse',),
            'fields': ('geojson_track', 'elevation_profile')
        }),
        ('Auditoría', {
            'classes': ('collapse',),
            'fields': ('uuid', 'created_at', 'updated_at')
        }),
    )

    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path('<path:object_id>/studio/', self.admin_site.admin_view(self.studio_view), name='tourism_route_studio'),
            path('<path:object_id>/export-pdf/', self.admin_site.admin_view(self.export_pdf_view), name='tourism_route_export_pdf'),
            path('<path:object_id>/studio/scenes/', self.admin_site.admin_view(self.scenes_partial_view), name='tourism_route_scenes_partial'),
            path('<path:object_id>/studio/scene-inspector/<uuid:scene_uuid>/', self.admin_site.admin_view(self.scene_inspector_view), name='tourism_route_scene_inspector'),
            path('<path:object_id>/studio/update-scene/<uuid:scene_uuid>/', self.admin_site.admin_view(self.update_scene_view), name='tourism_route_update_scene'),
            path('<path:object_id>/studio/delete-scene/<uuid:scene_uuid>/', self.admin_site.admin_view(self.delete_scene_view), name='tourism_route_delete_scene'),
            path('<path:object_id>/studio/delete-hotspot/<int:hotspot_id>/', self.admin_site.admin_view(self.delete_hotspot_view), name='tourism_route_delete_hotspot'),
            path('<path:object_id>/studio/create-scene/', self.admin_site.admin_view(self.create_scene_view), name='tourism_route_create_scene'),
            path('<path:object_id>/studio/create-hotspot/', self.admin_site.admin_view(self.create_hotspot_view), name='tourism_route_create_hotspot'),
            path('<path:object_id>/studio/auto-link/', self.admin_site.admin_view(self.auto_link_htmx_view), name='tourism_route_auto_link'),
            path('<path:object_id>/studio/generate-trail-nodes/', self.admin_site.admin_view(self.generate_trail_nodes_htmx_view), name='tourism_route_generate_trail_nodes'),
            path('<path:object_id>/studio/upload-gpx/', self.admin_site.admin_view(self.upload_gpx_htmx_view), name='tourism_route_upload_gpx_htmx'),
        ]
        return custom_urls + urls

    def export_pdf_view(self, request, object_id):
        from apps.tourism.utils.pdf_generator import generate_route_technical_pdf
        route = get_object_or_404(Route, pk=object_id)
        pdf_buffer = generate_route_technical_pdf(route)
        filename = f"ficha_tecnica_{route.slug or 'huaguruncho'}.pdf"

        response = HttpResponse(pdf_buffer.getvalue(), content_type='application/pdf')
        response['Content-Disposition'] = f'inline; filename="{filename}"'
        return response

    def studio_view(self, request, object_id):
        route = get_object_or_404(Route, pk=object_id)
        scenes = route.scenes.all().order_by('sequence').prefetch_related('hotspots')
        scenes_data = TourSceneSerializer(scenes, many=True, context={'request': request}).data
        pois = route.points_of_interest.all()
        pois_data = PointOfInterestSerializer(pois, many=True, context={'request': request}).data

        context = {
            **self.admin_site.each_context(request),
            'title': f'Tour 360 Studio: {route.name}',
            'route': route,
            'scenes': scenes,
            'scenes_json': json.dumps(scenes_data, cls=DjangoJSONEncoder),
            'pois_json': json.dumps(pois_data, cls=DjangoJSONEncoder),
            'geojson_track_json': json.dumps(route.geojson_track, cls=DjangoJSONEncoder) if route.geojson_track else 'null',
            'elevation_profile_json': json.dumps(route.elevation_profile, cls=DjangoJSONEncoder) if route.elevation_profile else '[]',
        }
        return render(request, 'admin/tourism/route/studio.html', context)

    def scenes_partial_view(self, request, object_id):
        route = get_object_or_404(Route, pk=object_id)
        scenes = route.scenes.all().order_by('sequence').prefetch_related('hotspots')
        return render(request, 'admin/tourism/route/partials/scenes_list.html', {
            'route': route,
            'scenes': scenes,
        })

    def scene_inspector_view(self, request, object_id, scene_uuid):
        route = get_object_or_404(Route, pk=object_id)
        scene = get_object_or_404(TourScene, uuid=scene_uuid, route=route)
        return render(request, 'admin/tourism/route/partials/scene_inspector.html', {
            'route': route,
            'scene': scene,
        })

    def update_scene_view(self, request, object_id, scene_uuid):
        route = get_object_or_404(Route, pk=object_id)
        scene = get_object_or_404(TourScene, uuid=scene_uuid, route=route)

        if request.method == 'POST':
            title = request.POST.get('title')
            lat = request.POST.get('latitude')
            lng = request.POST.get('longitude')
            alt = request.POST.get('altitude_masl')
            head = request.POST.get('heading')
            init_yaw = request.POST.get('initial_yaw')
            init_pitch = request.POST.get('initial_pitch')
            desc = request.POST.get('description', '')

            if title and title.strip():
                scene.title = title.strip()
            
            # Normalizar separadores decimales (soporte para comas de localización española)
            if lat:
                lat = str(lat).replace(',', '.').strip()
            if lng:
                lng = str(lng).replace(',', '.').strip()
            if alt:
                alt = str(alt).replace(',', '.').strip()
            if head:
                head = str(head).replace(',', '.').strip()
            if init_yaw:
                init_yaw = str(init_yaw).replace(',', '.').strip()
            if init_pitch:
                init_pitch = str(init_pitch).replace(',', '.').strip()

            scene.latitude = lat if lat else None
            scene.longitude = lng if lng else None
            try:
                scene.altitude_masl = int(float(alt)) if alt and str(alt).strip() != '' else None
            except (ValueError, TypeError):
                scene.altitude_masl = None
            try:
                scene.heading = float(head) if head and str(head).strip() != '' else 0.0
            except (ValueError, TypeError):
                scene.heading = 0.0
            if init_yaw is not None and str(init_yaw).strip() != '':
                try:
                    scene.initial_yaw = float(init_yaw)
                except (ValueError, TypeError):
                    pass
            if init_pitch is not None and str(init_pitch).strip() != '':
                try:
                    scene.initial_pitch = float(init_pitch)
                except (ValueError, TypeError):
                    pass
            scene.description = desc
            pano_file = request.FILES.get('panorama_image')
            if pano_file:
                scene.panorama_image = pano_file
            scene.save()

        return render(request, 'admin/tourism/route/partials/scene_inspector.html', {
            'route': route,
            'scene': scene,
            'updated': True,
        })

    def delete_scene_view(self, request, object_id, scene_uuid):
        route = get_object_or_404(Route, pk=object_id)
        scene = get_object_or_404(TourScene, uuid=scene_uuid, route=route)
        scene.delete()
        # Re-indexar secuencias ordenadas de los hitos restantes
        for idx, s in enumerate(route.scenes.all().order_by('sequence', 'created_at'), start=1):
            if s.sequence != idx:
                s.sequence = idx
                s.save(update_fields=['sequence'])
        return HttpResponse("", status=200)

    def delete_hotspot_view(self, request, object_id, hotspot_id):
        hotspot = get_object_or_404(Hotspot, pk=hotspot_id)
        hotspot.delete()
        return HttpResponse("", status=200)

    def auto_link_htmx_view(self, request, object_id):
        route = get_object_or_404(Route, pk=object_id)
        scenes = list(route.scenes.filter(is_active=True).order_by('sequence'))

        for i in range(len(scenes) - 1):
            curr_scene = scenes[i]
            next_scene = scenes[i + 1]
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

        updated_scenes = route.scenes.all().order_by('sequence').prefetch_related('hotspots')
        return render(request, 'admin/tourism/route/partials/scenes_list.html', {
            'route': route,
            'scenes': updated_scenes,
        })

    def generate_trail_nodes_htmx_view(self, request, object_id):
        route = get_object_or_404(Route, pk=object_id)
        track = route.geojson_track
        if track and 'geometry' in track and track['geometry'].get('coordinates'):
            coords = track['geometry']['coordinates']
            total_pts = len(coords)
            if total_pts > 0:
                num_nodes = min(6, total_pts)
                step = max(1, total_pts // (num_nodes - 1)) if num_nodes > 1 else 1
                sample_indices = [min(i * step, total_pts - 1) for i in range(num_nodes)]
                if (total_pts - 1) not in sample_indices:
                    sample_indices[-1] = total_pts - 1

                names = [
                    f"Punto de Partida ({route.min_altitude_m or 3400}m)",
                    "Tramo Inicial de Sendero",
                    "Quebrada & Zona de Descanso",
                    "Pampa Altoandina & Rodales",
                    "Laguna Glaciar / Campamento",
                    f"Mirador Cumbre ({route.max_altitude_m or 4680}m)",
                ]

                created_scenes = []
                for seq, idx in enumerate(sample_indices, start=1):
                    pt = coords[idx]
                    lng = pt[0]
                    lat = pt[1]
                    alt = int(pt[2]) if len(pt) > 2 else int((route.min_altitude_m or 3400) + (seq - 1) * (route.elevation_gain_m or 500) / max(1, len(sample_indices) - 1))

                    title = names[seq - 1] if seq - 1 < len(names) else f"Hito de Sendero {seq}"
                    scene, _ = TourScene.objects.update_or_create(
                        route=route,
                        sequence=seq,
                        defaults={
                            'title': title,
                            'latitude': lat,
                            'longitude': lng,
                            'altitude_masl': alt,
                            'heading': 0.0,
                            'is_active': True,
                        }
                    )
                    created_scenes.append(scene)

                # Auto-enlazar en cadena Street View
                for i in range(len(created_scenes) - 1):
                    curr = created_scenes[i]
                    nxt = created_scenes[i + 1]
                    Hotspot.objects.update_or_create(
                        source_scene=curr,
                        target_scene=nxt,
                        defaults={
                            'type': Hotspot.HotspotType.NAVIGATION,
                            'title': f"Avanzar hacia {nxt.title}",
                            'yaw': 0.0,
                            'pitch': -10.0,
                            'icon': 'arrow_forward',
                        }
                    )
                    Hotspot.objects.update_or_create(
                        source_scene=nxt,
                        target_scene=curr,
                        defaults={
                            'type': Hotspot.HotspotType.NAVIGATION,
                            'title': f"Retroceder hacia {curr.title}",
                            'yaw': 180.0,
                            'pitch': -10.0,
                            'icon': 'arrow_back',
                        }
                    )

        updated_scenes = route.scenes.all().order_by('sequence').prefetch_related('hotspots')
        return render(request, 'admin/tourism/route/partials/scenes_list.html', {
            'route': route,
            'scenes': updated_scenes,
        })

    def upload_gpx_htmx_view(self, request, object_id):
        route = get_object_or_404(Route, pk=object_id)
        gpx_file = request.FILES.get('gpx_file')
        import_waypoints = request.POST.get('import_waypoints') in ['on', 'true', True] or True

        if gpx_file:
            raw_text = gpx_file.read().decode('utf-8', errors='ignore')
            res = parse_gpx_content(raw_text)
            if res.get('success'):
                route.gpx_file = gpx_file
                route.geojson_track = res.get('geojson_track')
                route.elevation_profile = res.get('elevation_profile')
                route.elevation_gain_m = res.get('elevation_gain_m', 0.0)
                route.elevation_loss_m = res.get('elevation_loss_m', 0.0)
                route.max_altitude_m = int(res.get('max_altitude_m', 0))
                route.min_altitude_m = int(res.get('min_altitude_m', 0))
                if res.get('total_distance_km'):
                    route.distance_km = res.get('total_distance_km')
                if res.get('estimated_duration_minutes'):
                    route.estimated_duration_minutes = res.get('estimated_duration_minutes')
                if not route.difficulty and res.get('difficulty'):
                    route.difficulty = str(res.get('difficulty')).lower()
                route.save()

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

                if route.scenes.count() == 0:
                    return self.generate_trail_nodes_htmx_view(request, object_id)

        scenes = route.scenes.all().order_by('sequence').prefetch_related('hotspots')
        return render(request, 'admin/tourism/route/partials/scenes_list.html', {
            'route': route,
            'scenes': scenes,
        })

    def create_scene_view(self, request, object_id):
        route = get_object_or_404(Route, pk=object_id)
        title = request.POST.get('title', 'Punto 360')
        sequence = int(request.POST.get('sequence', route.scenes.count() + 1))
        lat = request.POST.get('latitude') or None
        lng = request.POST.get('longitude') or None
        alt = request.POST.get('altitude_masl') or None
        desc = request.POST.get('description', '')
        pano_file = request.FILES.get('panorama_image')

        alt_val = None
        if alt and str(alt).strip():
            try:
                alt_val = int(float(alt))
            except (ValueError, TypeError):
                alt_val = None

        TourScene.objects.create(
            route=route,
            title=title,
            sequence=sequence,
            latitude=lat,
            longitude=lng,
            altitude_masl=alt_val,
            description=desc,
            panorama_image=pano_file if pano_file else 'panoramas/default_sample.jpg'
        )

        scenes = route.scenes.all().order_by('sequence').prefetch_related('hotspots')
        return render(request, 'admin/tourism/route/partials/scenes_list.html', {
            'route': route,
            'scenes': scenes,
        })

    def create_hotspot_view(self, request, object_id):
        source_uuid = request.POST.get('source_scene_uuid')
        target_uuid = request.POST.get('target_scene_uuid')
        h_type = request.POST.get('type', Hotspot.HotspotType.NAVIGATION)
        title = request.POST.get('title', 'Punto de Interés')
        content = request.POST.get('content', '')
        yaw = float(request.POST.get('yaw', 0.0))
        pitch = float(request.POST.get('pitch', 0.0))
        target_yaw = float(request.POST.get('target_yaw', 0.0))
        target_pitch = float(request.POST.get('target_pitch', 0.0))
        media_image = request.FILES.get('media_image')
        audio_url = request.POST.get('audio_url', '')

        route = get_object_or_404(Route, pk=object_id)
        source_scene = get_object_or_404(TourScene, uuid=source_uuid)
        target_scene = TourScene.objects.filter(uuid=target_uuid).first() if target_uuid else None

        icon_map = {
            Hotspot.HotspotType.NAVIGATION: 'arrow_forward',
            Hotspot.HotspotType.PHOTO_POI: 'photo_camera',
            Hotspot.HotspotType.AUDIO_GUIDE: 'headphones',
            Hotspot.HotspotType.WARNING: 'warning',
            Hotspot.HotspotType.INFORMATION: 'info',
        }

        Hotspot.objects.create(
            source_scene=source_scene,
            target_scene=target_scene,
            type=h_type,
            title=title,
            content=content,
            yaw=yaw,
            pitch=pitch,
            target_yaw=target_yaw,
            target_pitch=target_pitch,
            media_image=media_image,
            audio_url=audio_url,
            icon=icon_map.get(h_type, 'info')
        )

        return render(request, 'admin/tourism/route/partials/scene_inspector.html', {
            'route': route,
            'scene': source_scene,
            'updated': True,
        })

    @admin.display(description='Studio 360°')
    def studio_action(self, obj):
        url = reverse('admin:tourism_route_studio', args=[obj.pk])
        return format_html(
            '<a class="hp-badge" style="background: #00838F; color: #FFFFFF; font-weight: 700; text-decoration: none; padding: 5px 12px; gap: 5px;" href="{}">🗺️ Studio 360° &rarr;</a>',
            url
        )

    @admin.display(description='Acceso al Studio 360°')
    def studio_action_large(self, obj):
        if obj.pk:
            url = reverse('admin:tourism_route_studio', args=[obj.pk])
            return format_html(
                '<div style="margin: 8px 0;"><a class="button" style="background: linear-gradient(135deg, #0A2540 0%, #00838F 100%); color:#ffffff; font-weight:800; font-size:13px; padding:10px 18px; border-radius:8px; text-decoration:none; display:inline-flex; align-items:center; gap:8px;" href="{}">🗺️ Abrir Tour 360 Studio Interactivo &rarr;</a></div>',
                url
            )
        return "Guarda la ruta para habilitar el Studio"

    @admin.display(description='Portada')
    def cover_preview(self, obj):
        if obj.cover_image:
            return format_html(
                '<img src="{}" style="width: 54px; height: 38px; object-fit: cover; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.15); border: 1px solid rgba(0,0,0,0.08);" />',
                obj.cover_image.url
            )
        return format_html('<span class="hp-thumb-empty" title="Sin imagen de portada">🏔️</span>')

    @admin.display(description='Vista Previa de Portada')
    def cover_preview_large(self, obj):
        if obj.cover_image:
            return format_html(
                '<img src="{}" style="max-height: 220px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.15);" />',
                obj.cover_image.url
            )
        return "Sin imagen cargada"

    @admin.display(description='Dificultad')
    def difficulty_badge(self, obj):
        config = {
            Route.Difficulty.FACIL: ('#DCFCE7', '#15803D', '🟢'),
            Route.Difficulty.MODERADA: ('#FEF3C7', '#B45309', '🟡'),
            Route.Difficulty.DIFICIL: ('#FEE2E2', '#B91C1C', '🔴'),
            Route.Difficulty.EXPERTO: ('#F3E8FF', '#7E22CE', '🟣'),
        }
        diff_key = (obj.difficulty or '').lower()
        bg, fg, icon = config.get(diff_key, ('#F1F5F9', '#475569', '⚪'))
        return format_html(
            '<span class="hp-badge" style="background: {}; color: {};">{} {}</span>',
            bg, fg, icon, obj.get_difficulty_display()
        )

    @admin.display(description='Escenas 360°')
    def scenes_count(self, obj):
        return obj.scenes.count()

    @admin.action(description='Activar rutas seleccionadas')
    def activar_rutas(self, request, queryset):
        count = queryset.update(is_active=True)
        self.message_user(request, f"Se activaron {count} rutas con éxito.")

    @admin.action(description='Desactivar rutas seleccionadas')
    def desactivar_rutas(self, request, queryset):
        count = queryset.update(is_active=False)
        self.message_user(request, f"Se desactivaron {count} rutas.")


@admin.register(TourScene)
class TourSceneAdmin(admin.ModelAdmin):
    list_display = (
        'panorama_preview',
        'title',
        'route',
        'sequence',
        'map_link',
        'hotspots_count',
        'is_active'
    )
    list_filter = ('route', 'is_active')
    search_fields = ('title', 'description', 'route__name')
    inlines = [HotspotInline]
    readonly_fields = ('uuid', 'panorama_preview_large', 'map_link_detail', 'created_at', 'updated_at')
    actions = ['activar_escenas', 'desactivar_escenas']

    fieldsets = (
        ('Ubicación en Ruta y Título', {
            'fields': ('route', 'sequence', 'title', 'description', 'is_active')
        }),
        ('Contenido Multimedia 360°', {
            'fields': ('panorama_image', 'thumbnail', 'panorama_preview_large')
        }),
        ('Georreferenciación GPS', {
            'fields': (('latitude', 'longitude'), 'map_link_detail')
        }),
        ('Auditoría', {
            'classes': ('collapse',),
            'fields': ('uuid', 'created_at', 'updated_at')
        }),
    )

    @admin.display(description='Miniatura 360°')
    def panorama_preview(self, obj):
        img_field = obj.thumbnail or obj.panorama_image
        if img_field:
            return format_html(
                '<img src="{}" style="width: 60px; height: 35px; object-fit: cover; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.2);" />',
                img_field.url
            )
        return format_html('<span style="color: #999; font-size: 11px;">Sin imagen</span>')

    @admin.display(description='Vista Panorámica')
    def panorama_preview_large(self, obj):
        if obj.panorama_image:
            return format_html(
                '<div style="margin: 10px 0;"><img src="{}" style="max-height: 240px; max-width: 100%; border-radius: 8px; border: 1px solid #ddd;" /><br><small style="color: #666;">Imagen Equirectangular 360°</small></div>',
                obj.panorama_image.url
            )
        return "Sin imagen panorámica"

    @admin.display(description='Coordenadas GPS')
    def map_link(self, obj):
        if obj.latitude and obj.longitude:
            return format_html(
                '<a href="https://www.google.com/maps?q={},{}"" target="_blank" style="color: #1976D2; font-weight: 500; text-decoration: none;">📍 {}, {}</a>',
                obj.latitude, obj.longitude, obj.latitude, obj.longitude
            )
        return format_html('<span style="color: #999;">Sin GPS</span>')

    @admin.display(description='Ver en Mapa')
    def map_link_detail(self, obj):
        if obj.latitude and obj.longitude:
            return format_html(
                '<a href="https://www.google.com/maps?q={},{}"" target="_blank" class="button" style="background: #1976D2; color: #fff; padding: 6px 12px; border-radius: 4px; text-decoration: none;">🗺️ Abrir Coordenadas en Google Maps ({}, {})</a>',
                obj.latitude, obj.longitude, obj.latitude, obj.longitude
            )
        return "Coordenadas no especificadas"

    @admin.display(description='Hotspots')
    def hotspots_count(self, obj):
        return obj.hotspots.count()

    @admin.action(description='Activar escenas seleccionadas')
    def activar_escenas(self, request, queryset):
        queryset.update(is_active=True)

    @admin.action(description='Desactivar escenas seleccionadas')
    def desactivar_escenas(self, request, queryset):
        queryset.update(is_active=False)


@admin.register(Hotspot)
class HotspotAdmin(admin.ModelAdmin):
    list_display = ('title', 'source_scene', 'hotspot_type_badge', 'yaw_pitch_display', 'target_scene', 'icon')
    list_filter = ('type', 'source_scene__route')
    search_fields = ('title', 'content', 'source_scene__title')
    readonly_fields = ('uuid', 'created_at', 'updated_at')

    @admin.display(description='Tipo de Hotspot')
    def hotspot_type_badge(self, obj):
        colors = {
            Hotspot.HotspotType.NAVIGATION: '#0288D1',   # Blue
            Hotspot.HotspotType.INFORMATION: '#388E3C',  # Green
            Hotspot.HotspotType.WARNING: '#D32F2F',      # Red
        }
        color = colors.get(obj.type, '#666')
        return format_html(
            '<span style="background-color: {}; color: #fff; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 600;">{}</span>',
            color,
            obj.get_type_display()
        )

    @admin.display(description='Orientación (Yaw / Pitch)')
    def yaw_pitch_display(self, obj):
        return f"{obj.yaw:.1f}° / {obj.pitch:.1f}°"


@admin.register(PointOfInterest)
class PointOfInterestAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'altitude_masl', 'route', 'map_link', 'order', 'is_active')
    list_filter = ('category', 'route', 'is_active')
    search_fields = ('name', 'description', 'route__name')
    readonly_fields = ('uuid', 'image_preview', 'created_at', 'updated_at')
    list_editable = ('order', 'is_active')

    @admin.display(description='Fotografía')
    def image_preview(self, obj):
        if obj.image:
            return format_html('<img src="{}" style="max-height: 180px; border-radius: 6px;" />', obj.image.url)
        return "Sin imagen"

    @admin.display(description='GPS')
    def map_link(self, obj):
        if obj.latitude and obj.longitude:
            return format_html(
                '<a href="https://www.google.com/maps?q={},{}"" target="_blank" style="color: #1976D2;">📍 Ver Mapa</a>',
                obj.latitude, obj.longitude
            )
        return "-"


@admin.register(SafetyRecommendation)
class SafetyRecommendationAdmin(admin.ModelAdmin):
    list_display = ('title', 'category_badge', 'order', 'is_active')
    list_filter = ('category', 'is_active')
    search_fields = ('title', 'description')
    list_editable = ('order', 'is_active')

    @admin.display(description='Categoría')
    def category_badge(self, obj):
        colors = {
            SafetyRecommendation.Category.EQUIPAMIENTO: '#455A64',
            SafetyRecommendation.Category.SALUD: '#C2185B',
            SafetyRecommendation.Category.HIDRATACION: '#0288D1',
            SafetyRecommendation.Category.SEGURIDAD: '#E65100',
            SafetyRecommendation.Category.AMBIENTE: '#2E7D32',
            SafetyRecommendation.Category.BATERIA: '#6A1B9A',
        }
        color = colors.get(obj.category, '#444')
        return format_html(
            '<span style="background-color: {}; color: #fff; padding: 2px 8px; border-radius: 10px; font-size: 11px;">{}</span>',
            color, obj.get_category_display()
        )


@admin.register(BiodiversitySpecies)
class BiodiversitySpeciesAdmin(admin.ModelAdmin):
    list_display = (
        'photo_thumb',
        'name',
        'quechua_name',
        'scientific_name',
        'category',
        'altitude_range',
        'status_badge',
        'is_endemic',
        'order',
        'is_active'
    )
    list_filter = ('category', 'conservation_status', 'is_endemic', 'is_active')
    search_fields = ('name', 'quechua_name', 'scientific_name', 'summary', 'ecological_role')
    list_editable = ('order', 'is_active')
    readonly_fields = ('uuid', 'photo_preview_large', 'created_at', 'updated_at')

    fieldsets = (
        ('Nomenclatura y Clasificación', {
            'fields': (
                ('name', 'quechua_name'),
                'scientific_name',
                ('category', 'is_endemic'),
                ('conservation_status', 'altitude_range'),
                ('order', 'is_active')
            )
        }),
        ('Información Ecológica y de Conservación', {
            'fields': ('summary', 'ecological_role', 'conservation_tip')
        }),
        ('Fotografía de la Especie', {
            'fields': ('image', 'photo_preview_large')
        }),
        ('Auditoría', {
            'classes': ('collapse',),
            'fields': ('uuid', 'created_at', 'updated_at')
        }),
    )

    @admin.display(description='Foto')
    def photo_thumb(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="width: 44px; height: 44px; object-fit: cover; border-radius: 50%; box-shadow: 0 2px 6px rgba(0,0,0,0.15); border: 2px solid #2D6A4F;" />',
                obj.image.url
            )
        return format_html('<span class="hp-thumb-empty" style="border-radius: 50%; width: 44px; height: 44px;" title="Sin fotografía">🌿</span>')

    @admin.display(description='Vista Previa de Foto')
    def photo_preview_large(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="max-height: 200px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.15);" />',
                obj.image.url
            )
        return "Sin fotografía adjunta"

    @admin.display(description='Estado de Conservación')
    def status_badge(self, obj):
        config = {
            BiodiversitySpecies.ConservationStatus.CRITICO: ('#FEE2E2', '#7F0000', '🚨'),
            BiodiversitySpecies.ConservationStatus.PELIGRO: ('#FEE2E2', '#C62828', '⚠️'),
            BiodiversitySpecies.ConservationStatus.VULNERABLE: ('#FEF3C7', '#D97706', '⚡'),
            BiodiversitySpecies.ConservationStatus.CASI_AMENAZADO: ('#FEF3C7', '#B45309', '👁️'),
            BiodiversitySpecies.ConservationStatus.PREOCUPACION_MENOR: ('#DCFCE7', '#15803D', '🌿'),
        }
        bg, fg, icon = config.get(obj.conservation_status, ('#F1F5F9', '#475569', '•'))
        return format_html(
            '<span class="hp-badge" style="background: {}; color: {};">{} {}</span>',
            bg, fg, icon, obj.get_conservation_status_display()
        )


@admin.register(MountainWeatherStation)
class MountainWeatherStationAdmin(admin.ModelAdmin):
    list_display = (
        'name',
        'altitude_masl',
        'temperatures_display',
        'condition',
        'wind_display',
        'uv_display',
        'risk_badge',
        'order',
        'is_active',
        'updated_at'
    )
    list_filter = ('risk_level', 'is_active')
    search_fields = ('name', 'condition', 'alert_advisory')
    list_editable = ('order', 'is_active')
    readonly_fields = ('uuid', 'created_at', 'updated_at')

    fieldsets = (
        ('Estación y Ubicación Altitudinal', {
            'fields': ('name', 'altitude_masl', ('order', 'is_active'))
        }),
        ('Temperatura y Condiciones Meteorológicas', {
            'fields': (
                ('temp_day_celsius', 'temp_night_celsius', 'wind_chill_celsius'),
                ('condition', 'weather_icon'),
                ('wind_kmh', 'wind_gusts_kmh'),
                ('uv_index', 'uv_level'),
                ('humidity_percentage', 'pressure_hpa'),
            )
        }),
        ('Evaluación de Riesgo y Avisos a Montañistas', {
            'fields': ('risk_level', 'alert_advisory')
        }),
        ('Auditoría', {
            'classes': ('collapse',),
            'fields': ('uuid', 'created_at', 'updated_at')
        }),
    )

    @admin.display(description='Temperaturas (Día / Noche / Sensación)')
    def temperatures_display(self, obj):
        return format_html(
            '<strong>{}°C</strong> / <span style="color: #1565C0;">{}°C</span> <small style="color: #666;">(ST: {}°C)</small>',
            obj.temp_day_celsius, obj.temp_night_celsius, obj.wind_chill_celsius
        )

    @admin.display(description='Viento')
    def wind_display(self, obj):
        return f"{obj.wind_kmh} km/h (Ráfagas {obj.wind_gusts_kmh})"

    @admin.display(description='Índice UV')
    def uv_display(self, obj):
        return f"UV {obj.uv_index} ({obj.uv_level})"

    @admin.display(description='Nivel de Riesgo')
    def risk_badge(self, obj):
        config = {
            MountainWeatherStation.RiskLevel.BAJO: ('#DCFCE7', '#15803D', '🟢'),
            MountainWeatherStation.RiskLevel.MODERADO: ('#FEF3C7', '#B45309', '🟡'),
            MountainWeatherStation.RiskLevel.HELADAS: ('#FEE2E2', '#DC2626', '❄️'),
            MountainWeatherStation.RiskLevel.EXTREMO: ('#FCE7F3', '#9D174D', '⚠️'),
            MountainWeatherStation.RiskLevel.VENTISCA: ('#EDE9FE', '#6D28D9', '🌪️'),
        }
        bg, fg, icon = config.get(obj.risk_level, ('#F1F5F9', '#475569', '•'))
        return format_html(
            '<span class="hp-badge" style="background: {}; color: {};">{} {}</span>',
            bg, fg, icon, obj.get_risk_level_display()
        )


@admin.register(WeatherAlert)
class WeatherAlertAdmin(admin.ModelAdmin):
    list_display = ('title', 'severity_badge', 'affected_sector', 'valid_from', 'valid_until', 'is_active')
    list_filter = ('severity', 'is_active', 'valid_from')
    search_fields = ('title', 'description', 'affected_sector')
    readonly_fields = ('uuid', 'created_at', 'updated_at')

    @admin.display(description='Severidad')
    def severity_badge(self, obj):
        colors = {
            WeatherAlert.Severity.INFO: '#0288D1',
            WeatherAlert.Severity.PRECAUCION: '#F57C00',
            WeatherAlert.Severity.PELIGRO: '#C62828',
        }
        color = colors.get(obj.severity, '#555')
        return format_html(
            '<span style="background-color: {}; color: #fff; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 600;">{}</span>',
            color,
            obj.get_severity_display()
        )


@admin.register(AudioGuide)
class AudioGuideAdmin(admin.ModelAdmin):
    list_display = (
        'title_es',
        'title_qu',
        'category',
        'location_name',
        'duration_formatted',
        'audio_player_widget',
        'order',
        'is_active'
    )
    list_filter = ('category', 'is_active')
    search_fields = ('title_es', 'title_qu', 'location_name', 'transcript_es', 'transcript_qu')
    list_editable = ('order', 'is_active')
    readonly_fields = ('uuid', 'audio_player_detail', 'created_at', 'updated_at')

    fieldsets = (
        ('Identificación y Ubicación', {
            'fields': (
                ('title_es', 'title_qu'),
                ('category', 'location_name'),
                ('duration_formatted', 'order', 'is_active')
            )
        }),
        ('Audio y Reproducción', {
            'fields': ('audio_file', 'audio_url', 'audio_player_detail')
        }),
        ('Transcripciones Bilingües y Glosario', {
            'fields': ('transcript_es', 'transcript_qu', 'didactic_glossary')
        }),
        ('Auditoría', {
            'classes': ('collapse',),
            'fields': ('uuid', 'created_at', 'updated_at')
        }),
    )

    @admin.display(description='Reproducir Audio')
    def audio_player_widget(self, obj):
        url = None
        if obj.audio_file:
            url = obj.audio_file.url
        elif obj.audio_url:
            url = obj.audio_url
        if url:
            return format_html(
                '<audio controls preload="none" style="height: 28px; width: 180px;"><source src="{}" type="audio/mpeg">Tu navegador no soporta audio.</audio>',
                url
            )
        return format_html('<span style="color: #999; font-size: 11px;">Sin audio</span>')

    @admin.display(description='Reproductor de Audio')
    def audio_player_detail(self, obj):
        url = None
        if obj.audio_file:
            url = obj.audio_file.url
        elif obj.audio_url:
            url = obj.audio_url
        if url:
            return format_html(
                '<div style="margin: 8px 0;"><audio controls style="width: 100%; max-width: 450px;"><source src="{}" type="audio/mpeg"></audio><br><small style="color: #666;">Fuente: {}</small></div>',
                url, url
            )
        return "No hay archivo ni URL de audio configurada"


@admin.register(CommunityService)
class CommunityServiceAdmin(admin.ModelAdmin):
    list_display = (
        'service_photo_thumb',
        'name',
        'category_badge',
        'contact_phone',
        'whatsapp_direct_link',
        'badge_text',
        'order',
        'is_active'
    )
    list_filter = ('category', 'is_active')
    search_fields = ('name', 'contact_phone', 'whatsapp_number', 'location_address', 'services_description')
    list_editable = ('order', 'is_active')
    readonly_fields = ('uuid', 'service_photo_large', 'whatsapp_direct_link', 'created_at', 'updated_at')

    fieldsets = (
        ('Prestador y Categoría', {
            'fields': (
                ('name', 'category'),
                ('badge_text', 'experience_years'),
                ('price_range', 'order', 'is_active')
            )
        }),
        ('Contacto y Ubicación', {
            'fields': (
                ('contact_phone', 'whatsapp_number'),
                'whatsapp_direct_link',
                'location_address'
            )
        }),
        ('Detalle de Servicios e Imagen', {
            'fields': ('services_description', 'image', 'service_photo_large')
        }),
        ('Auditoría', {
            'classes': ('collapse',),
            'fields': ('uuid', 'created_at', 'updated_at')
        }),
    )

    @admin.display(description='Logo / Foto')
    def service_photo_thumb(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="width: 42px; height: 42px; object-fit: cover; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.15);" />',
                obj.image.url
            )
        return format_html('<span style="color: #999; font-size: 11px;">Sin foto</span>')

    @admin.display(description='Vista Previa de Foto')
    def service_photo_large(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="max-height: 180px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.15);" />',
                obj.image.url
            )
        return "Sin fotografía adjunta"

    @admin.display(description='Categoría')
    def category_badge(self, obj):
        colors = {
            CommunityService.ServiceCategory.GUIA: '#1B5E20',
            CommunityService.ServiceCategory.ARRIERO: '#006064',
            CommunityService.ServiceCategory.HOSPEDAJE: '#E65100',
            CommunityService.ServiceCategory.CAMPAMENTO: '#33691E',
            CommunityService.ServiceCategory.GASTRONOMIA: '#B71C1C',
            CommunityService.ServiceCategory.ARTESANIA: '#4A148C',
        }
        color = colors.get(obj.category, '#444')
        return format_html(
            '<span style="background-color: {}; color: #fff; padding: 3px 8px; border-radius: 10px; font-size: 11px; font-weight: 600;">{}</span>',
            color, obj.get_category_display()
        )

    @admin.display(description='WhatsApp')
    def whatsapp_direct_link(self, obj):
        number = (obj.whatsapp_number or obj.contact_phone or '').replace(' ', '').replace('+', '').replace('-', '')
        if number:
            return format_html(
                '<a href="https://wa.me/{}" target="_blank" style="color: #2E7D32; font-weight: 600; text-decoration: none;">💬 Chatear ({})</a>',
                number, obj.whatsapp_number or obj.contact_phone
            )
        return "-"


@admin.register(EmergencyContact)
class EmergencyContactAdmin(admin.ModelAdmin):
    list_display = ('title', 'short_phone', 'full_number_link', 'priority_order', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('title', 'short_phone', 'full_number', 'description')
    list_editable = ('priority_order', 'is_active')
    readonly_fields = ('uuid', 'created_at', 'updated_at')

    @admin.display(description='Número Completo / Llamar')
    def full_number_link(self, obj):
        if obj.full_number:
            clean = obj.full_number.replace(' ', '')
            return format_html('<a href="tel:{}" style="color: #D32F2F; font-weight: 600;">📞 {}</a>', clean, obj.full_number)
        return "-"


@admin.register(CommunityPost)
class CommunityPostAdmin(admin.ModelAdmin):
    list_display = (
        'post_photo_thumb',
        'author_name',
        'author_role',
        'category',
        'location_name',
        'munay_count',
        'lnt_verified',
        'is_approved',
        'is_active',
        'created_at'
    )
    list_filter = ('is_approved', 'category', 'lnt_verified', 'is_active', 'created_at')
    search_fields = ('author_name', 'location_name', 'content')
    list_editable = ('is_approved', 'is_active')
    readonly_fields = ('uuid', 'post_photo_large', 'created_at', 'updated_at')
    actions = ['aprobar_publicaciones', 'rechazar_publicaciones', 'verificar_lnt']

    fieldsets = (
        ('Autor y Contenido', {
            'fields': (
                ('author_name', 'author_role'),
                ('category', 'location_name'),
                'content',
                ('image', 'post_photo_large')
            )
        }),
        ('Métricas y Moderación de Centinela', {
            'fields': (
                ('munay_count', 'lnt_verified'),
                ('is_approved', 'is_active')
            )
        }),
        ('Auditoría', {
            'classes': ('collapse',),
            'fields': ('uuid', 'created_at', 'updated_at')
        }),
    )

    @admin.display(description='Foto')
    def post_photo_thumb(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px;" />',
                obj.image.url
            )
        return "-"

    @admin.display(description='Vista Previa de Foto')
    def post_photo_large(self, obj):
        if obj.image:
            return format_html('<img src="{}" style="max-height: 200px; border-radius: 8px;" />', obj.image.url)
        return "Sin foto"

    @admin.action(description='Aprobar publicaciones seleccionadas')
    def aprobar_publicaciones(self, request, queryset):
        count = queryset.update(is_approved=True)
        self.message_user(request, f"Se aprobaron {count} publicaciones.")

    @admin.action(description='Rechazar / Desaprobar publicaciones seleccionadas')
    def rechazar_publicaciones(self, request, queryset):
        count = queryset.update(is_approved=False)
        self.message_user(request, f"Se desaprobaron {count} publicaciones.")

    @admin.action(description='Marcar como Verificado No Deje Rastro (LNT)')
    def verificar_lnt(self, request, queryset):
        count = queryset.update(lnt_verified=True)
        self.message_user(request, f"Se verificaron {count} publicaciones con sello LNT.")


@admin.register(GuardianBadge)
class GuardianBadgeAdmin(admin.ModelAdmin):
    list_display = ('title', 'quechua_title', 'tier_badge', 'xp_points', 'order', 'is_active')
    list_filter = ('tier', 'is_active')
    search_fields = ('title', 'quechua_title', 'description')
    prepopulated_fields = {'slug': ('title',)}
    readonly_fields = ('uuid', 'created_at', 'updated_at')

    @admin.display(description='Nivel')
    def tier_badge(self, obj):
        colors = {
            GuardianBadge.BadgeTier.BRONCE: '#CD7F32',
            GuardianBadge.BadgeTier.PLATA: '#9E9E9E',
            GuardianBadge.BadgeTier.ORO: '#E9C46A',
            GuardianBadge.BadgeTier.DIAMANTE: '#00838F',
        }
        color = colors.get(obj.tier, '#333')
        return format_html(
            '<span style="background-color: {}; color: #fff; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 700;">{}</span>',
            color,
            obj.get_tier_display()
        )


@admin.register(TrailPassportStamp)
class TrailPassportStampAdmin(admin.ModelAdmin):
    list_display = ('name', 'quechua_name', 'route', 'altitude_masl', 'latitude', 'longitude', 'secret_code', 'order', 'is_active')
    list_filter = ('route', 'is_active')
    search_fields = ('name', 'quechua_name', 'secret_code')
    readonly_fields = ('uuid', 'created_at', 'updated_at')


@admin.register(MunicipalNotice)
class MunicipalNoticeAdmin(admin.ModelAdmin):
    list_display = ('title', 'category_badge', 'priority_badge', 'department', 'published_at', 'valid_until', 'is_active')
    list_filter = ('category', 'priority', 'is_active', 'published_at')
    search_fields = ('title', 'subtitle', 'full_text', 'department')
    readonly_fields = ('uuid', 'created_at', 'updated_at')
    fieldsets = (
        ('Información Principal', {
            'fields': ('title', 'subtitle', 'category', 'priority', 'department', 'icon', 'image')
        }),
        ('Contenido Oficial', {
            'fields': ('full_text', 'recommendations')
        }),
        ('Vigencia y Estado', {
            'fields': ('published_at', 'valid_until', 'is_active')
        }),
        ('Metadatos', {
            'classes': ('collapse',),
            'fields': ('uuid', 'created_at', 'updated_at')
        })
    )

    @admin.display(description='Categoría')
    def category_badge(self, obj):
        colors = {
            MunicipalNotice.Category.VIAL: '#E76F51',
            MunicipalNotice.Category.TURISMO: '#00838F',
            MunicipalNotice.Category.CONSERVACION: '#2D6A4F',
            MunicipalNotice.Category.CLIMA: '#0A2540',
            MunicipalNotice.Category.COMUNAL: '#6A4C93',
        }
        color = colors.get(obj.category, '#555')
        return format_html(
            '<span style="background-color: {}; color: #fff; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 700;">{}</span>',
            color,
            obj.get_category_display()
        )

    @admin.display(description='Prioridad')
    def priority_badge(self, obj):
        colors = {
            MunicipalNotice.Priority.ALTA: '#D32F2F',
            MunicipalNotice.Priority.PRECAUCION: '#F57C00',
            MunicipalNotice.Priority.INFORMATIVO: '#1976D2',
            MunicipalNotice.Priority.COMUNITARIO: '#388E3C',
        }
        color = colors.get(obj.priority, '#666')
        return format_html(
            '<span style="background-color: {}; color: #fff; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 700;">{}</span>',
            color,
            obj.get_priority_display()
        )


@admin.register(TrekkingExpedition)
class TrekkingExpeditionAdmin(admin.ModelAdmin):
    list_display = ('tourist_name', 'group_size', 'route', 'guide_name', 'status_badge', 'departure_datetime', 'expected_return_datetime', 'actual_return_datetime')
    list_filter = ('status', 'route', 'departure_datetime')
    search_fields = ('tourist_name', 'tourist_phone', 'guide_name', 'emergency_contact_name')
    readonly_fields = ('uuid', 'created_at', 'updated_at')
    actions = ['marcar_como_retornadas', 'marcar_como_retrasadas']

    @admin.display(description='Estado')
    def status_badge(self, obj):
        colors = {
            TrekkingExpedition.Status.PLANIFICADA: '#1976D2',
            TrekkingExpedition.Status.EN_CURSO: '#F57C00',
            TrekkingExpedition.Status.RETORNADA: '#2E7D32',
            TrekkingExpedition.Status.RETRASADA: '#C62828',
            TrekkingExpedition.Status.ALERTA_SOS: '#D50000',
        }
        color = colors.get(obj.status, '#555')
        return format_html(
            '<span style="background-color: {}; color: #fff; padding: 4px 10px; border-radius: 14px; font-size: 11px; font-weight: 800;">{}</span>',
            color,
            obj.get_status_display()
        )

    @admin.action(description='Marcar expediciones seleccionadas como RETORNADAS (Check-out)')
    def marcar_como_retornadas(self, request, queryset):
        from django.utils import timezone
        count = queryset.update(status=TrekkingExpedition.Status.RETORNADA, actual_return_datetime=timezone.now())
        self.message_user(request, f"Se registraron {count} expediciones como retornadas con éxito.")

    @admin.action(description='Marcar expediciones seleccionadas como RETRASADAS')
    def marcar_como_retrasadas(self, request, queryset):
        count = queryset.update(status=TrekkingExpedition.Status.RETRASADA)
        self.message_user(request, f"Se marcaron {count} expediciones en alerta de retraso.")


@admin.register(CommunityServiceReview)
class CommunityServiceReviewAdmin(admin.ModelAdmin):
    list_display = ('author_name', 'service', 'rating_stars', 'comment_snippet', 'is_approved', 'created_at')
    list_filter = ('rating', 'is_approved', 'created_at', 'service')
    search_fields = ('author_name', 'comment', 'service__name')
    actions = ['aprobar_resenas', 'desaprobar_resenas']

    @admin.display(description='Puntuación')
    def rating_stars(self, obj):
        stars = '★' * obj.rating + '☆' * (5 - obj.rating)
        return format_html('<span style="color: #F59E0B; font-size: 14px; font-weight: 700;">{} ({}★)</span>', stars, obj.rating)

    @admin.display(description='Comentario')
    def comment_snippet(self, obj):
        return obj.comment[:60] + '...' if len(obj.comment) > 60 else obj.comment

    @admin.action(description='Aprobar reseñas seleccionadas')
    def aprobar_resenas(self, request, queryset):
        count = queryset.update(is_approved=True)
        self.message_user(request, f"Se aprobaron {count} reseñas.")

    @admin.action(description='Desaprobar reseñas seleccionadas')
    def desaprobar_resenas(self, request, queryset):
        count = queryset.update(is_approved=False)
        self.message_user(request, f"Se desaprobaron {count} reseñas.")


@admin.register(CheckpointVisitorLog)
class CheckpointVisitorLogAdmin(admin.ModelAdmin):
    list_display = (
        'visitor_name',
        'document_info',
        'route_name',
        'group_size',
        'entry_datetime',
        'waste_summary_badge',
        'compliance_badge',
        'status_badge',
    )
    list_filter = (
        'status',
        'waste_compliance_status',
        'document_type',
        'entry_datetime',
        'exit_datetime',
    )
    search_fields = (
        'visitor_name',
        'document_number',
        'guide_name',
        'phone',
        'entry_ranger_name',
        'exit_ranger_name',
        'local_uuid',
    )
    readonly_fields = (
        'uuid',
        'local_uuid',
        'total_items_in',
        'total_items_out',
        'created_at',
        'updated_at',
    )
    fieldsets = (
        ('Datos del Visitante / Grupo', {
            'fields': (
                ('visitor_name', 'document_type', 'document_number'),
                ('phone', 'group_size', 'route_name'),
                ('guide_name', 'checkpoint_name'),
            )
        }),
        ('Registro de Ascenso (Entrada)', {
            'fields': (
                ('entry_datetime', 'entry_ranger_name'),
                ('plastic_bottles_in', 'cans_in', 'plastic_wrappers_in'),
                ('plastic_bags_in', 'batteries_in', 'gas_canisters_in'),
                ('other_waste_details_in', 'total_items_in'),
            )
        }),
        ('Inspección de Descenso y Retorno de Residuos (Salida)', {
            'fields': (
                ('exit_datetime', 'exit_ranger_name'),
                ('plastic_bottles_out', 'cans_out', 'plastic_wrappers_out'),
                ('plastic_bags_out', 'batteries_out', 'gas_canisters_out'),
                ('total_items_out', 'waste_compliance_status', 'status'),
                'notes',
            )
        }),
        ('Metadatos y Sincronización Offline', {
            'classes': ('collapse',),
            'fields': ('uuid', 'local_uuid', 'created_by', 'created_at', 'updated_at'),
        }),
    )

    @admin.display(description='Documento')
    def document_info(self, obj):
        return f"{obj.document_type}: {obj.document_number}"

    @admin.display(description='Residuos In / Out')
    def waste_summary_badge(self, obj):
        in_count = obj.total_items_in
        out_count = obj.total_items_out
        return format_html(
            '<span style="font-weight: 700; font-size: 12px; color: #1E293B;">'
            '📦 Subieron: <b>{}</b> | ♻️ Retornaron: <b>{}</b>'
            '</span>',
            in_count,
            out_count
        )

    @admin.display(description='Huella Cero / Cumplimiento')
    def compliance_badge(self, obj):
        status_colors = {
            'compliant': ('#10B981', '#ECFDF5', '✓ Conforme (100% Retornado)'),
            'extra_collected': ('#059669', '#D1FAE5', '★ Meritorio (+ Basura recogida)'),
            'infraction_missing': ('#EF4444', '#FEF2F2', '⚠ Infracción (Faltan Residuos)'),
            'pending_checkout': ('#F59E0B', '#FFFBEB', '⏳ En Montaña (Pendiente)'),
        }
        color, bg, label = status_colors.get(
            obj.waste_compliance_status,
            ('#64748B', '#F1F5F9', obj.get_waste_compliance_status_display())
        )
        return format_html(
            '<span style="background-color: {}; color: {}; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 700; border: 1px solid {};">{}</span>',
            bg, color, color, label
        )

    @admin.display(description='Estado Visita')
    def status_badge(self, obj):
        badges = {
            'en_montana': ('#2563EB', '#EFF6FF', 'En Montaña'),
            'completado': ('#10B981', '#ECFDF5', 'Descenso Verificado'),
            'alerta_retraso': ('#DC2626', '#FEF2F2', 'Alerta Retraso'),
        }
        color, bg, label = badges.get(
            obj.status,
            ('#64748B', '#F1F5F9', obj.get_status_display())
        )
        return format_html(
            '<span style="background-color: {}; color: {}; padding: 4px 8px; border-radius: 6px; font-size: 11px; font-weight: 600;">{}</span>',
            bg, color, label
        )




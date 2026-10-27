from django.shortcuts import render
from django.views.generic import TemplateView, View
from django.http import HttpResponse
from django.db.models import Prefetch

from apps.tourism.models import (
    Route,
    TourScene,
    PointOfInterest,
    SafetyRecommendation,
    BiodiversitySpecies,
    MountainWeatherStation,
    WeatherAlert,
    AudioGuide,
    CommunityService,
    EmergencyContact,
    GuardianBadge,
    TrailPassportStamp,
)
from apps.environmental_reports.models import EnvironmentalReport
from apps.landing.models import (
    LandingHeroConfig,
    LandingMetric,
    LandingFeature,
    LandingWaypoint,
    LandingExperience,
    LandingFAQ,
    LandingAudioGuide
)


class LandingPageView(TemplateView):
    template_name = 'landing/index.html'

    def dispatch(self, request, *args, **kwargs):
        host = request.get_host().lower()
        if host.startswith('apih.'):
            accept = request.headers.get('Accept', '')
            if 'application/json' in accept and 'text/html' not in accept:
                from django.http import JsonResponse
                return JsonResponse({
                    'service': 'HUAGURUNCHO 360 - API Gateway',
                    'version': '1.0.0',
                    'status': 'operational',
                    'portal': 'https://huaguruncho.aquienpasco.com'
                })
            from django.shortcuts import redirect
            return redirect('https://huaguruncho.aquienpasco.com/', permanent=False)
        return super().dispatch(request, *args, **kwargs)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)

        # 0. CMS: Configuración Hero y Enlaces de Descarga
        hero_config = LandingHeroConfig.objects.filter(is_active=True).first()
        context['hero_config'] = hero_config

        # CMS: Métricas y Beneficios
        context['cms_metrics'] = LandingMetric.objects.filter(is_active=True).order_by('order')
        context['cms_features'] = LandingFeature.objects.filter(is_active=True).order_by('order')
        context['cms_waypoints'] = LandingWaypoint.objects.all().order_by('order')
        context['cms_experiences'] = LandingExperience.objects.filter(is_active=True).order_by('order')
        context['cms_faqs'] = LandingFAQ.objects.filter(is_active=True).order_by('order')
        context['cms_audio_guide'] = LandingAudioGuide.objects.filter(is_active=True).first()

        # 1. Rutas con sus puntos de interés
        routes = Route.objects.filter(is_active=True).prefetch_related(
            'points_of_interest',
            'scenes'
        ).order_by('distance_km')
        context['routes'] = routes
        context['featured_route'] = routes.first()

        # 2. Escenas 360 destacadas
        scenes = TourScene.objects.filter(is_active=True).select_related('route').prefetch_related('hotspots').order_by('sequence')
        context['scenes'] = scenes
        context['current_scene'] = scenes.first()

        # 3. Puntos de Interés emblemáticos
        context['pois'] = PointOfInterest.objects.filter(is_active=True).select_related('route').order_by('order')[:6]

        # 4. Estación Meteorológica y Alertas
        weather_station = MountainWeatherStation.objects.filter(is_active=True).first()
        context['weather_station'] = weather_station
        context['weather_alerts'] = WeatherAlert.objects.filter(is_active=True).order_by('-created_at')[:3]

        # 5. Biodiversidad Altoandina
        context['species_list'] = BiodiversitySpecies.objects.filter(is_active=True).order_by('category', 'name')[:8]

        # 6. Recomendaciones de Seguridad y Montaña
        context['safety_recommendations'] = SafetyRecommendation.objects.filter(is_active=True).order_by('order')[:8]

        # 7. Insignias de Gamificación y Pasaporte del Guardián
        context['badges'] = GuardianBadge.objects.filter(is_active=True).order_by('order')[:6]
        context['stamps'] = TrailPassportStamp.objects.filter(is_active=True).order_by('order')[:4]

        # 8. Muestras de Audioguías
        context['audio_guides'] = AudioGuide.objects.filter(is_active=True).select_related('point_of_interest')[:4]

        # 9. Servicios Comunitarios de Huachón
        context['community_services'] = CommunityService.objects.filter(is_active=True).order_by('category')[:6]

        # 10. Contactos de Emergencia
        context['emergency_contacts'] = EmergencyContact.objects.filter(is_active=True).order_by('priority_order')

        # 11. Métricas del Ecosistema
        context['stats'] = {
            'summit_altitude': '5,742 m',
            'total_routes_km': sum(r.distance_km for r in routes) if routes.exists() else '14.5 km',
            'panoramas_count': scenes.count() or 9,
            'species_count': BiodiversitySpecies.objects.filter(is_active=True).count() or 6,
            'total_reports': EnvironmentalReport.objects.count() or 128,
            'conservation_rate': '99.4%',
        }

        return context


class HTMXRouteFilterView(View):
    """
    Endpoint HTMX para filtrar rutas por nivel de dificultad o criterios de altimetría.
    """
    def get(self, request, *args, **kwargs):
        difficulty = request.GET.get('difficulty', 'all')
        routes_qs = Route.objects.filter(is_active=True).prefetch_related('points_of_interest', 'scenes')

        if difficulty and difficulty != 'all':
            routes_qs = routes_qs.filter(difficulty=difficulty)

        sort_by = request.GET.get('sort', 'default')
        if sort_by == 'distance_asc':
            routes_qs = routes_qs.order_by('distance_km')
        elif sort_by == 'distance_desc':
            routes_qs = routes_qs.order_by('-distance_km')
        elif sort_by == 'altitude_desc':
            routes_qs = routes_qs.order_by('-max_altitude_m')

        return render(request, 'landing/partials/_route_cards.html', {
            'routes': routes_qs,
            'active_difficulty': difficulty,
        })


class HTMXSafetyAdvisorView(View):
    """
    Endpoint HTMX: Asesor Interactivo de Altitud, Soroche e Hidratación.
    """
    def post(self, request, *args, **kwargs):
        try:
            target_altitude = int(request.POST.get('target_altitude', 4250))
        except (ValueError, TypeError):
            target_altitude = 4250

        experience = request.POST.get('experience', 'intermedio')
        acclimatization_days = int(request.POST.get('acclimatization_days', 1))

        # Cálculos biométricos y de altitud
        # A nivel del mar: 100% O2 efectivo. A 5,000m: ~53% presión de O2.
        o2_effective_pct = max(45, int(100 - ((target_altitude - 0) / 100) * 0.95))
        
        # Agua diaria recomendada: 1L extra cada 1000m sobre los 2500m
        base_water = 2.0
        if target_altitude > 2500:
            extra_water = ((target_altitude - 2500) / 1000) * 0.8
            recommended_water = round(base_water + extra_water, 1)
        else:
            recommended_water = 2.0

        # Nivel de riesgo de mal de altura (Soroche)
        if target_altitude < 3500:
            risk_level = 'Bajo'
            risk_color = 'teal'
            risk_advice = 'Excelente cota para inicio de aclimatación en Huachón (3,400 msnm). Mantén ritmo constante e hidratación.'
        elif target_altitude < 4400:
            if acclimatization_days >= 2 or experience == 'avanzado':
                risk_level = 'Moderado'
                risk_color = 'gold'
                risk_advice = 'Cota de Laguna Huascacocha. Se recomienda caminar a ritmo de 1 respiración por paso. Tomar infusión de muña o coca.'
            else:
                risk_level = 'Elevado'
                risk_color = 'orange'
                risk_advice = 'Requiere al menos 24 horas previas en Huachón. No asciendas de prisa y mantén monitoreo de síntomas.'
        else:
            if acclimatization_days >= 3 and experience == 'avanzado':
                risk_level = 'Alto (Zona Glaciar)'
                risk_color = 'orange'
                risk_advice = 'Mirador Glaciar y Morrenas. Obligatorio equipo técnico, crampones, abrigo de 3 capas y guía certificado UIAGM/AGMP.'
            else:
                risk_level = 'Crítico sin Aclimatación'
                risk_color = 'red'
                risk_advice = 'Peligro de edema pulmonar/cerebral sin aclimatación previa de 48-72h. Ascenso no recomendado sin guía.'

        # Frecuencia recomendada de paradas de descanso
        if target_altitude > 4500:
            rest_interval = 'Cada 30 minutos (Pausa activa de 5 min)'
        elif target_altitude > 3800:
            rest_interval = 'Cada 45 minutos (Pausa de hidratación)'
        else:
            rest_interval = 'Cada 60 minutos'

        return render(request, 'landing/partials/_safety_result.html', {
            'target_altitude': target_altitude,
            'experience': experience,
            'acclimatization_days': acclimatization_days,
            'o2_effective_pct': o2_effective_pct,
            'recommended_water': recommended_water,
            'risk_level': risk_level,
            'risk_color': risk_color,
            'risk_advice': risk_advice,
            'rest_interval': rest_interval,
        })


class HTMXWeatherTelemetryView(View):
    """
    Endpoint HTMX para actualizar en tiempo real los sensores de la estación meteorológica.
    """
    def get(self, request, *args, **kwargs):
        station = MountainWeatherStation.objects.filter(is_active=True).first()
        alerts = WeatherAlert.objects.filter(is_active=True).order_by('-created_at')[:2]

        return render(request, 'landing/partials/_weather_telemetry.html', {
            'weather_station': station,
            'weather_alerts': alerts,
        })


class HTMXTourSceneView(View):
    """
    Endpoint HTMX para cambiar la escena 360 interactiva del visor.
    """
    def get(self, request, *args, **kwargs):
        scene_id = request.GET.get('scene_id')
        if scene_id:
            scene = TourScene.objects.filter(id=scene_id, is_active=True).prefetch_related('hotspots').first()
        else:
            scene = TourScene.objects.filter(is_active=True).prefetch_related('hotspots').first()

        all_scenes = TourScene.objects.filter(is_active=True).order_by('sequence')

        return render(request, 'landing/partials/_tour_scene.html', {
            'current_scene': scene,
            'scenes': all_scenes,
        })


class HTMXSubscribeView(View):
    """
    Endpoint HTMX para procesar descarga anticipada, APK y boletín ambiental.
    """
    def post(self, request, *args, **kwargs):
        email_or_phone = request.POST.get('email_or_phone', '').strip()
        platform = request.POST.get('platform', 'android')

        if not email_or_phone:
            return HttpResponse(
                '<div class="p-4 rounded-xl bg-red-500/20 border border-red-500/40 text-red-200 text-sm flex items-center gap-2">'
                '<i data-lucide="alert-circle" class="w-5 h-5 text-red-400"></i>'
                '<span>Por favor ingresa un correo electrónico o número de WhatsApp válido.</span>'
                '</div>'
            )

        return render(request, 'landing/partials/_subscribe_success.html', {
            'contact': email_or_phone,
            'platform': platform,
        })


class HTMXGuardianStampView(View):
    """
    Endpoint HTMX para simular la recolección de un sello en el Pasaporte Digital del Guardián.
    """
    def post(self, request, *args, **kwargs):
        stamp_name = request.POST.get('stamp_name', 'Mirador Glaciar Huaguruncho')
        altitude = request.POST.get('altitude', '4,680 m s.n.m.')
        
        return render(request, 'landing/partials/_guardian_stamp_result.html', {
            'stamp_name': stamp_name,
            'altitude': altitude,
            'points_earned': 75,
            'total_points': 340,
            'new_rank': 'Guardián del Hielo (Nivel 3)',
        })

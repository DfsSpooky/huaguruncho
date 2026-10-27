from django.core.management.base import BaseCommand
from apps.landing.models import (
    LandingHeroConfig,
    LandingMetric,
    LandingFeature,
    LandingWaypoint,
    LandingExperience,
    LandingFAQ,
    LandingAudioGuide
)


class Command(BaseCommand):
    help = "Puebla la configuración inicial y datos del CMS para la Landing Page de Huaguruncho 360"

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("Iniciando seed de CMS para Landing Page..."))

        # 1. Hero Config
        hero, created = LandingHeroConfig.objects.get_or_create(
            is_active=True,
            defaults={
                "title_line_1": "Explora el Apu Sagrado.",
                "title_line_2": "En la Palma de tu Mano.",
                "subtitle": "Descubre los glaciares milenarios y lagunas turquesas del Nevado Huaguruncho (5,742 m) con mapas que funcionan sin internet, visitas virtuales en 360° y asistencia médica para la altura.",
                "season_badge": "Descubre la Joya Glaciar de Pasco • Temporada 2026",
                "enable_snow_effect": True,
                "app_store_url": "https://apple.com/app-store",
                "google_play_url": "https://play.google.com/store/apps",
                "apk_version": "v1.0.4",
                "apk_size_mb": "48 MB",
            }
        )
        if created:
            self.stdout.write(self.style.SUCCESS("✔ Configuración Hero creada."))

        # 2. Métricas
        metrics_data = [
            {"value": "5,742 m", "label": "Cumbre del Nevado", "color_class": "text-white", "order": 1},
            {"value": "100%", "label": "Navegación Sin Conexión", "color_class": "text-apple-blue", "order": 2},
            {"value": "360°", "label": "Panoramas Virtuales", "color_class": "text-apple-gold", "order": 3},
            {"value": "4 Lagunas", "label": "Espejos Glaciares Vírgenes", "color_class": "text-emerald-400", "order": 4},
        ]
        for item in metrics_data:
            LandingMetric.objects.get_or_create(
                value=item["value"],
                defaults=item
            )
        self.stdout.write(self.style.SUCCESS("✔ Métricas iniciales cargadas."))

        # 3. Features (Bento Grid)
        features_data = [
            {
                "icon_name": "map-pin",
                "icon_color": "text-apple-blue",
                "title": "Mapas 100% Sin Internet",
                "description": "Descarga el sendero completo antes de salir de Huachón. Tu posición GPS funcionará con precisión incluso en los valles más profundos.",
                "badge_text": "GPS Satelital Activo sin Cobertura Móvil",
                "badge_color": "emerald",
                "order": 1,
            },
            {
                "icon_name": "heart-pulse",
                "icon_color": "text-apple-gold",
                "title": "Calculadora Anti-Soroche",
                "description": "Recomendaciones personalizadas de aclimatación, hidratación y pausas de respiración según la altitud de tu ruta.",
                "badge_text": "Monitoreo de Oxigenación y Ritmo Cardíaco",
                "badge_color": "gold",
                "order": 2,
            },
            {
                "icon_name": "award",
                "icon_color": "text-emerald-400",
                "title": "Pasaporte & Sellos Andinos",
                "description": "Colecciona sellos digitales en cada mirador, suma Eco-Puntos y desbloquea insignias mientras ayudas a proteger el glaciar.",
                "badge_text": "Retos Comunitarios de Ecoturismo",
                "badge_color": "blue",
                "order": 3,
            },
        ]
        for feat in features_data:
            LandingFeature.objects.get_or_create(
                title=feat["title"],
                defaults=feat
            )
        self.stdout.write(self.style.SUCCESS("✔ Beneficios Bento creados."))

        # 4. Waypoints (Perfil Altimétrico)
        waypoints_data = [
            {"name": "Pueblo de Huachón", "altitude_m": 3400, "distance_km": 0.0, "description": "Aclimatación y hospedajes típicos", "badge_color": "text-apple-blue", "order": 1},
            {"name": "Bosque de Queñuales", "altitude_m": 3720, "distance_km": 4.2, "description": "Árboles de papel milenarios y aves", "badge_color": "text-apple-blue", "order": 2},
            {"name": "Laguna Huascacocha", "altitude_m": 4250, "distance_km": 9.0, "description": "Campamento base y aguas turquesas", "badge_color": "text-apple-gold", "order": 3},
            {"name": "Mirador Glaciar", "altitude_m": 4680, "distance_km": 13.5, "description": "Frente de hielo y morrenas", "badge_color": "text-rose-400", "order": 4},
            {"name": "Cumbre Huaguruncho", "altitude_m": 5742, "distance_km": 21.0, "description": "Cumbre máxima de la Cordillera", "badge_color": "text-emerald-400", "order": 5},
        ]
        for wp in waypoints_data:
            LandingWaypoint.objects.get_or_create(
                name=wp["name"],
                defaults=wp
            )
        self.stdout.write(self.style.SUCCESS("✔ Hitos de altimetría creados."))

        # 5. Experiencias & Gastronomía
        exp_data = [
            {
                "icon_or_emoji": "🍲",
                "title": "Gastronomía Andina",
                "description": "Prueba la trucha frita recién pescada de la laguna Huascacocha, la tradicional pachamanca de tres carnes y el caldo de cordero reconfortante.",
                "highlight_tag": "⭐ Restaurantes familiares en Huachón",
                "tag_color": "text-apple-gold",
                "order": 1
            },
            {
                "icon_or_emoji": "🏡",
                "title": "Hospedajes & Guías",
                "description": "Alójate en acogedoras casas rurales, contrata arrieros con caballos para llevar tu equipaje y camina junto a guías locales certificados.",
                "highlight_tag": "⭐ Apoyo directo a la economía comunal",
                "tag_color": "text-emerald-400",
                "order": 2
            },
            {
                "icon_or_emoji": "🎙️",
                "title": "Leyenda del Apu Huaguruncho",
                "description": "Escucha el relato tradicional en Quechua y Español narrado por los ancianos guardianes de la cordillera.",
                "highlight_tag": "⭐ Patrimonio oral vivo",
                "tag_color": "text-apple-blue",
                "order": 3
            },
        ]
        for exp in exp_data:
            LandingExperience.objects.get_or_create(
                title=exp["title"],
                defaults=exp
            )
        self.stdout.write(self.style.SUCCESS("✔ Experiencias de Huachón creadas."))

        # 6. FAQ
        faq_data = [
            {
                "question": "¿La aplicación realmente funciona sin señal de internet?",
                "answer": "¡Sí, 100%! Todos los mapas topográficos, rutas de senderismo y perfiles de elevación quedan guardados en tu celular al descargar la app. Tu GPS funcionará en medio de la montaña sin necesidad de datos móviles.",
                "order": 1
            },
            {
                "question": "¿Cómo llego a Huachón desde Lima o Cerro de Pasco?",
                "answer": "Desde Lima tomas bus hasta Cerro de Pasco (aprox. 6-7 horas). Desde el terminal de Pasco salen colectivos y combis diarias hacia Huachón (1 hora y media por pista asfaltada y afirmada).",
                "order": 2
            },
            {
                "question": "¿Cuál es la mejor época del año para visitar el nevado?",
                "answer": "La temporada seca (mayo a octubre) es ideal, con días soleados de cielo azul y excelente visibilidad del glaciar. De noviembre a abril es temporada de lluvias andinas.",
                "order": 3
            },
            {
                "question": "¿Es obligatorio contratar un guía local?",
                "answer": "Para caminatas cortas hasta la laguna Huascacocha el sendero está señalizado en la app. Sin embargo, para acercarse al frente glaciar o escalar la cumbre es muy recomendable contratar un guía local o arriero en Huachón por seguridad y apoyo a la comunidad.",
                "order": 4
            },
        ]
        for faq in faq_data:
            LandingFAQ.objects.get_or_create(
                question=faq["question"],
                defaults=faq
            )
        self.stdout.write(self.style.SUCCESS("✔ Preguntas frecuentes (FAQ) cargadas."))

        # 7. Audioguía
        LandingAudioGuide.objects.get_or_create(
            title="Leyenda del Apu Huaguruncho",
            defaults={
                "narrator": "Don Eustaquio • Anciano de Huachón",
                "languages": "Quechua Central & Español",
                "duration_text": "03:45",
                "transcript": "En tiempos antiguos, el Apu Huaguruncho protegía a las comunidades de las sequías vertiendo sus aguas puras en las cuatro lagunas...",
                "is_active": True
            }
        )
        self.stdout.write(self.style.SUCCESS("✔ Audioguía creada."))
        self.stdout.write(self.style.SUCCESS("🎉 SEED DE CMS COMPLETADO CON ÉXITO."))

from datetime import timedelta
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.core.files.base import ContentFile
from django.utils import timezone
from django.conf import settings
from apps.tourism.models import (
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
)
from apps.environmental_reports.models import EnvironmentalReport
from apps.offline_packages.services import update_or_create_offline_package

User = get_user_model()


class Command(BaseCommand):
    help = 'Carga datos iniciales y de prueba completos para el Nevado Huaguruncho (Huachón, Pasco, Perú)'

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE('=== INICIANDO CARGA DE SEED DATA: HUAGURUNCHO 360 ==='))

        # 1. Usuarios del Sistema
        admin_user, created = User.objects.get_or_create(
            email='admin@huaguruncho.pe',
            defaults={
                'full_name': 'Administrador General Huaguruncho',
                'phone': '+51963258741',
                'role': User.Role.ADMINISTRADOR,
                'is_staff': True,
                'is_superuser': True,
            }
        )
        if created:
            admin_user.set_password('Huaguruncho2026!')
            admin_user.save()
            self.stdout.write(self.style.SUCCESS('✔ Superusuario admin@huaguruncho.pe creado'))
        else:
            self.stdout.write('ℹ Superusuario admin@huaguruncho.pe ya existe')

        guide_user, created = User.objects.get_or_create(
            email='guia@huaguruncho.pe',
            defaults={
                'full_name': 'Carlos Huamán (Guía de Alta Montaña)',
                'phone': '+51987654321',
                'role': User.Role.GUIA,
            }
        )
        if created:
            guide_user.set_password('Huaguruncho2026!')
            guide_user.save()
            self.stdout.write(self.style.SUCCESS('✔ Guía certificado guia@huaguruncho.pe creado'))

        muni_user, created = User.objects.get_or_create(
            email='municipalidad@huachon.gob.pe',
            defaults={
                'full_name': 'Subgerencia de Turismo y Medio Ambiente - Huachón',
                'phone': '+51955112233',
                'role': User.Role.MUNICIPALIDAD,
                'is_staff': True,
            }
        )
        if created:
            muni_user.set_password('Huaguruncho2026!')
            muni_user.save()
            self.stdout.write(self.style.SUCCESS('✔ Usuario municipalidad@huachon.gob.pe creado'))

        ranger_user, created = User.objects.get_or_create(
            email='guardaparque@huaguruncho.pe',
            defaults={
                'full_name': 'Marco Rosales (Guardaparque Huaguruncho)',
                'phone': '+51944556677',
                'role': User.Role.GUARDAPARQUE,
                'is_staff': True,
            }
        )
        if created:
            ranger_user.set_password('Huaguruncho2026!')
            ranger_user.save()
            self.stdout.write(self.style.SUCCESS('✔ Guardabosques guardaparque@huaguruncho.pe creado'))

        # 2. Recomendaciones de Seguridad y Sostenibilidad
        recommendations = [
            (SafetyRecommendation.Category.EQUIPAMIENTO, 'Calzado de alta montaña', 'Usa botas de trekking impermeables y con buen agarre para terrenos rocosos y húmedos.', 1),
            (SafetyRecommendation.Category.EQUIPAMIENTO, 'Vestimenta en 3 capas', '1ra capa térmica transpirable, 2da capa polar/abrigo, 3ra capa cortavientos e impermeable.', 2),
            (SafetyRecommendation.Category.EQUIPAMIENTO, 'Bastones de trekking', 'Indispensables para reducir el impacto articular en ascensos y descensos empinados.', 3),
            (SafetyRecommendation.Category.SALUD, 'Aclimatación progresiva', 'Pasa al menos 24 a 48 horas en Pasco o Huachón antes de emprender ascensos sobre 4,000 m s.n.m.', 1),
            (SafetyRecommendation.Category.SALUD, 'Prevención del mal de altura (Soroche)', 'Bebe infusión de coca o muña, mantén un ritmo de marcha pausado y evita comidas pesadas.', 2),
            (SafetyRecommendation.Category.HIDRATACION, 'Líquidos constantes', 'Lleva mínimo 2.5 litros de agua o electrolitos por persona. La altitud acelera la deshidratación.', 1),
            (SafetyRecommendation.Category.HIDRATACION, 'Snacks energéticos', 'Frutos secos, chocolate negro, barras energéticas y frutas deshidratadas para recargas rápidas.', 2),
            (SafetyRecommendation.Category.SEGURIDAD, 'Guía local certificado', 'Nunca asciendas solo. El glaciar cuenta con grietas y cambios repentinos de clima.', 1),
            (SafetyRecommendation.Category.SEGURIDAD, 'Horarios de retorno', 'Inicia el retorno antes de las 15:00 horas para evitar nevadas o niebla densa.', 2),
            (SafetyRecommendation.Category.AMBIENTE, 'Principio No Deje Rastro', 'Regresa absolutamente todos los residuos (incluyendo orgánicos). No contamines las lagunas.', 1),
            (SafetyRecommendation.Category.AMBIENTE, 'Respeto a la flora y fauna', 'No arranques queñuales, puyas Raimondi ni molestes a vicuñas, vizcachas o aves altoandinas.', 2),
            (SafetyRecommendation.Category.BATERIA, 'Resguardo térmico de baterías', 'El frío extremo reduce drásticamente la batería de tu celular. Llévalo cerca de tu cuerpo y usa powerbank.', 1),
        ]

        for cat, title, desc, ord in recommendations:
            SafetyRecommendation.objects.update_or_create(
                title=title,
                defaults={
                    'category': cat,
                    'description': desc,
                    'order': ord,
                    'is_active': True
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(recommendations)} recomendaciones de seguridad cargadas'))

        # 3. Ruta Principal con Trazo GeoJSON y Altimetría (Huachón 3,400m -> Huascacocha 4,250m -> Mirador 4,680m)
        huaguruncho_track_coords = [
            [-75.952130, -10.605120, 3400.0],  # 0.0 km - Plaza Huachón
            [-75.954800, -10.601200, 3480.0],  # 0.8 km - Salida del Pueblo
            [-75.958200, -10.595400, 3610.0],  # 2.1 km - Inicio Quebrada
            [-75.961500, -10.589800, 3720.0],  # 3.4 km - Bosque de Queñuales
            [-75.965400, -10.582300, 3850.0],  # 4.5 km - Pampa Chichuraque / Rodal Puya
            [-75.970200, -10.574100, 3990.0],  # 6.2 km - Abra Chichuraque
            [-75.974500, -10.565800, 4110.0],  # 7.9 km - Quebrada Huascacocha
            [-75.981450, -10.551240, 4250.0],  # 9.8 km - Laguna Huascacocha Campamento
            [-75.986200, -10.542100, 4420.0],  # 12.0 km - Morrena Glaciar
            [-75.992810, -10.528930, 4680.0],  # 14.5 km - Mirador Frontal Glaciar
        ]

        elevation_profile_data = [
            {"distance_km": 0.0, "altitude_m": 3400.0, "name": "Plaza Huachón"},
            {"distance_km": 2.1, "altitude_m": 3610.0, "name": "Quebrada Huachina"},
            {"distance_km": 4.5, "altitude_m": 3850.0, "name": "Pampa Chichuraque"},
            {"distance_km": 7.9, "altitude_m": 4110.0, "name": "Abra Altoandina"},
            {"distance_km": 9.8, "altitude_m": 4250.0, "name": "Laguna Huascacocha"},
            {"distance_km": 12.0, "altitude_m": 4420.0, "name": "Morrenas de Altura"},
            {"distance_km": 14.5, "altitude_m": 4680.0, "name": "Mirador Glaciar Huaguruncho"},
        ]

        route, _ = Route.objects.update_or_create(
            slug='huachon-mirador-huaguruncho',
            defaults={
                'name': 'Ruta piloto Huachón – Mirador Huaguruncho',
                'description': 'Recorrido emblemático desde la pintoresca villa de Huachón hasta las faldas del imponente Nevado Huaguruncho (5,742 msnm), conocido como el Coloso de Pasco.',
                'difficulty': Route.Difficulty.MODERADA,
                'distance_km': 14.50,
                'estimated_duration_minutes': 360,
                'safety_recommendations': 'Ruta sobre los 4,000 msnm. Obligatorio calzado de trekking, abrigo por capas y guía autorizado.',
                'elevation_gain_m': 1280.0,
                'elevation_loss_m': 50.0,
                'min_altitude_m': 3400,
                'max_altitude_m': 4680,
                'geojson_track': {
                    "type": "Feature",
                    "geometry": {
                        "type": "LineString",
                        "coordinates": huaguruncho_track_coords,
                    },
                    "properties": {
                        "name": "Sendero Huachón - Nevado Huaguruncho",
                        "distance_km": 14.5,
                        "elevation_gain_m": 1280.0,
                    }
                },
                'elevation_profile': elevation_profile_data,
                'is_active': True,
            }
        )
        self.stdout.write(self.style.SUCCESS('✔ Ruta piloto Huachón – Mirador Huaguruncho lista'))

        # Asignar portada oficial de la ruta si no existe
        if not route.cover_image:
            cover_path = settings.BASE_DIR / 'static' / 'images' / 'huaguruncho_cover.jpg'
            if cover_path.exists():
                with open(cover_path, 'rb') as f:
                    route.cover_image.save('huaguruncho_cover.jpg', ContentFile(f.read()), save=True)

        # 4. Puntos de Interés (POIs)
        pois_data = [
            ('Plaza Mayor de Huachón', PointOfInterest.POICategory.QUEBRADA, 3400, -10.605120, -75.952130, 'Villa andina tradicional, punto de inicio para la expedición al glaciar.', 1),
            ('Pampa Chichuraque', PointOfInterest.POICategory.FLORA_RODAL, 3850, -10.582300, -75.965400, 'Amplia planicie de puna con rodales de Puya Raimondi milenarias.', 2),
            ('Laguna Huascacocha', PointOfInterest.POICategory.LAGUNA, 4250, -10.551240, -75.981450, 'Espejo de agua glaciar turquesa y zona de campamento base ecológico.', 3),
            ('Mirador Glaciar Huaguruncho', PointOfInterest.POICategory.MIRADOR, 4680, -10.528930, -75.992810, 'Balcón natural frente a la pared de hielo y seracs del nevado.', 4),
            ('Cumbre Nevado Huaguruncho', PointOfInterest.POICategory.SITIO_SAGRADO, 5742, -10.518000, -75.999500, 'Apu tutelar de Pasco, cumbre piramidal sagrada en la cosmovisión andina.', 5),
        ]
        for name, cat, alt, lat, lng, desc, ord in pois_data:
            PointOfInterest.objects.update_or_create(
                name=name,
                defaults={
                    'route': route,
                    'category': cat,
                    'altitude_masl': alt,
                    'latitude': lat,
                    'longitude': lng,
                    'description': desc,
                    'order': ord,
                    'is_active': True
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(pois_data)} puntos de interés (POIs) cargados'))

        # 5. Escenas 360° y Hotspots con Panoramas Reales
        def get_bundled_panorama(static_filename, target_filename):
            static_path = settings.BASE_DIR / 'static' / 'images' / static_filename
            if static_path.exists():
                with open(static_path, 'rb') as f:
                    return ContentFile(f.read(), name=target_filename)
            return None

        def ensure_scene_panorama(scene, static_filename, target_filename):
            needs_file = False
            if not scene.panorama_image:
                needs_file = True
            else:
                try:
                    if not scene.panorama_image.storage.exists(scene.panorama_image.name):
                        needs_file = True
                    elif scene.panorama_image.size < 1000:  # Archivo dummy de 43 bytes
                        needs_file = True
                except Exception:
                    needs_file = True

            if needs_file:
                cf = get_bundled_panorama(static_filename, target_filename)
                if cf:
                    scene.panorama_image.save(target_filename, cf, save=True)

        scene1, _ = TourScene.objects.get_or_create(
            route=route,
            sequence=1,
            defaults={
                'title': 'Plaza Principal de Huachón (Punto de Partida)',
                'description': 'Punto de encuentro y aclimatación a 3,400 m s.n.m. Aquí se coordinan los guías de montaña y el equipo de expedición.',
                'latitude': -10.605120,
                'longitude': -75.952130,
                'is_active': True,
            }
        )
        ensure_scene_panorama(scene1, 'scene_huachon_plaza.jpg', 'scene_huachon_plaza.jpg')

        scene2, _ = TourScene.objects.get_or_create(
            route=route,
            sequence=2,
            defaults={
                'title': 'Laguna Huascacocha (Campamento Base)',
                'description': 'Hermosa laguna de origen glaciar a 4,250 m s.n.m. Aguas turquesas y punto de descanso para observar el macizo nevado.',
                'latitude': -10.551240,
                'longitude': -75.981450,
                'is_active': True,
            }
        )
        ensure_scene_panorama(scene2, 'scene_laguna_huaguruncho.jpg', 'scene_laguna_huascacocha.jpg')

        scene3, _ = TourScene.objects.get_or_create(
            route=route,
            sequence=3,
            defaults={
                'title': 'Mirador del Glaciar Nevado Huaguruncho',
                'description': 'Vista panorámica impresionante frente a la pared de hielo y seracs del Nevado Huaguruncho a 4,680 m s.n.m.',
                'latitude': -10.528930,
                'longitude': -75.992810,
                'is_active': True,
            }
        )
        ensure_scene_panorama(scene3, 'scene_mirador_glaciar.jpg', 'scene_mirador_glaciar.jpg')

        for sc in [scene1, scene2, scene3]:
            if sc.panorama_image and not sc.thumbnail:
                sc.save()

        # Hotspots
        Hotspot.objects.update_or_create(
            source_scene=scene1,
            title='Hacia Laguna Huascacocha',
            defaults={
                'target_scene': scene2,
                'type': Hotspot.HotspotType.NAVIGATION,
                'yaw': 35.0,
                'pitch': -2.0,
                'content': 'Avanzar por el sendero comunal hacia el campamento base de la laguna.',
                'icon': 'arrow_forward',
            }
        )
        Hotspot.objects.update_or_create(
            source_scene=scene1,
            title='Historia de Huachón',
            defaults={
                'target_scene': None,
                'type': Hotspot.HotspotType.INFORMATION,
                'yaw': -60.0,
                'pitch': 5.0,
                'content': 'Comunidad altoandina conocida por su hospitalidad, ganadería de altura y guardianes ancestrales del Huaguruncho.',
                'icon': 'info',
            }
        )
        Hotspot.objects.update_or_create(
            source_scene=scene2,
            title='Subir al Mirador del Glaciar',
            defaults={
                'target_scene': scene3,
                'type': Hotspot.HotspotType.NAVIGATION,
                'yaw': 15.0,
                'pitch': 8.0,
                'content': 'Ascenso por la morrena lateral hacia el mirador glaciar superior.',
                'icon': 'arrow_forward',
            }
        )
        Hotspot.objects.update_or_create(
            source_scene=scene2,
            title='Regresar a Plaza Huachón',
            defaults={
                'target_scene': scene1,
                'type': Hotspot.HotspotType.NAVIGATION,
                'yaw': 195.0,
                'pitch': -5.0,
                'content': 'Sendero de retorno hacia el pueblo de Huachón.',
                'icon': 'arrow_back',
            }
        )
        Hotspot.objects.update_or_create(
            source_scene=scene2,
            title='Alerta de Clima Glaciar',
            defaults={
                'target_scene': None,
                'type': Hotspot.HotspotType.WARNING,
                'yaw': -45.0,
                'pitch': -10.0,
                'content': 'Zona con descenso brusco de temperatura por la tarde. No acampar cerca de zonas de desprendimiento de rocas.',
                'icon': 'warning',
            }
        )
        Hotspot.objects.update_or_create(
            source_scene=scene3,
            title='Cumbre Huaguruncho (5,742 msnm)',
            defaults={
                'target_scene': None,
                'type': Hotspot.HotspotType.INFORMATION,
                'yaw': 0.0,
                'pitch': 20.0,
                'content': 'Pirámide de hielo sagrada para la cosmovisión andina central. Requiere equipo técnico de alta montaña.',
                'icon': 'terrain',
            }
        )
        Hotspot.objects.update_or_create(
            source_scene=scene3,
            title='Zona de Grietas y Morrenas',
            defaults={
                'target_scene': None,
                'type': Hotspot.HotspotType.WARNING,
                'yaw': 25.0,
                'pitch': 10.0,
                'content': 'Peligro de grietas no visibles y terreno inestable. No traspasar este punto sin cuerda ni guía oficial.',
                'icon': 'warning',
            }
        )
        self.stdout.write(self.style.SUCCESS('✔ Escenas 360° y Hotspots configurados'))

        # 6. Catálogo de Biodiversidad Altoandina
        species_data = [
            (
                'Puya Raimondi',
                'Titankay / Ckara / Tinkaq',
                'Puya raimondii Harms',
                BiodiversitySpecies.Category.FLORA,
                '3,800 - 4,400 m s.n.m.',
                BiodiversitySpecies.ConservationStatus.PELIGRO,
                True,
                'La reina de la puna. Florece una sola vez cada 80 a 100 años con un cirio floral de más de 10 metros y 10,000 flores.',
                'Almacena agua en sus hojas espinosas y brinda refugio vital a colibríes gigantes y murciélagos polinizadores de altura.',
                'No cortar las hojas ni encender fuego cerca de los rodales. La resina es altamente inflamable.',
                1
            ),
            (
                'Bosque de Queñual',
                'Qiwña / Quñwi',
                'Polylepis racemosa',
                BiodiversitySpecies.Category.FLORA,
                '3,500 - 4,500 m s.n.m.',
                BiodiversitySpecies.ConservationStatus.VULNERABLE,
                True,
                'Árbol con corteza de láminas de papel rojizo. Crece a mayor altitud que cualquier otro árbol en el mundo.',
                'Siembra y cosecha de agua: sus raíces retienen la humedad de las nieblas glaciares alimentando ríos y lagunas.',
                'Prohibido extraer leña de queñual. Su regeneración tarda más de 50 años.',
                2
            ),
            (
                'Cóndor Andino',
                'Apu Kuntur',
                'Vultur gryphus',
                BiodiversitySpecies.Category.AVES,
                '3,000 - 5,500 m s.n.m.',
                BiodiversitySpecies.ConservationStatus.VULNERABLE,
                False,
                'El ave voladora más grande del mundo (3.3m de envergadura). Mensajero sagrado de los Apus en la cosmovisión andina.',
                'Limpiador natural de los ecosistemas al consumir restos orgánicos, previniendo la propagación de enfermedades.',
                'Observar desde la distancia con binoculares. No usar drones cerca de sus riscos de anidación.',
                3
            ),
            (
                'Vizcacha de la Sierra',
                'Wisk\'acha',
                'Lagidium peruanum',
                BiodiversitySpecies.Category.FAUNA,
                '3,600 - 4,800 m s.n.m.',
                BiodiversitySpecies.ConservationStatus.PREOCUPACION_MENOR,
                False,
                'Roedor andino emparentado con la chinchilla. Se le observa tomando el sol en los pedregales y morrenas por la mañana.',
                'Dispersora de semillas de pastos altoandinos y alimento clave para el gato andino y el zorro culpeo.',
                'No alimentarlas con comida procesada humana; altera su digestión adaptada a líquenes y pajonales.',
                4
            ),
            (
                'Gaviota Andina',
                'Qillwa',
                'Chroicocephalus serranus',
                BiodiversitySpecies.Category.AVES,
                '3,200 - 4,700 m s.n.m.',
                BiodiversitySpecies.ConservationStatus.PREOCUPACION_MENOR,
                False,
                'Ave acuática de capuchón negro en época reproductiva. Habita y anida en las orillas de la Laguna Huascacocha.',
                'Controladora de larvas de insectos acuáticos y bioindicadora de la calidad hídrica de las lagunas glaciares.',
                'No ingresar con mascotas sueltas que puedan perturbar los nidos en los totorales y orillas.',
                5
            ),
            (
                'Vicuña Altoandina',
                'Wik\'uña',
                'Vicugna vicugna',
                BiodiversitySpecies.Category.ENDEMICAS,
                '3,700 - 4,900 m s.n.m.',
                BiodiversitySpecies.ConservationStatus.PREOCUPACION_MENOR,
                True,
                'Camélido silvestre símbolo nacional del Perú. Posee la fibra animal más fina y cotizada del planeta.',
                'Pasta sin arrancar las raíces gracias a sus almohadillas plantares y dientes de crecimiento continuo, protegiendo el suelo de la erosión.',
                'Mantener una distancia mínima de 50 metros. Evitar movimientos bruscos que provoquen estampidas.',
                6
            ),
        ]
        for name, qname, sname, cat, alt, stat, endm, summ, eco, ctip, ord in species_data:
            BiodiversitySpecies.objects.update_or_create(
                scientific_name=sname,
                defaults={
                    'name': name,
                    'quechua_name': qname,
                    'category': cat,
                    'altitude_range': alt,
                    'conservation_status': stat,
                    'is_endemic': endm,
                    'summary': summ,
                    'ecological_role': eco,
                    'conservation_tip': ctip,
                    'order': ord,
                    'is_active': True,
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(species_data)} especies de biodiversidad cargadas'))

        # 7. Estaciones Meteorológicas de Montaña
        stations_data = [
            (
                'Pueblo de Huachón', 3400, 14.0, 4.0, 'Parcialmente Nublado', 'wb_cloudy',
                12.0, 20.0, 13.0, 8.5, 'Muy Alto', 62, 690,
                MountainWeatherStation.RiskLevel.BAJO,
                'Clima templado andino. Aclimatación ideal antes de subir a campamentos de altura.', 1
            ),
            (
                'Pampa Chichuraque', 3850, 10.0, 1.0, 'Soleado con Viento', 'air',
                22.0, 35.0, 8.0, 10.2, 'Muy Alto', 50, 640,
                MountainWeatherStation.RiskLevel.MODERADO,
                'Vientos secos de puna. Usar cortaviento y protector labial hidratante.', 2
            ),
            (
                'Laguna Huascacocha', 4250, 6.0, -3.0, 'Despejado / Frío Intenso', 'ac_unit',
                28.0, 45.0, 2.0, 12.8, 'Extremo (11+)', 42, 600,
                MountainWeatherStation.RiskLevel.HELADAS,
                '⚠️ Heladas bajo cero a partir de las 18:00 hrs. Bolsa de dormir confort -10°C obligatoria para pernoctar.', 3
            ),
            (
                'Mirador Glaciar', 4680, 2.0, -7.0, 'Nieve y Escarcha', 'severe_cold',
                38.0, 60.0, -4.0, 14.5, 'Extremo Albedo', 35, 560,
                MountainWeatherStation.RiskLevel.EXTREMO,
                '⚡ Radiación amplificada por nieve (+80% albedo). Lentes UV400 Cat 4 de alta montaña indispensables.', 4
            ),
            (
                'Cumbre Nevado Huaguruncho', 5742, -4.0, -16.0, 'Ventisca y Hielo Glaciar', 'thunderstorm',
                55.0, 90.0, -18.0, 16.0, 'Extremo Glaciar', 25, 490,
                MountainWeatherStation.RiskLevel.VENTISCA,
                '🚨 Zona técnica de alta montaña. Prohibido ascender sin equipo técnico de hielo, cuerdas y crampones.', 5
            ),
        ]
        for name, alt, td, tn, cond, ico, w, wg, wc, uv, uvl, hum, pres, risk, adv, ord in stations_data:
            MountainWeatherStation.objects.update_or_create(
                name=name,
                defaults={
                    'altitude_masl': alt,
                    'temp_day_celsius': td,
                    'temp_night_celsius': tn,
                    'condition': cond,
                    'weather_icon': ico,
                    'wind_kmh': w,
                    'wind_gusts_kmh': wg,
                    'wind_chill_celsius': wc,
                    'uv_index': uv,
                    'uv_level': uvl,
                    'humidity_percentage': hum,
                    'pressure_hpa': pres,
                    'risk_level': risk,
                    'alert_advisory': adv,
                    'order': ord,
                    'is_active': True,
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(stations_data)} estaciones meteorológicas cargadas'))

        # 8. Alerta Meteorológica de Montaña
        WeatherAlert.objects.update_or_create(
            title='Descenso Térmico y Heladas en Laguna Huascacocha',
            defaults={
                'severity': WeatherAlert.Severity.PRECAUCION,
                'description': 'Masa de aire frío de alta cordillera provocará heladas severas (-3°C a -7°C) entre las 18:00 y las 06:00 horas en sectores sobre los 4,000 msnm.',
                'affected_sector': 'Sectores Laguna Huascacocha y Mirador Glaciar (4,200 - 4,700 msnm)',
                'valid_from': timezone.now(),
                'valid_until': timezone.now() + timedelta(days=3),
                'is_active': True,
            }
        )

        # 9. Audioguías y Relatos Culturales Bilingües
        audio_guides_data = [
            (
                'La Leyenda del Apu Huaguruncho',
                'Apu Wajuruncho Willakuy',
                AudioGuide.Category.MITOLOGIA,
                'Mirador Principal 5,742m',
                '3:45 min',
                'Cuentan los abuelos de Huachón que el Apu Huaguruncho es el guerrero gigante que protege la cordillera oriental de Pasco. Su manto de nieve perpetua purifica las nubes que vienen de la selva central, convirtiéndolas en ríos cristalinos que dan vida a los valles.',
                'Huachón runakunam willakunku: Apu Wajurunchoqa ancha hatun awqaqmi, Pasco suyuta kuyaqmi. Riti pachanmi sach\'a-sach\'amanta hamuq pukutayta chuqyachin, mayukunaman tukuchispa allpa kawsayta quspan.',
                '• Apu: Deidad tutelar de las altas montañas.\n• Riti: Nieve sagrada perpetua.\n• Awqaq: Guerrero defensor de la tierra.',
                1
            ),
            (
                'El Espejo Sagrado de Huascacocha',
                'Waskaqucha Ch\'uya Qucha',
                AudioGuide.Category.HIDROLOGIA,
                'Laguna Huascacocha 4,250m',
                '4:10 min',
                'La laguna Huascacocha refleja las cumbres afiladas del nevado. Los antiguos pobladores depositaban ofrendas de coca y plata para pedir cosechas fértiles y abundante agua para su ganado en los pastizales de altura.',
                'Waskaquchaqa rit\'i urqukunatam kancharichin. Ñawpa runakunam kuka kintuta quchaman kumpaykuqku allin tarpuykunata mañakuspa.',
                '• Qucha: Laguna de alta montaña.\n• Kuka Kintu: Tres hojas selectas de coca para agradecimiento a la Pachamama.',
                2
            ),
            (
                'El Secreto de la Puya Raimondi',
                'Tinkaq Puya Raymundi',
                AudioGuide.Category.FLORA_FAUNA,
                'Quebrada Chichuraque',
                '3:20 min',
                'Conocida como "Tinkaq", la Puya Raimondi es la reina de las plantas andinas. Espera pacientemente hasta un siglo para erigir un cirio floral de 10 metros de altura antes de esparcir millones de semillas al viento.',
                'Tinkaq nisqaqa urqukunapa qillqanmi. Pachak watata suyaspa hatun waytata hatarichin, chaymantataq murukunata wayraman kacharin.',
                '• Tinkaq: Nombre tradicional pasqueño de la Puya Raimondi.\n• Wayta: Flor de las alturas.',
                3
            ),
        ]
        for tes, tqu, cat, loc, dur, res, rqu, glo, ord in audio_guides_data:
            AudioGuide.objects.update_or_create(
                title_es=tes,
                defaults={
                    'title_qu': tqu,
                    'category': cat,
                    'location_name': loc,
                    'duration_formatted': dur,
                    'transcript_es': res,
                    'transcript_qu': rqu,
                    'didactic_glossary': glo,
                    'order': ord,
                    'is_active': True,
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(audio_guides_data)} audioguías bilingües cargadas'))

        # 10. Directorio de Servicios Comunitarios de Huachón
        services_data = [
            (
                'Asociación de Guías Oficiales de Huachón',
                CommunityService.ServiceCategory.GUIA,
                '+51 963 111 222',
                '+51 963 111 222',
                'Plaza Mayor de Huachón s/n',
                'S/ 120 - S/ 180 por día de guiado',
                'DIRCETUR Acreditado',
                '12 años guiando en el Nevado Huaguruncho',
                'Guiado profesional a Laguna Huascacocha, Mirador Glaciar, escalada en roca y observación de flora/fauna con enfoque No Deje Rastro.',
                1
            ),
            (
                'Red de Arrieros "Caballos de la Cordillera"',
                CommunityService.ServiceCategory.ARRIERO,
                '+51 945 333 444',
                '+51 945 333 444',
                'Comunidad Campesina de Huachón y Quiparacra',
                'S/ 50 por mula/caballo de carga',
                'Comunal Oficial',
                'Pobladores locales de Huachón',
                'Alquiler de mulas y caballos para traslado de mochilas pesadas, equipos de campamento y auxilio en senderos empinados.',
                2
            ),
            (
                'Albergue Comunitario "Nevado Huaguruncho"',
                CommunityService.ServiceCategory.HOSPEDAJE,
                '+51 980 555 666',
                '+51 980 555 666',
                'Jr. Pasco 104, a 2 cuadras de la Plaza de Huachón',
                'S/ 35 - S/ 60 por noche',
                'Agua Caliente y Desayuno Andino',
                'Emprendimiento familiar comunal',
                'Habitaciones abrigadas con frazadas de pura lana de oveja, zona de secado de ropa de trekking y mate de muña de bienvenida.',
                3
            ),
            (
                'Zona de Campamento Huascacocha Eco-Lodge',
                CommunityService.ServiceCategory.CAMPAMENTO,
                '+51 955 777 888',
                '+51 955 777 888',
                'Orillas de la Laguna Huascacocha (4,250 m)',
                'S/ 20 derecho de carpa',
                'Campamento Seguro LNT',
                'Guardaparques comunales',
                'Área nivelada protegida del viento, letrina ecológica seca, agua de manantial filtrada y fogata comunal designada.',
                4
            ),
            (
                'Comedor Típico "El Sabor del Huaguruncho"',
                CommunityService.ServiceCategory.GASTRONOMIA,
                '+51 977 444 111',
                '+51 977 444 111',
                'Frente a la Municipalidad de Huachón',
                'S/ 15 - S/ 28 por plato',
                'Ingredientes 100% Orgánicos de Altura',
                'Cocineras tradicionales de Huachón',
                'Especialidad en Trucha Frita de laguna con papas nativas, Caldo de Cordero huachino, Pachamanca y mate de hierbas medicinales.',
                5
            ),
        ]
        for name, cat, phone, wa, loc, price, badge, exp, desc, ord in services_data:
            CommunityService.objects.update_or_create(
                name=name,
                defaults={
                    'category': cat,
                    'contact_phone': phone,
                    'whatsapp_number': wa,
                    'location_address': loc,
                    'price_range': price,
                    'badge_text': badge,
                    'experience_years': exp,
                    'services_description': desc,
                    'order': ord,
                    'is_active': True,
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(services_data)} servicios comunitarios cargados'))

        # 11. Contactos de Emergencia SOS
        emergency_data = [
            ('Policía de Alta Montaña (DEPSAM Pasco)', '105', '+51 980 122 345', 'Brigada policial especializada en búsqueda y rescate técnico en glaciares y cordilleras.', 'local_police_rounded', 1),
            ('Centro de Salud Huachón', '063-421111', '+51 063 421111', 'Atención médica de urgencias, balones de oxígeno medicinal y tratamiento de mal agudo de montaña (soroche).', 'medical_services_rounded', 2),
            ('Serenazgo y Seguridad Ciudadana Huachón', '+51 963 888 123', '+51 963 888 123', 'Patrullaje rural constante y coordinación inmediata con la red de guías y arrieros locales.', 'shield_rounded', 3),
            ('Comunidad Campesina de Huachón', '+51 945 678 901', '+51 945 678 901', 'Red de arrieros y pobladores para apoyo de auxilio y evacuación a lomo de caballo.', 'people_alt_rounded', 4),
        ]
        for title, sph, fnum, desc, ico, pord in emergency_data:
            EmergencyContact.objects.update_or_create(
                title=title,
                defaults={
                    'short_phone': sph,
                    'full_number': fnum,
                    'description': desc,
                    'icon': ico,
                    'priority_order': pord,
                    'is_active': True,
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(emergency_data)} contactos de emergencia cargados'))

        # 12. Muro Comunitario de Centinelas
        posts_data = [
            (
                'Valeria Mendoza',
                'Guardián Glacial Nivel II',
                CommunityPost.PostCategory.FOTOGRAFIA,
                'Laguna Huascacocha (4,250 m)',
                'El amanecer sobre el espejo turquesa de Huascacocha no tiene comparación. El viento estuvo calmo a las 6:30 AM y el reflejo de la pared sur del nevado fue perfecto. ¡Recuerden traer guantes térmicos, la escarcha es densa a esa hora!',
                34, True, True
            ),
            (
                'Carlos Alania (Guía Local)',
                'Guía Oficial DIRCETUR Huachón',
                CommunityPost.PostCategory.AVISTAMIENTOS,
                'Quebrada Chichuraque',
                '¡Hoy avistamos una pareja de cóndores andinos planeando en las corrientes térmicas sobre el rodal de Puyas Raimondi! Los turistas mantuvieron total silencio y distancia de 200m. Una experiencia inolvidable.',
                58, True, True
            ),
            (
                'Brigada Juvenil Huachón',
                'Centinela Ambiental',
                CommunityPost.PostCategory.ACCION_ECOLOGICA,
                'Sendero Pueblo - Pampa',
                'Completamos la jornada comunal de señalización con estacas de madera nativa y recolección de micro-plásticos en el primer tramo. Invitamos a todos los visitantes a regresar con sus residuos en la mochila.',
                89, True, True
            ),
            (
                'Martín Silva',
                'Montañista Explorador',
                CommunityPost.PostCategory.CONSEJOS,
                'Mirador Glaciar (4,680 m)',
                'Recomiendo iniciar el ascenso desde Huachón a más tardar a las 7:00 AM para llegar al mirador con sol despejado antes de que suba la niebla de la selva a las 14:00 hrs. Llevar bastones para el descenso de morrenas.',
                42, True, True
            ),
        ]
        for aname, arole, pcat, loc, cont, mun, lnt, appr in posts_data:
            CommunityPost.objects.update_or_create(
                author_name=aname,
                location_name=loc,
                defaults={
                    'author_role': arole,
                    'category': pcat,
                    'content': cont,
                    'munay_count': mun,
                    'lnt_verified': lnt,
                    'is_approved': appr,
                    'is_active': True,
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(posts_data)} publicaciones comunitarias cargadas'))

        # 13. Paquete Offline
        update_or_create_offline_package(route)
        self.stdout.write(self.style.SUCCESS('✔ Manifiesto de Paquete Offline regenerado'))

        # 14. Gamificación: Medallas y Logros Ecológicos
        badges_data = [
            (
                'caminante-lnt',
                'Caminante No Deje Rastro (LNT)',
                'Allin Purikuy',
                'Completar la lectura de normas de sostenibilidad y descargar la ruta para uso offline.',
                GuardianBadge.BadgeTier.BRONCE,
                'eco',
                50,
                1
            ),
            (
                'centinela-ambiental',
                'Centinela Ambiental de Huachón',
                'Huachón Pachamama Waqaychaq',
                'Emitir un reporte ambiental georreferenciado verificado por la comunidad.',
                GuardianBadge.BadgeTier.PLATA,
                'verified_user',
                100,
                2
            ),
            (
                'explorador-huascacocha',
                'Explorador de Huascacocha',
                'Huascacocha Taripaq',
                'Llegar al campamento base de la laguna y completar el avistamiento de aves altoandinas.',
                GuardianBadge.BadgeTier.ORO,
                'water_drop',
                200,
                3
            ),
            (
                'apu-guardian-glacial',
                'Apu Guardián Glacial Huaguruncho',
                'Huaguruncho Hatun Guardián',
                'Alcanzar el Mirador del Glaciar a 4,680 m s.n.m., escuchar las audioguías en quechua y compartir tu testimonio.',
                GuardianBadge.BadgeTier.DIAMANTE,
                'military_tech',
                500,
                4
            ),
        ]
        for bslug, btitle, bqtitle, bdesc, btier, bicon, bxp, bord in badges_data:
            GuardianBadge.objects.update_or_create(
                slug=bslug,
                defaults={
                    'title': btitle,
                    'quechua_title': bqtitle,
                    'description': bdesc,
                    'tier': btier,
                    'icon': bicon,
                    'xp_points': bxp,
                    'order': bord,
                    'is_active': True,
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(badges_data)} medallas de Guardián Glacial cargadas'))

        # 15. Gamificación: Sellos de Pasaporte de Montaña con Coordenadas GPS Satelitales
        stamps_data = [
            ('Sello Plaza Mayor de Huachón', 'Huachón Hatun Kancha Sello', 3400, -10.605120, -75.952130, 'location_city', 'STAMP-HUA-3400', 1),
            ('Sello Pampa Chichuraque', 'Chichuraque Pampa Sello', 3850, -10.582300, -75.965400, 'forest', 'STAMP-CHI-3850', 2),
            ('Sello Laguna Huascacocha', 'Huascacocha Qucha Sello', 4250, -10.551240, -75.981450, 'waves', 'STAMP-HUA-4250', 3),
            ('Sello Mirador Glaciar Huaguruncho', 'Huaguruncho Riti Qhawana Sello', 4680, -10.528930, -75.992810, 'terrain', 'STAMP-GLA-4680', 4),
            ('Sello Cumbre Sagrada Huaguruncho', 'Huaguruncho Apu Umalliq Sello', 5742, -10.518000, -75.988000, 'ac_unit', 'STAMP-CUM-5742', 5),
        ]
        for sname, sqname, salt, slat, slon, sicon, scode, sord in stamps_data:
            TrailPassportStamp.objects.update_or_create(
                route=route,
                name=sname,
                defaults={
                    'quechua_name': sqname,
                    'altitude_masl': salt,
                    'latitude': slat,
                    'longitude': slon,
                    'landmark_icon': sicon,
                    'secret_code': scode,
                    'order': sord,
                    'is_active': True,
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(stamps_data)} sellos del Pasaporte de Montaña con GPS cargados'))

        # 16. Reportes Ambientales de Prueba
        EnvironmentalReport.objects.update_or_create(
            local_uuid='seed-demo-report-001',
            defaults={
                'user': guide_user,
                'route': route,
                'category': EnvironmentalReport.Category.BASURA,
                'description': 'Presencia de botellas descartables y envolturas plásticas en la zona de descanso de la laguna.',
                'latitude': -10.551300,
                'longitude': -75.981500,
                'accuracy_meters': 3.5,
                'status': EnvironmentalReport.Status.RECIBIDO,
                'captured_at': timezone.now(),
            }
        )
        EnvironmentalReport.objects.update_or_create(
            local_uuid='seed-demo-report-002',
            defaults={
                'user': admin_user,
                'route': route,
                'category': EnvironmentalReport.Category.SENALIZACION,
                'description': 'Poste indicador de desvío hacia el mirador con señalética desgastada por la lluvia.',
                'latitude': -10.535000,
                'longitude': -75.989000,
                'accuracy_meters': 5.0,
                'status': EnvironmentalReport.Status.EN_REVISION,
                'captured_at': timezone.now(),
            }
        )
        self.stdout.write(self.style.SUCCESS('✔ Eco-reportes ambientales de prueba creados'))

        # 17. Avisos Oficiales y Comunicados de la Municipalidad Distrital de Huachón
        notices_data = [
            (
                'Mantenimiento Preventivo Vía Huachón – Pampa Chichuraque',
                'Paso restringido de 07:00 a 12:00 hrs por perfilado de vía y afirmado.',
                MunicipalNotice.Category.VIAL,
                MunicipalNotice.Priority.ALTA,
                'Gerencia de Infraestructura y Transporte Huachón',
                'warning_amber',
                'La Municipalidad Distrital de Huachón informa a los operadores turísticos, transportistas y visitantes que se ejecutan trabajos de perfilado y afirmado en el tramo comprendido entre Huachón y Pampa Chichuraque. Se recomienda transitar con precaución y respetar la señalización de los operarios de maquinaria pesada.',
                'Vehículos 4x4 recomendados. Salidas sugeridas antes de las 06:30 hrs o después de las 13:00 hrs.'
            ),
            (
                'Apertura de Nuevas Salidas Guiadas a Lagunas Glaciares',
                'Tarifas promocionales con 20% de descuento comunal este fin de semana.',
                MunicipalNotice.Category.TURISMO,
                MunicipalNotice.Priority.INFORMATIVO,
                'Oficina de Turismo y Desarrollo Económico Huachón',
                'local_offer',
                'En coordinación con la Asociación de Guías y Arrieros de Huachón y la DIRCETUR Pasco, se habilitan nuevas salidas guiadas hacia la Laguna Huascacocha y Mirador Huaguruncho con un 20% de descuento comunal para promover el turismo sostenible.',
                'Contratar únicamente guías acreditados con carnet DIRCETUR. Incluye servicio de acémilas y botiquín de altura.'
            ),
            (
                'Jornada Comunal de Conservación de Puya Raimondi',
                'Campaña ambiental "Huaguruncho Limpio" con guardaparques y voluntarios.',
                MunicipalNotice.Category.CONSERVACION,
                MunicipalNotice.Priority.COMUNITARIO,
                'Subgerencia de Medio Ambiente y Recursos Naturales',
                'eco',
                'Convocatoria abierta a comuneros y montañistas voluntarios para la jornada de recojo de residuos y delimitación de senderos en los rodales de Puya Raimondi en la quebrada de Huachón.',
                'Llevar guantes de protección y calzado adecuado. Punto de encuentro: Plaza Principal de Huachón a las 08:00 AM.'
            ),
            (
                'Alerta de Heladas Nocturnas (-5°C) en Zonas Glaciares',
                'Defensa Civil y COEL recomiendan pernoctar sólo en campamentos autorizados.',
                MunicipalNotice.Category.CLIMA,
                MunicipalNotice.Priority.PRECAUCION,
                'Centro de Operaciones de Emergencia Huachón (COEL)',
                'ac_unit',
                'Se pronostica descenso térmico extremo en altitudes superiores a los 4,000 m s.n.m. Es obligatorio el porte de equipo térmico de 3 capas, crampones y carpa 4 estaciones para campamento de montaña.',
                'Registrar su expedición en la garita de turismo de Huachón antes de iniciar el ascenso hacia el nevado.'
            ),
        ]

        for ntitle, nsub, ncat, nprio, ndept, nicon, nfull, nrec in notices_data:
            MunicipalNotice.objects.update_or_create(
                title=ntitle,
                defaults={
                    'subtitle': nsub,
                    'category': ncat,
                    'priority': nprio,
                    'department': ndept,
                    'icon': nicon,
                    'full_text': nfull,
                    'recommendations': nrec,
                    'published_at': timezone.now(),
                    'is_active': True,
                }
            )
        self.stdout.write(self.style.SUCCESS(f'✔ {len(notices_data)} avisos de la Municipalidad de Huachón cargados'))

        # 18. Limpieza de expediciones piloto de prueba
        TrekkingExpedition.objects.filter(
            tourist_name='Carlos Mendoza Quispe',
            emergency_contact_name__icontains='María Mendoza',
        ).delete()
        self.stdout.write(self.style.SUCCESS('✔ Bitácora COEL lista (sin expediciones simuladas)'))

        # 19. Reseñas y Calificaciones de Servicios Comunitarios
        first_service = CommunityService.objects.first()
        if first_service:
            CommunityServiceReview.objects.update_or_create(
                service=first_service,
                author_name='Valeria Mendoza',
                defaults={
                    'rating': 5,
                    'comment': 'Excelente servicio de guía hacia la laguna Huascacocha. Carlos conoce cada rincón del nevado, llevó oxígeno portátil y nos contó historias fascinantes sobre el Apu.',
                    'is_approved': True,
                }
            )
            CommunityServiceReview.objects.update_or_create(
                service=first_service,
                author_name='Rodrigo Alarcón',
                defaults={
                    'rating': 5,
                    'comment': 'Muy puntual y las mulas de carga facilitaron muchísimo el ascenso con carpas pesadas. Totalmente recomendado para montañistas.',
                    'is_approved': True,
                }
            )
            self.stdout.write(self.style.SUCCESS(f'✔ Reseñas comunitarias cargadas para {first_service.name}'))

        self.stdout.write(self.style.SUCCESS('=== SEED DATA COMPLETADO CON ÉXITO ==='))

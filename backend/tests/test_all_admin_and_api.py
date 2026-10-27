from datetime import timedelta
from django.test import TestCase, Client
from django.urls import reverse
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient
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
)
from apps.environmental_reports.models import EnvironmentalReport, ReportEvidence
from apps.offline_packages.models import OfflinePackage

User = get_user_model()


class ComprehensiveAdminAndAPITests(TestCase):
    def setUp(self):
        self.api_client = APIClient()
        self.admin_client = Client()

        # Admin user
        self.admin_user = User.objects.create_superuser(
            email='admin@test.pe',
            password='TestPassword123!',
            full_name='Admin Test'
        )
        self.admin_client.force_login(self.admin_user)

        # Standard tourist user
        self.tourist_user = User.objects.create_user(
            email='turista@test.pe',
            password='TestPassword123!',
            full_name='Turista Test',
            role=User.Role.TURISTA
        )

        # Base Route
        self.route = Route.objects.create(
            name='Ruta Huaguruncho Test',
            slug='ruta-huaguruncho-test',
            description='Descripción test',
            difficulty=Route.Difficulty.MODERADA,
            distance_km=14.5,
            estimated_duration_minutes=360,
            is_active=True
        )

        # Scene and POI
        self.scene = TourScene.objects.create(
            route=self.route,
            title='Escena Test',
            sequence=1,
            latitude=-10.551240,
            longitude=-75.981450,
            is_active=True
        )
        self.poi = PointOfInterest.objects.create(
            route=self.route,
            name='Laguna Huascacocha Test',
            category=PointOfInterest.POICategory.LAGUNA,
            altitude_masl=4250,
            latitude=-10.551240,
            longitude=-75.981450,
            is_active=True
        )

        # Species
        self.species = BiodiversitySpecies.objects.create(
            name='Puya Raimondi Test',
            quechua_name='Tinkaq',
            scientific_name='Puya raimondii Harms Test',
            category=BiodiversitySpecies.Category.FLORA,
            conservation_status=BiodiversitySpecies.ConservationStatus.PELIGRO,
            is_endemic=True,
            summary='Resumen test',
            is_active=True
        )

        # Weather Station
        self.weather_station = MountainWeatherStation.objects.create(
            name='Estación Huascacocha Test',
            altitude_masl=4250,
            temp_day_celsius=6.0,
            temp_night_celsius=-3.0,
            wind_kmh=28.0,
            risk_level=MountainWeatherStation.RiskLevel.HELADAS,
            is_active=True
        )

        # Weather Alert
        self.alert = WeatherAlert.objects.create(
            title='Alerta Heladas Test',
            severity=WeatherAlert.Severity.PRECAUCION,
            description='Detalle de alerta',
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=2),
            is_active=True
        )

        # Audio Guide
        self.audio_guide = AudioGuide.objects.create(
            title_es='Leyenda del Apu Test',
            title_qu='Apu Willakuy Test',
            category=AudioGuide.Category.MITOLOGIA,
            location_name='Mirador Test',
            duration_formatted='3:30 min',
            transcript_es='Transcripción español test',
            transcript_qu='Transcripción quechua test',
            is_active=True
        )

        # Community Service
        self.service = CommunityService.objects.create(
            name='Guías Huachón Test',
            category=CommunityService.ServiceCategory.GUIA,
            contact_phone='+51963111222',
            whatsapp_number='+51963111222',
            services_description='Servicios de guiado',
            is_active=True
        )

        # Emergency Contact
        self.emergency = EmergencyContact.objects.create(
            title='Policía de Montaña Test',
            short_phone='105',
            full_number='+51980122345',
            description='Rescate en montaña',
            priority_order=1,
            is_active=True
        )

        # Community Post
        self.post = CommunityPost.objects.create(
            author_name='Valeria Test',
            location_name='Laguna Test',
            content='Amanecer increíble',
            munay_count=10,
            lnt_verified=True,
            is_approved=True,
            is_active=True
        )

        # Environmental Report
        self.report = EnvironmentalReport.objects.create(
            local_uuid='test-admin-env-report-01',
            user=self.tourist_user,
            route=self.route,
            category=EnvironmentalReport.Category.BASURA,
            description='Botellas encontradas',
            latitude=-10.551300,
            longitude=-75.981500,
            status=EnvironmentalReport.Status.RECIBIDO
        )

    # 1. Tests de Vistas del Django Admin
    def test_admin_changelist_views_load_successfully(self):
        admin_urls = [
            '/admin/tourism/route/',
            '/admin/tourism/tourscene/',
            '/admin/tourism/hotspot/',
            '/admin/tourism/pointofinterest/',
            '/admin/tourism/safetyrecommendation/',
            '/admin/tourism/biodiversityspecies/',
            '/admin/tourism/mountainweatherstation/',
            '/admin/tourism/weatheralert/',
            '/admin/tourism/audioguide/',
            '/admin/tourism/communityservice/',
            '/admin/tourism/emergencycontact/',
            '/admin/tourism/communitypost/',
            '/admin/environmental_reports/environmentalreport/',
            '/admin/environmental_reports/reportevidence/',
            '/admin/accounts/user/',
            '/admin/offline_packages/offlinepackage/',
        ]
        for url in admin_urls:
            response = self.admin_client.get(url)
            self.assertEqual(
                response.status_code,
                status.HTTP_200_OK,
                f"Error al cargar vista admin: {url}"
            )

    def test_admin_change_form_views_load_successfully(self):
        form_urls = [
            f'/admin/tourism/route/{self.route.id}/change/',
            f'/admin/tourism/tourscene/{self.scene.id}/change/',
            f'/admin/tourism/pointofinterest/{self.poi.id}/change/',
            f'/admin/tourism/biodiversityspecies/{self.species.id}/change/',
            f'/admin/tourism/mountainweatherstation/{self.weather_station.id}/change/',
            f'/admin/tourism/audioguide/{self.audio_guide.id}/change/',
            f'/admin/tourism/communityservice/{self.service.id}/change/',
            f'/admin/tourism/emergencycontact/{self.emergency.id}/change/',
            f'/admin/tourism/communitypost/{self.post.id}/change/',
            f'/admin/environmental_reports/environmentalreport/{self.report.id}/change/',
        ]
        for url in form_urls:
            response = self.admin_client.get(url)
            self.assertEqual(
                response.status_code,
                status.HTTP_200_OK,
                f"Error al cargar formulario de edición admin: {url}"
            )

    # 2. Tests de Endpoints de la API REST
    def test_api_biodiversity_list_and_detail(self):
        url = reverse('api-v1:tourism:biodiversity-list')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) >= 1)
        self.assertEqual(response.data[0]['name'], 'Puya Raimondi Test')
        self.assertEqual(response.data[0]['quechua_name'], 'Tinkaq')

        detail_url = reverse('api-v1:tourism:biodiversity-detail', kwargs={'uuid': self.species.uuid})
        detail_res = self.api_client.get(detail_url)
        self.assertEqual(detail_res.status_code, status.HTTP_200_OK)
        self.assertEqual(detail_res.data['scientific_name'], 'Puya raimondii Harms Test')

    def test_api_weather_stations_and_alerts(self):
        url = reverse('api-v1:tourism:weather-stations-list')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) >= 1)
        self.assertEqual(response.data[0]['name'], 'Estación Huascacocha Test')
        self.assertEqual(response.data[0]['risk_level'], 'heladas')

        alerts_url = reverse('api-v1:tourism:weather-alerts-list')
        alerts_res = self.api_client.get(alerts_url)
        self.assertEqual(alerts_res.status_code, status.HTTP_200_OK)
        self.assertTrue(len(alerts_res.data) >= 1)

    def test_api_audio_guides_list_and_detail(self):
        url = reverse('api-v1:tourism:audio-guides-list')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) >= 1)
        self.assertEqual(response.data[0]['title_es'], 'Leyenda del Apu Test')
        self.assertEqual(response.data[0]['title_qu'], 'Apu Willakuy Test')

    def test_api_community_services_list(self):
        url = reverse('api-v1:tourism:community-services-list')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) >= 1)
        self.assertEqual(response.data[0]['name'], 'Guías Huachón Test')

    def test_api_emergency_contacts_list(self):
        url = reverse('api-v1:tourism:emergency-contacts-list')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) >= 1)
        self.assertEqual(response.data[0]['short_phone'], '105')

    def test_api_community_posts_list_and_create(self):
        url = reverse('api-v1:tourism:community-posts-list')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['results']) >= 1)

        # Crear nuevo post (requiere usuario autenticado)
        create_payload = {
            'author_name': 'Turista Nuevo',
            'location_name': 'Mirador Glaciar',
            'category': CommunityPost.PostCategory.CONSEJOS,
            'content': 'Llevar bastones de trekking',
        }
        unauth_res = self.api_client.post(url, create_payload, format='json')
        self.assertEqual(unauth_res.status_code, status.HTTP_401_UNAUTHORIZED)

        self.api_client.force_authenticate(user=self.tourist_user)
        create_res = self.api_client.post(url, create_payload, format='json')
        self.assertEqual(create_res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(create_res.data['author_name'], 'Turista Nuevo')

    def test_api_points_of_interest_list(self):
        url = reverse('api-v1:tourism:points-of-interest-list')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) >= 1)
        self.assertEqual(response.data[0]['name'], 'Laguna Huascacocha Test')

    # 3. Tests del Parser GPX de Wikiloc y Tour 360 Studio
    def test_gpx_parser_utility(self):
        from apps.tourism.utils.gpx_parser import parse_gpx_content

        sample_gpx = """<?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Wikiloc - https://www.wikiloc.com" xmlns="http://www.topografix.com/GPX/1/1">
          <wpt lat="-10.605120" lon="-75.952130">
            <ele>3400.0</ele>
            <name>Pueblo Huachon</name>
            <desc>Inicio de ruta</desc>
          </wpt>
          <trk>
            <name>Sendero Huaguruncho Wikiloc</name>
            <trkseg>
              <trkpt lat="-10.605120" lon="-75.952130"><ele>3400.0</ele></trkpt>
              <trkpt lat="-10.582300" lon="-75.965400"><ele>3850.0</ele></trkpt>
              <trkpt lat="-10.551240" lon="-75.981450"><ele>4250.0</ele></trkpt>
            </trkseg>
          </trk>
        </gpx>"""

        res = parse_gpx_content(sample_gpx)
        self.assertTrue(res['success'])
        self.assertEqual(res['point_count'], 3)
        self.assertEqual(res['min_altitude_m'], 3400.0)
        self.assertEqual(res['max_altitude_m'], 4250.0)
        self.assertEqual(res['elevation_gain_m'], 850.0)
        self.assertEqual(len(res['waypoints']), 1)
        self.assertEqual(res['waypoints'][0]['name'], 'Pueblo Huachon')
        self.assertEqual(res['geojson_track']['type'], 'Feature')

    def test_api_upload_gpx(self):
        url = reverse('api-v1:tourism:routes-upload-gpx', kwargs={'uuid': self.route.uuid})
        sample_gpx = """<?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Wikiloc" xmlns="http://www.topografix.com/GPX/1/1">
          <trk>
            <trkseg>
              <trkpt lat="-10.605120" lon="-75.952130"><ele>3400.0</ele></trkpt>
              <trkpt lat="-10.551240" lon="-75.981450"><ele>4250.0</ele></trkpt>
            </trkseg>
          </trk>
        </gpx>"""
        unauth_res = self.api_client.post(url, {'gpx_content': sample_gpx}, format='json')
        self.assertEqual(unauth_res.status_code, status.HTTP_401_UNAUTHORIZED)

        self.api_client.force_authenticate(user=self.admin_user)
        response = self.api_client.post(url, {'gpx_content': sample_gpx}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.route.refresh_from_db()
        self.assertIsNotNone(self.route.geojson_track)
        self.assertEqual(self.route.max_altitude_m, 4250)

    def test_api_studio_data(self):
        url = reverse('api-v1:tourism:routes-studio-data', kwargs={'uuid': self.route.uuid})
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('route', response.data)
        self.assertIn('scenes', response.data)
        self.assertIn('points_of_interest', response.data)

    def test_api_auto_link_street_view(self):
        # Crear segunda escena para probar auto-enlace
        scene2 = TourScene.objects.create(
            route=self.route,
            title='Escena 2 Test',
            sequence=2,
            latitude=-10.551240,
            longitude=-75.981450,
            is_active=True
        )
        url = reverse('api-v1:tourism:routes-auto-link-street-view', kwargs={'uuid': self.route.uuid})
        unauth_res = self.api_client.post(url)
        self.assertEqual(unauth_res.status_code, status.HTTP_401_UNAUTHORIZED)

        self.api_client.force_authenticate(user=self.admin_user)
        response = self.api_client.post(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertTrue(self.scene.hotspots.filter(target_scene=scene2).exists())
        self.assertTrue(scene2.hotspots.filter(target_scene=self.scene).exists())

    def test_admin_studio_view_renders(self):
        url = f'/admin/tourism/route/{self.route.id}/studio/'
        response = self.admin_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertContains(response, 'Tour 360 Studio')
        self.assertContains(response, 'OpenStreetMap')
        self.assertContains(response, 'htmx')

    def test_admin_htmx_scenes_partial(self):
        url = f'/admin/tourism/route/{self.route.id}/studio/scenes/'
        response = self.admin_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertContains(response, 'Escena Test')

    def test_admin_htmx_scene_inspector(self):
        url = f'/admin/tourism/route/{self.route.id}/studio/scene-inspector/{self.scene.uuid}/'
        response = self.admin_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertContains(response, 'Escena Test')
        self.assertContains(response, 'Hotspots en esta escena')

    def test_admin_htmx_update_scene(self):
        url = f'/admin/tourism/route/{self.route.id}/studio/update-scene/{self.scene.uuid}/'
        response = self.admin_client.post(url, {
            'latitude': '-10.5999',
            'longitude': '-75.9555',
            'altitude_masl': '3500',
            'heading': '45.0',
            'description': 'Punto actualizado vía HTMX',
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.scene.refresh_from_db()
        self.assertEqual(self.scene.altitude_masl, 3500)
        self.assertEqual(self.scene.heading, 45.0)

    def test_admin_htmx_auto_link(self):
        scene2 = TourScene.objects.create(
            route=self.route,
            title='Escena 2 Test',
            sequence=2,
            latitude=-10.551240,
            longitude=-75.981450,
            is_active=True
        )
        url = f'/admin/tourism/route/{self.route.id}/studio/auto-link/'
        response = self.admin_client.post(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(self.scene.hotspots.filter(target_scene=scene2).exists())

    def test_admin_htmx_delete_scene(self):
        scene_to_delete = TourScene.objects.create(
            route=self.route,
            title='Escena a borrar',
            sequence=99,
            is_active=True
        )
        url = f'/admin/tourism/route/{self.route.id}/studio/delete-scene/{scene_to_delete.uuid}/'
        response = self.admin_client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(TourScene.objects.filter(uuid=scene_to_delete.uuid).exists())

    def test_offline_package_zip_download(self):
        url = reverse('api-v1:offline_packages:route-offline-download', kwargs={'uuid': self.route.uuid})
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response['Content-Type'], 'application/zip')
        self.assertTrue('attachment;' in response['Content-Disposition'])
        content = b"".join(response.streaming_content) if getattr(response, 'streaming', False) else response.content
        self.assertTrue(len(content) > 0)

    def test_route_export_pdf_endpoint(self):
        url = f'/admin/tourism/route/{self.route.id}/export-pdf/'
        response = self.admin_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response['Content-Type'], 'application/pdf')
        self.assertTrue(len(response.content) > 0)

    def test_api_guardian_badges_list(self):
        from apps.tourism.models import GuardianBadge
        badge = GuardianBadge.objects.create(
            slug='test-badge',
            title='Medalla Test',
            tier=GuardianBadge.BadgeTier.ORO,
            xp_points=150,
            order=1
        )
        url = reverse('api-v1:tourism:badges-list')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) >= 1)

    def test_api_trail_passport_stamps_list(self):
        from apps.tourism.models import TrailPassportStamp
        stamp = TrailPassportStamp.objects.create(
            route=self.route,
            name='Sello Test Huascacocha',
            altitude_masl=4250,
            order=1
        )
        url = reverse('api-v1:tourism:passport-stamps-list')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) >= 1)

    def test_health_check_endpoints(self):
        # 1. Endpoint /health/
        response_root = self.api_client.get(reverse('root-health-check'))
        self.assertEqual(response_root.status_code, status.HTTP_200_OK)
        self.assertEqual(response_root.data['status'], 'ok')
        self.assertEqual(response_root.data['database'], 'operational')
        self.assertEqual(response_root.data['domain'], 'apih.aquienpasco.com')

        # 2. Endpoint /api/v1/health/
        response_v1 = self.api_client.get(reverse('api-v1:health'))
        self.assertEqual(response_v1.status_code, status.HTTP_200_OK)
        self.assertEqual(response_v1.data['status'], 'ok')
        self.assertIn('rust_engine', response_v1.data)

    def test_analytics_overview_endpoint(self):
        url = reverse('api-v1:tourism:analytics-overview')
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tourism', response.data)
        self.assertIn('conservation', response.data)
        self.assertIn('gamification', response.data)
        self.assertIn('engine', response.data)



from django.test import TestCase, Client
from django.urls import reverse
from apps.tourism.models import Route, TourScene, MountainWeatherStation


class LandingPageTests(TestCase):
    def setUp(self):
        self.client = Client()
        # Crear una ruta de prueba
        self.route = Route.objects.create(
            name="Sendero Laguna Huascacocha",
            slug="sendero-laguna-huascacocha",
            description="Hermosa ruta hacia la laguna turquesa del glaciar.",
            difficulty=Route.Difficulty.MODERADA,
            distance_km=9.8,
            estimated_duration_minutes=240,
            elevation_gain_m=850.0,
            max_altitude_m=4250,
            is_active=True,
        )
        self.scene = TourScene.objects.create(
            route=self.route,
            title="Vista Panorámica Huascacocha",
            sequence=1,
            is_active=True,
        )
        self.station = MountainWeatherStation.objects.create(
            name="Estación Huascacocha Test",
            altitude_masl=4250,
            temp_day_celsius=5.0,
            temp_night_celsius=-2.0,
            wind_kmh=15.0,
            is_active=True,
        )

    def test_landing_page_renders_successfully(self):
        """Verifica que la página principal de la landing cargue con código 200 y título correcto."""
        response = self.client.get(reverse('landing:index'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "HUAGURUNCHO")
        self.assertContains(response, "Huaguruncho 360")

    def test_htmx_route_filter_endpoint(self):
        """Verifica el filtrado HTMX de rutas por dificultad."""
        response = self.client.get(reverse('landing:htmx-routes') + '?difficulty=moderada')
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Sendero Laguna Huascacocha")
        
        # Filtro que no coincide
        response_facil = self.client.get(reverse('landing:htmx-routes') + '?difficulty=facil')
        self.assertEqual(response_facil.status_code, 200)
        self.assertContains(response_facil, "No hay rutas para este criterio")

    def test_htmx_safety_advisor_endpoint(self):
        """Verifica el cálculo de altitud y soroche en el asesor de seguridad."""
        response = self.client.post(reverse('landing:htmx-safety-check'), {
            'target_altitude': 4680,
            'experience': 'intermedio',
            'acclimatization_days': 1,
        })
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Telemetría de Oxigenación & Soroche")
        self.assertContains(response, "4680")
        self.assertContains(response, "Riesgo")

    def test_htmx_weather_telemetry_endpoint(self):
        """Verifica la actualización de sensores meteorológicos."""
        response = self.client.get(reverse('landing:htmx-weather-telemetry'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Estación Huascacocha Test")

    def test_htmx_tour_scene_endpoint(self):
        """Verifica el cambio de escena 360 interactiva."""
        response = self.client.get(reverse('landing:htmx-tour-scene') + f'?scene_id={self.scene.id}')
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Vista Panorámica Huascacocha")

    def test_htmx_subscribe_endpoint(self):
        """Verifica la suscripción / descarga anticipada."""
        response = self.client.post(reverse('landing:htmx-subscribe'), {
            'email_or_phone': 'montanista@peru.pe',
            'platform': 'android',
        })
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Acceso Anticipado Activado")
        self.assertContains(response, "montanista@peru.pe")

    def test_htmx_guardian_stamp_endpoint(self):
        """Verifica la simulación de sello en el pasaporte digital."""
        response = self.client.post(reverse('landing:htmx-guardian-stamp'), {
            'stamp_name': 'Cumbre Nevado Huaguruncho',
            'altitude': '5,742 m s.n.m.',
        })
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Cumbre Nevado Huaguruncho")
        self.assertContains(response, "Eco-Puntos")

from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient
from apps.tourism.models import Route, TourScene, Hotspot, SafetyRecommendation


class TourismAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.route = Route.objects.create(
            name='Ruta Laguna Huaguruncho',
            description='Ruta piloto de prueba',
            difficulty=Route.Difficulty.MODERADA,
            distance_km=12.5,
            estimated_duration_minutes=300,
            is_active=True
        )
        self.scene1 = TourScene.objects.create(
            route=self.route,
            title='Escena 1 - Plaza',
            sequence=1,
            is_active=True
        )
        self.scene2 = TourScene.objects.create(
            route=self.route,
            title='Escena 2 - Laguna',
            sequence=2,
            is_active=True
        )
        self.hotspot = Hotspot.objects.create(
            source_scene=self.scene1,
            target_scene=self.scene2,
            type=Hotspot.HotspotType.NAVIGATION,
            yaw=45.0,
            pitch=0.0,
            title='Ir a Laguna'
        )
        self.safety = SafetyRecommendation.objects.create(
            category=SafetyRecommendation.Category.EQUIPAMIENTO,
            title='Llevar abrigo',
            description='Ropa térmica obligatoria',
            order=1,
            is_active=True
        )

    def test_list_routes(self):
        url = reverse('api-v1:tourism:routes-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
        self.assertEqual(response.data['results'][0]['name'], 'Ruta Laguna Huaguruncho')

    def test_get_route_detail(self):
        url = reverse('api-v1:tourism:routes-detail', kwargs={'uuid': self.route.uuid})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['name'], 'Ruta Laguna Huaguruncho')
        self.assertEqual(len(response.data['scenes']), 2)

    def test_get_scene_hotspots(self):
        url = reverse('api-v1:tourism:scenes-hotspots', kwargs={'uuid': self.scene1.uuid})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['title'], 'Ir a Laguna')

    def test_safety_recommendations_list(self):
        url = reverse('api-v1:tourism:safety-recommendations')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['title'], 'Llevar abrigo')

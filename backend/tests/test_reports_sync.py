import uuid
from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APIClient
from apps.environmental_reports.models import EnvironmentalReport
from apps.tourism.models import Route

User = get_user_model()


class EnvironmentalReportSyncTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='turista_report@test.pe',
            password='PasswordSegura123!',
            full_name='Turista Reportero'
        )
        self.client.force_authenticate(user=self.user)
        self.sync_batch_url = reverse('api-v1:environmental_reports:sync-batch')
        self.my_reports_url = reverse('api-v1:environmental_reports:my-reports')

        self.route = Route.objects.create(
            name='Ruta Huaguruncho',
            description='Ruta piloto',
            difficulty=Route.Difficulty.MODERADA,
            distance_km=10.0,
            estimated_duration_minutes=240,
            is_active=True
        )

    def test_sync_batch_creates_new_reports(self):
        local_id_1 = str(uuid.uuid4())
        local_id_2 = str(uuid.uuid4())

        payload = {
            'reports': [
                {
                    'local_uuid': local_id_1,
                    'route_uuid': str(self.route.uuid),
                    'category': 'basura',
                    'description': 'Botellas arrojadas en el camino',
                    'latitude': -10.551234,
                    'longitude': -75.981234,
                    'accuracy_meters': 4.5
                },
                {
                    'local_uuid': local_id_2,
                    'category': 'senalizacion_danada',
                    'description': 'Letrero roto',
                    'latitude': -10.552000,
                    'longitude': -75.982000,
                }
            ]
        }

        response = self.client.post(self.sync_batch_url, payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 2)
        self.assertTrue(response.data['results'][0]['success'])
        self.assertTrue(response.data['results'][1]['success'])
        self.assertEqual(EnvironmentalReport.objects.count(), 2)

    def test_sync_batch_idempotency(self):
        """Verifica que reintentar la sincronización no duplique registros"""
        local_id = str(uuid.uuid4())

        payload = {
            'reports': [
                {
                    'local_uuid': local_id,
                    'category': 'incendio',
                    'description': 'Fogata mal apagada',
                    'latitude': -10.550000,
                    'longitude': -75.980000,
                }
            ]
        }

        # Primera sincronización
        resp1 = self.client.post(self.sync_batch_url, payload, format='json')
        self.assertEqual(resp1.status_code, status.HTTP_200_OK)
        self.assertEqual(EnvironmentalReport.objects.count(), 1)
        first_server_uuid = resp1.data['results'][0]['server_uuid']

        # Segunda sincronización (reintento offline/online)
        resp2 = self.client.post(self.sync_batch_url, payload, format='json')
        self.assertEqual(resp2.status_code, status.HTTP_200_OK)
        self.assertEqual(EnvironmentalReport.objects.count(), 1)  # No se duplicó
        second_server_uuid = resp2.data['results'][0]['server_uuid']

        self.assertEqual(first_server_uuid, second_server_uuid)

    def test_my_reports_endpoint(self):
        EnvironmentalReport.objects.create(
            local_uuid=str(uuid.uuid4()),
            user=self.user,
            category=EnvironmentalReport.Category.BASURA,
            description='Reporte propio'
        )

        response = self.client.get(self.my_reports_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
        self.assertEqual(response.data['results'][0]['description'], 'Reporte propio')

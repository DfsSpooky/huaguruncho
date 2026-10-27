from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APIClient
from apps.environmental_reports.models import EnvironmentalReport
from apps.tourism.models import Route
from apps.offline_packages.services import update_or_create_offline_package

User = get_user_model()


class AdminAndOfflineAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.admin_user = User.objects.create_user(
            email='admin_test@huaguruncho.pe',
            password='PasswordAdmin123!',
            full_name='Admin Test',
            role=User.Role.ADMINISTRADOR,
            is_staff=True
        )
        self.turista_user = User.objects.create_user(
            email='turista_test@huaguruncho.pe',
            password='Password123!',
            full_name='Turista Test',
            role=User.Role.TURISTA
        )
        self.route = Route.objects.create(
            name='Ruta Offline Test',
            description='Prueba de paquete',
            difficulty=Route.Difficulty.FACIL,
            distance_km=5.0,
            estimated_duration_minutes=120,
            is_active=True
        )
        self.report = EnvironmentalReport.objects.create(
            local_uuid='test-admin-report-uuid',
            user=self.turista_user,
            category=EnvironmentalReport.Category.BASURA,
            description='Reporte a ser atendido por admin'
        )

    def test_admin_reports_forbidden_for_regular_user(self):
        self.client.force_authenticate(user=self.turista_user)
        url = reverse('api-v1:environmental_reports:admin-reports-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_admin_reports_accessible_for_admin(self):
        self.client.force_authenticate(user=self.admin_user)
        url = reverse('api-v1:environmental_reports:admin-reports-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_admin_can_update_report_status(self):
        self.client.force_authenticate(user=self.admin_user)
        url = reverse('api-v1:environmental_reports:admin-reports-detail', kwargs={'uuid': self.report.uuid})
        response = self.client.patch(url, {'status': 'atendido', 'admin_notes': 'Basura retirada por cuadrilla'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.report.refresh_from_db()
        self.assertEqual(self.report.status, 'atendido')
        self.assertEqual(self.report.admin_notes, 'Basura retirada por cuadrilla')

    def test_offline_package_endpoint(self):
        update_or_create_offline_package(self.route)
        url = reverse('api-v1:offline_packages:route-offline-package', kwargs={'uuid': self.route.uuid})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('manifest', response.data)
        self.assertEqual(response.data['manifest']['route']['name'], 'Ruta Offline Test')

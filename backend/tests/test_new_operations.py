from datetime import timedelta
from django.utils import timezone
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model
from apps.tourism.models import (
    Route,
    MunicipalNotice,
    TrekkingExpedition,
    CommunityService,
    CommunityServiceReview,
    TrailPassportStamp,
)

User = get_user_model()


class NewOperationsApiTests(APITestCase):
    def setUp(self):
        self.tourist_user = User.objects.create_user(
            email='excursionista@huachon.pe',
            password='TestPassword123!',
            full_name='Juan Pérez',
            phone='+51911223344',
            role=User.Role.TURISTA,
        )
        self.route = Route.objects.create(
            name='Ruta Glaciar Piloto',
            description='Ruta hacia la laguna Huascacocha',
            distance_km=14.5,
            is_active=True
        )
        self.notice = MunicipalNotice.objects.create(
            title='Mantenimiento de Vía Huachón',
            subtitle='Paso restringido matutino',
            category=MunicipalNotice.Category.VIAL,
            priority=MunicipalNotice.Priority.ALTA,
            department='Transportes Huachón',
            full_text='Mantenimiento de vía en ejecución.',
            is_active=True
        )
        self.service = CommunityService.objects.create(
            name='Guías Oficiales Huachón',
            category=CommunityService.ServiceCategory.GUIA,
            contact_phone='+51987654321',
            is_active=True
        )
        self.stamp = TrailPassportStamp.objects.create(
            route=self.route,
            name='Sello Huascacocha',
            altitude_masl=4250,
            latitude=-10.551240,
            longitude=-75.981450,
            order=1,
            is_active=True
        )

    def test_list_municipal_notices(self):
        response = self.client.get('/api/v1/municipal-notices/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        results = response.data['results'] if 'results' in response.data else response.data
        self.assertTrue(len(results) >= 1)
        self.assertEqual(results[0]['title'], 'Mantenimiento de Vía Huachón')
        self.assertIn('category_display', results[0])

    def test_create_and_checkout_expedition(self):
        now = timezone.now()
        payload = {
            'tourist_name': 'Juan Pérez',
            'tourist_phone': '+51911223344',
            'emergency_contact_name': 'Ana Pérez',
            'emergency_contact_phone': '+51955667788',
            'route': self.route.id,
            'group_size': 2,
            'guide_name': 'Guía Local Carlos',
            'departure_datetime': now.isoformat(),
            'expected_return_datetime': (now + timedelta(hours=8)).isoformat(),
            'health_notes': 'Sin condiciones médicas previas.',
            'gear_checklist_verified': True,
        }
        # Unauthenticated request must be rejected
        unauth_res = self.client.post('/api/v1/expeditions/', payload, format='json')
        self.assertEqual(unauth_res.status_code, status.HTTP_401_UNAUTHORIZED)

        self.client.force_authenticate(user=self.tourist_user)
        create_res = self.client.post('/api/v1/expeditions/', payload, format='json')
        self.assertEqual(create_res.status_code, status.HTTP_201_CREATED)
        exp_uuid = create_res.data['uuid']
        self.assertEqual(create_res.data['status'], TrekkingExpedition.Status.EN_CURSO)

        checkout_res = self.client.post(f'/api/v1/expeditions/{exp_uuid}/check-out/')
        self.assertEqual(checkout_res.status_code, status.HTTP_200_OK)
        self.assertEqual(checkout_res.data['status'], 'success')
        self.assertEqual(checkout_res.data['expedition']['status'], TrekkingExpedition.Status.RETORNADA)
        self.assertIsNotNone(checkout_res.data['expedition']['actual_return_datetime'])

    def test_community_service_reviews_and_rating(self):
        payload = {
            'service': self.service.id,
            'author_name': 'Turista Feliz',
            'rating': 5,
            'comment': 'El guía fue excepcional y nos cuidó mucho.',
        }
        unauth_res = self.client.post('/api/v1/service-reviews/', payload, format='json')
        self.assertEqual(unauth_res.status_code, status.HTTP_401_UNAUTHORIZED)

        self.client.force_authenticate(user=self.tourist_user)
        res = self.client.post('/api/v1/service-reviews/', payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

        svc_res = self.client.get(f'/api/v1/community-services/{self.service.uuid}/')
        self.assertEqual(svc_res.status_code, status.HTTP_200_OK)
        self.assertEqual(svc_res.data['average_rating'], 5.0)
        self.assertEqual(svc_res.data['reviews_count'], 1)

    def test_passport_stamp_includes_gps_coordinates(self):
        res = self.client.get(f'/api/v1/passport-stamps/{self.stamp.uuid}/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn('latitude', res.data)
        self.assertIn('longitude', res.data)
        self.assertAlmostEqual(float(res.data['latitude']), -10.551240, places=4)
        self.assertAlmostEqual(float(res.data['longitude']), -75.981450, places=4)

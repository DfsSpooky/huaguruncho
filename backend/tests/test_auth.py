from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APIClient

User = get_user_model()


class AuthAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.register_url = reverse('api-v1:accounts:register')
        self.login_url = reverse('api-v1:accounts:login')
        self.profile_url = reverse('api-v1:accounts:profile')

        self.user_data = {
            'email': 'turista@test.pe',
            'password': 'PasswordSegura123!',
            'full_name': 'Turista de Prueba',
            'phone': '+51987123456'
        }

    def test_register_user_success(self):
        response = self.client.post(self.register_url, self.user_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])
        self.assertIn('refresh', response.data['tokens'])
        self.assertEqual(response.data['user']['email'], 'turista@test.pe')
        self.assertEqual(response.data['user']['role'], 'turista')

    def test_login_user_success(self):
        # Primero crear usuario
        user = User.objects.create_user(
            email='turista@test.pe',
            password='PasswordSegura123!',
            full_name='Turista de Prueba'
        )

        login_data = {
            'email': 'turista@test.pe',
            'password': 'PasswordSegura123!'
        }
        response = self.client.post(self.login_url, login_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])

    def test_profile_authenticated(self):
        user = User.objects.create_user(
            email='turista@test.pe',
            password='PasswordSegura123!',
            full_name='Turista de Prueba'
        )
        self.client.force_authenticate(user=user)
        response = self.client.get(self.profile_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['email'], 'turista@test.pe')

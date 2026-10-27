from unittest.mock import patch
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from apps.tourism.models import MountainWeatherStation, WeatherAlert
from apps.tourism.services.weather_service import (
    interpret_wmo_code,
    sync_weather_stations,
    NEVADO_TEMP_OFFSET_CELSIUS,
)


class WeatherSyncTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_wmo_code_interpretation(self):
        cond, icon = interpret_wmo_code(0)
        self.assertEqual(cond, 'Despejado / Frío Intenso')
        self.assertEqual(icon, 'wb_sunny')

        cond, icon = interpret_wmo_code(71)
        self.assertEqual(cond, 'Nevada Ligera')
        self.assertEqual(icon, 'severe_cold')

        cond, icon = interpret_wmo_code(95)
        self.assertEqual(cond, 'Tormenta Eléctrica')
        self.assertEqual(icon, 'thunderstorm')

    @patch('apps.tourism.services.weather_service.fetch_yanacancha_raw_weather')
    def test_sync_weather_stations_with_nevado_offset(self, mock_fetch):
        # Simular que Yanacancha está exactamente a 5.0 °C como en el ejemplo del usuario
        mock_fetch.return_value = {
            'elevation': 4378.0,
            'current': {
                'temperature_2m': 5.0,
                'relative_humidity_2m': 65,
                'apparent_temperature': 3.0,
                'weather_code': 0,
                'surface_pressure': 610.0,
                'wind_speed_10m': 12.0,
                'wind_gusts_10m': 20.0,
            },
            'daily': {
                'temperature_2m_max': [12.0],
                'temperature_2m_min': [1.0],
                'uv_index_max': [10.0],
            }
        }

        result = sync_weather_stations(force_refresh=True)

        self.assertEqual(result['status'], 'success')
        self.assertEqual(result['stations_count'], 5)
        self.assertEqual(result['base_temperature_yanacancha'], 5.0)

        # En Cumbre Nevado Huaguruncho (Huayruro):
        # Con 5°C en Yanacancha y offset de -5.5°C => -0.5°C
        nevado = MountainWeatherStation.objects.get(name='Cumbre Nevado Huaguruncho')
        self.assertEqual(float(nevado.temp_day_celsius), 5.0 + NEVADO_TEMP_OFFSET_CELSIUS)
        self.assertEqual(nevado.altitude_masl, 5742)

        # En Pueblo de Huachón (+5.0°C respecto a Yanacancha):
        huachon = MountainWeatherStation.objects.get(name='Pueblo de Huachón')
        self.assertEqual(float(huachon.temp_day_celsius), 10.0)

        # En Laguna Huascacocha (-1.5°C respecto a Yanacancha):
        huascacocha = MountainWeatherStation.objects.get(name='Laguna Huascacocha')
        self.assertEqual(float(huascacocha.temp_day_celsius), 3.5)

    def test_api_weather_stations_list_and_refresh(self):
        url = reverse('api-v1:tourism:weather-stations-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

        refresh_url = f"{url}refresh/"
        refresh_resp = self.client.get(refresh_url)
        self.assertEqual(refresh_resp.status_code, 200)
        data = refresh_resp.json()
        self.assertIn('meta', data)
        self.assertIn('stations', data)
        self.assertEqual(len(data['stations']), 5)

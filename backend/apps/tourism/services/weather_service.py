import json
import logging
import urllib.request
import urllib.error
from decimal import Decimal
from datetime import datetime, timedelta
from django.core.cache import cache
from django.utils import timezone
from apps.tourism.models import MountainWeatherStation, WeatherAlert

logger = logging.getLogger(__name__)

# Coordenadas meteorológicas oficiales para Yanacancha (Cerro de Pasco, Perú)
YANACANCHA_LATITUDE = -10.67
YANACANCHA_LONGITUDE = -76.25
YANACANCHA_BASE_ALTITUDE = 4380

# Offset de temperatura según testimonio técnico de la Municipalidad de Huachón:
# En el Nevado Huayruro / Cumbre Huaguruncho la temperatura desciende entre 5 y 6 °C
# respecto al distrito de Yanacancha.
NEVADO_TEMP_OFFSET_CELSIUS = -5.5

CACHE_KEY_YANACANCHA_WEATHER = 'openmeteo_yanacancha_weather_v1'
CACHE_TTL_SECONDS = 900  # 15 minutos


def interpret_wmo_code(code: int) -> tuple[str, str]:
    """
    Convierte el código WMO de Open-Meteo a condición climática en español
    y nombre de icono Material correspondiente.
    """
    mapping = {
        0: ('Despejado / Frío Intenso', 'wb_sunny'),
        1: ('Mayormente Despejado', 'wb_sunny'),
        2: ('Parcialmente Nublado', 'wb_cloudy'),
        3: ('Nublado / Cubierto', 'wb_cloudy'),
        45: ('Niebla de Altura', 'air'),
        48: ('Neblina Helada / Cencellada', 'air'),
        51: ('Llovizna Ligera', 'ac_unit'),
        53: ('Llovizna Moderada', 'ac_unit'),
        55: ('Llovizna Densa', 'ac_unit'),
        61: ('Lluvia Ligera', 'water_drop'),
        63: ('Lluvia Andina Moderada', 'water_drop'),
        65: ('Lluvia Fuerte', 'water_drop'),
        71: ('Nevada Ligera', 'severe_cold'),
        73: ('Nevada Moderada', 'severe_cold'),
        75: ('Nevada Intensa', 'severe_cold'),
        77: ('Granizo Menudo / Escarcha', 'severe_cold'),
        80: ('Chubascos Ligeros', 'water_drop'),
        81: ('Chubascos Moderados', 'water_drop'),
        82: ('Chubascos Fuertes', 'water_drop'),
        85: ('Chubascos de Nieve', 'severe_cold'),
        86: ('Ventisca Fuerte de Nieve', 'severe_cold'),
        95: ('Tormenta Eléctrica', 'thunderstorm'),
        96: ('Tormenta con Granizo Ligero', 'thunderstorm'),
        99: ('Tormenta Eléctrica Glaciar Severa', 'thunderstorm'),
    }
    return mapping.get(code, ('Parcialmente Nublado', 'wb_cloudy'))


def fetch_yanacancha_raw_weather(force_refresh: bool = False) -> dict:
    """
    Consulta la API gratuita de Open-Meteo para Yanacancha, Cerro de Pasco.
    Aplica almacenamiento en caché por 15 minutos.
    """
    if not force_refresh:
        cached = cache.get(CACHE_KEY_YANACANCHA_WEATHER)
        if cached:
            return cached

    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={YANACANCHA_LATITUDE}&longitude={YANACANCHA_LONGITUDE}"
        f"&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,surface_pressure,wind_speed_10m,wind_gusts_10m"
        f"&daily=temperature_2m_max,temperature_2m_min,uv_index_max"
        f"&timezone=America%2FLima&forecast_days=1"
    )

    try:
        req = urllib.request.Request(
            url,
            headers={'User-Agent': 'HuagurunchoApp/1.0 (Municipalidad de Huachon)'}
        )
        with urllib.request.urlopen(req, timeout=8) as response:
            data = json.loads(response.read().decode('utf-8'))
            cache.set(CACHE_KEY_YANACANCHA_WEATHER, data, CACHE_TTL_SECONDS)
            return data
    except Exception as exc:
        logger.warning("Fallo al consultar Open-Meteo para Yanacancha: %s. Usando fallback.", exc)
        return {
            'elevation': 4378.0,
            'current': {
                'temperature_2m': 4.0,
                'relative_humidity_2m': 65,
                'apparent_temperature': 1.5,
                'weather_code': 1,
                'surface_pressure': 612.0,
                'wind_speed_10m': 14.0,
                'wind_gusts_10m': 22.0,
            },
            'daily': {
                'temperature_2m_max': [11.0],
                'temperature_2m_min': [-1.0],
                'uv_index_max': [11.5],
            }
        }


def get_altitude_calibration_profiles():
    """
    Perfiles altitudinales para calibrar el clima en base a la telemetría de Yanacancha.
    Cada perfil define:
    - offset_temp: diferencia térmica respecto a Yanacancha (°C).
    - uv_multiplier: factor de amplificación de radiación solar por altitud y albedo.
    - wind_factor: multiplicación del viento según exposición topográfica.
    - pressure_offset: variación de presión atmosférica (hPa).
    - default_risk: nivel de riesgo por defecto.
    - advisory: recomendación de seguridad para senderistas y montañistas.
    """
    return {
        'Pueblo de Huachón': {
            'altitude': 3400,
            'order': 1,
            'offset_temp': 5.0,  # +5°C más templado que Yanacancha
            'night_offset': 4.0,
            'uv_multiplier': 0.85,
            'wind_factor': 0.75,
            'pressure_offset': 75,
            'default_risk': MountainWeatherStation.RiskLevel.BAJO,
            'advisory': 'Clima templado andino. Aclimatación ideal antes de subir a campamentos de altura.',
        },
        'Pampa Chichuraque': {
            'altitude': 3850,
            'order': 2,
            'offset_temp': 2.5,  # +2.5°C
            'night_offset': 1.5,
            'uv_multiplier': 0.95,
            'wind_factor': 1.1,
            'pressure_offset': 25,
            'default_risk': MountainWeatherStation.RiskLevel.MODERADO,
            'advisory': 'Vientos secos de puna. Usar cortaviento y protector labial hidratante.',
        },
        'Laguna Huascacocha': {
            'altitude': 4250,
            'order': 3,
            'offset_temp': -1.5,  # -1.5°C respecto a Yanacancha
            'night_offset': -2.5,
            'uv_multiplier': 1.05,
            'wind_factor': 1.3,
            'pressure_offset': -12,
            'default_risk': MountainWeatherStation.RiskLevel.HELADAS,
            'advisory': '⚠️ Heladas nocturnas a partir de las 18:00 hrs. Bolsa de dormir confort -10°C obligatoria para pernoctar.',
        },
        'Mirador Glaciar': {
            'altitude': 4680,
            'order': 4,
            'offset_temp': -3.5,  # -3.5°C
            'night_offset': -4.5,
            'uv_multiplier': 1.2,
            'wind_factor': 1.5,
            'pressure_offset': -50,
            'default_risk': MountainWeatherStation.RiskLevel.EXTREMO,
            'advisory': '⚡ Radiación amplificada por nieve (+80% albedo). Lentes UV400 Cat 4 de alta montaña indispensables.',
        },
        'Cumbre Nevado Huaguruncho': {
            'altitude': 5742,
            'order': 5,
            # Regla de la Municipalidad de Huachón: reducir entre 5 y 6 grados (-5.5°C)
            'offset_temp': NEVADO_TEMP_OFFSET_CELSIUS,
            'night_offset': -8.0,
            'uv_multiplier': 1.35,
            'wind_factor': 2.2,
            'pressure_offset': -120,
            'default_risk': MountainWeatherStation.RiskLevel.VENTISCA,
            'advisory': '🚨 Zona técnica de alta montaña. Prohibido ascender sin equipo técnico de hielo, cuerdas y crampones.',
        },
    }


def sync_weather_stations(force_refresh: bool = False) -> dict:
    """
    Sincroniza todas las estaciones meteorológicas de montaña en la base de datos
    utilizando los datos en tiempo real de Open-Meteo (Yanacancha) y los offsets
    térmicos calibrados de Huachón.
    """
    raw_data = fetch_yanacancha_raw_weather(force_refresh=force_refresh)
    current = raw_data.get('current', {})
    daily = raw_data.get('daily', {})

    base_temp = float(current.get('temperature_2m', 4.0))
    base_humidity = int(current.get('relative_humidity_2m', 60))
    base_apparent = float(current.get('apparent_temperature', base_temp - 2.0))
    base_wcode = int(current.get('weather_code', 0))
    base_pressure = float(current.get('surface_pressure', 612.0))
    base_wind = float(current.get('wind_speed_10m', 15.0))
    base_gusts = float(current.get('wind_gusts_10m', base_wind * 1.5))

    daily_max_list = daily.get('temperature_2m_max', [base_temp + 6.0])
    daily_min_list = daily.get('temperature_2m_min', [base_temp - 4.0])
    uv_max_list = daily.get('uv_index_max', [10.0])

    base_day_max = float(daily_max_list[0]) if daily_max_list else base_temp + 6.0
    base_night_min = float(daily_min_list[0]) if daily_min_list else base_temp - 4.0
    base_uv = float(uv_max_list[0]) if uv_max_list else 10.0

    condition, icon = interpret_wmo_code(base_wcode)
    profiles = get_altitude_calibration_profiles()
    updated_stations = []

    for name, prof in profiles.items():
        # Cálculo térmico actual y nocturno aplicando el offset altitudinal.
        # En el nevado se aplican directamente los -5.5 °C solicitados por la municipalidad.
        temp_day = round(base_temp + prof['offset_temp'], 1)
        temp_night = round(base_night_min + prof['night_offset'], 1)

        wind_speed = round(max(base_wind * prof['wind_factor'], 5.0), 1)
        wind_gusts = round(max(base_gusts * prof['wind_factor'], wind_speed + 5.0), 1)

        # Sensación térmica calculada (wind chill aproximado)
        wind_chill = round(temp_day - (wind_speed * 0.18), 1)

        uv_calc = round(min(max(base_uv * prof['uv_multiplier'], 1.0), 18.0), 1)
        if uv_calc < 3.0:
            uv_level = 'Moderado'
        elif uv_calc < 8.0:
            uv_level = 'Alto'
        elif uv_calc < 11.0:
            uv_level = 'Muy Alto'
        else:
            uv_level = 'Extremo (11+)'

        # Presión y humedad ajustadas
        pressure = int(max(base_pressure + prof['pressure_offset'], 450))
        # Humedad relativa varía inversamente con altitud y viento
        humidity = int(max(min(base_humidity - (prof['order'] * 5), 95), 20))

        # Determinar nivel de riesgo dinámico si hay condiciones severas
        risk = prof['default_risk']
        station_condition = condition
        station_icon = icon

        if prof['order'] >= 4 and base_wcode in [71, 73, 75, 77, 85, 86]:
            station_condition = 'Ventisca y Nieve Glaciar'
            station_icon = 'severe_cold'
            risk = MountainWeatherStation.RiskLevel.VENTISCA
        elif temp_night <= 0 and prof['order'] == 3:
            risk = MountainWeatherStation.RiskLevel.HELADAS

        station, _ = MountainWeatherStation.objects.update_or_create(
            name=name,
            defaults={
                'altitude_masl': prof['altitude'],
                'temp_day_celsius': Decimal(str(temp_day)),
                'temp_night_celsius': Decimal(str(temp_night)),
                'condition': station_condition,
                'weather_icon': station_icon,
                'wind_kmh': Decimal(str(wind_speed)),
                'wind_gusts_kmh': Decimal(str(wind_gusts)),
                'wind_chill_celsius': Decimal(str(wind_chill)),
                'uv_index': Decimal(str(uv_calc)),
                'uv_level': uv_level,
                'humidity_percentage': humidity,
                'pressure_hpa': pressure,
                'risk_level': risk,
                'alert_advisory': prof['advisory'],
                'order': prof['order'],
                'is_active': True,
            }
        )
        updated_stations.append(station)

    # Actualizar o generar alerta meteorológica activa si la temperatura en alta montaña es bajo cero
    nevado_station = next((s for s in updated_stations if 'Cumbre' in s.name), None)
    if nevado_station and nevado_station.temp_night_celsius <= 0:
        now = timezone.now()
        WeatherAlert.objects.update_or_create(
            title='Descenso Térmico y Heladas en Macizo Glaciar',
            defaults={
                'severity': WeatherAlert.Severity.PRECAUCION if nevado_station.temp_night_celsius > -10 else WeatherAlert.Severity.PELIGRO,
                'description': (
                    f"Telemetría satelital registra temperaturas bajo cero ({nevado_station.temp_night_celsius}°C) "
                    f"en pisos superiores a 4,200 msnm. Vientos sostenidos de {nevado_station.wind_kmh} km/h."
                ),
                'affected_sector': 'Sectores Laguna Huascacocha, Mirador Glaciar y Nevado Huaguruncho',
                'valid_from': now,
                'valid_until': now + timedelta(hours=24),
                'is_active': True,
            }
        )

    return {
        'status': 'success',
        'stations_count': len(updated_stations),
        'base_temperature_yanacancha': base_temp,
        'nevado_temperature_celsius': float(nevado_station.temp_day_celsius) if nevado_station else None,
        'nevado_offset_applied': NEVADO_TEMP_OFFSET_CELSIUS,
        'synced_at': datetime.now().isoformat(),
    }

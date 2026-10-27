import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/weather_model.dart';

class WeatherRepository {
  final DioClient _dioClient;

  WeatherRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<WeatherStationModel>> getWeatherStations({bool forceRefresh = false}) async {
    // 1. Intentar obtener desde nuestro backend Django local
    try {
      final endpoint = forceRefresh
          ? '${ApiEndpoints.weatherStations}refresh/'
          : ApiEndpoints.weatherStations;
      final response = await _dioClient.dio.get(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;
        final List<dynamic> list = raw is List
            ? raw
            : (raw['stations'] as List<dynamic>? ?? raw['results'] as List<dynamic>? ?? []);
        if (list.isNotEmpty) {
          return list.map((j) => WeatherStationModel.fromJson(j as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    // 2. Fallback de resiliencia directa: Consultar Open-Meteo para Yanacancha (-10.67, -76.25)
    // aplicando la regla de la Municipalidad de Huachón (-5.5°C en el Nevado)
    try {
      final directStations = await _fetchFromOpenMeteoDirect();
      if (directStations.isNotEmpty) {
        return directStations;
      }
    } catch (_) {}

    // 3. Fallback estático sin conexión
    return _getLocalFallbackStations();
  }

  Future<List<WeatherStationModel>> _fetchFromOpenMeteoDirect() async {
    final directDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
      ),
    );
    const url = 'https://api.open-meteo.com/v1/forecast'
        '?latitude=-10.67&longitude=-76.25'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,surface_pressure,wind_speed_10m,wind_gusts_10m'
        '&daily=temperature_2m_max,temperature_2m_min,uv_index_max'
        '&timezone=America%2FLima&forecast_days=1';

    final response = await directDio.get(url);
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>? ?? {};
      final daily = data['daily'] as Map<String, dynamic>? ?? {};

      final baseTemp = double.tryParse(current['temperature_2m']?.toString() ?? '4.0') ?? 4.0;
      final baseHumidity = int.tryParse(current['relative_humidity_2m']?.toString() ?? '60') ?? 60;
      final baseWCode = int.tryParse(current['weather_code']?.toString() ?? '0') ?? 0;
      final basePressure = double.tryParse(current['surface_pressure']?.toString() ?? '612') ?? 612.0;
      final baseWind = double.tryParse(current['wind_speed_10m']?.toString() ?? '15.0') ?? 15.0;
      final baseGusts = double.tryParse(current['wind_gusts_10m']?.toString() ?? '22.0') ?? 22.0;

      final dailyMinList = daily['temperature_2m_min'] as List<dynamic>? ?? [baseTemp - 4.0];
      final uvMaxList = daily['uv_index_max'] as List<dynamic>? ?? [10.0];
      final baseNightMin = double.tryParse(dailyMinList.first?.toString() ?? '0.0') ?? 0.0;
      final baseUv = double.tryParse(uvMaxList.first?.toString() ?? '10.0') ?? 10.0;

      final (cond, ico) = _mapWmoCode(baseWCode);

      final profiles = [
        _Profile('Pueblo de Huachón', 3400, 5.0, 4.0, 0.85, 0.75, 75, 'bajo', 'Bajo', 'Clima templado andino. Aclimatación ideal antes de campamentos de altura.', 1),
        _Profile('Pampa Chichuraque', 3850, 2.5, 1.5, 0.95, 1.1, 25, 'moderado', 'Moderado', 'Vientos secos de puna. Usar cortaviento y protector labial hidratante.', 2),
        _Profile('Laguna Huascacocha', 4250, -1.5, -2.5, 1.05, 1.3, -12, 'heladas', 'Heladas Nocturnas', '⚠️ Heladas nocturnas a partir de las 18:00 hrs. Bolsa confort -10°C obligatoria.', 3),
        _Profile('Mirador Glaciar', 4680, -3.5, -4.5, 1.2, 1.5, -50, 'extremo', 'Alto Riesgo / Extremo Albedo', '⚡ Radiación amplificada por nieve (+80% albedo). Lentes UV400 Cat 4 indispensables.', 4),
        // En la cumbre/nevado se aplica el offset de -5.5 °C de Huachón
        _Profile('Cumbre Nevado Huaguruncho', 5742, -5.5, -8.0, 1.35, 2.2, -120, 'ventisca', 'Ventisca y Congelamiento', '🚨 Zona técnica de alta montaña. Prohibido ascender sin crampones, piolet y cuerdas.', 5),
      ];

      return profiles.map((p) {
        final tDay = double.parse((baseTemp + p.offsetTemp).toStringAsFixed(1));
        final tNight = double.parse((baseNightMin + p.nightOffset).toStringAsFixed(1));
        final w = double.parse((baseWind * p.windFactor).clamp(5.0, 120.0).toStringAsFixed(1));
        final wg = double.parse((baseGusts * p.windFactor).clamp(w + 5, 150.0).toStringAsFixed(1));
        final wc = double.parse((tDay - (w * 0.18)).toStringAsFixed(1));
        final uv = double.parse((baseUv * p.uvMultiplier).clamp(1.0, 18.0).toStringAsFixed(1));
        final hum = (baseHumidity - (p.order * 5)).clamp(20, 95);
        final pres = (basePressure + p.pressureOffset).round().clamp(450, 750);

        return WeatherStationModel(
          uuid: 'direct-${p.order}',
          name: p.name,
          altitudeMasl: p.altitude,
          tempDayCelsius: tDay,
          tempNightCelsius: tNight,
          condition: cond,
          weatherIcon: ico,
          windKmh: w,
          windGustsKmh: wg,
          windChillCelsius: wc,
          uvIndex: uv,
          uvLevel: uv >= 11 ? 'Extremo (11+)' : (uv >= 8 ? 'Muy Alto' : 'Alto'),
          humidityPercentage: hum,
          pressureHpa: pres,
          riskLevel: p.risk,
          riskLevelDisplay: p.riskDisplay,
          alertAdvisory: p.advisory,
          order: p.order,
          updatedAt: DateTime.now(),
        );
      }).toList();
    }
    return [];
  }

  (String, String) _mapWmoCode(int code) {
    switch (code) {
      case 0:
        return ('Despejado / Frío Intenso', 'wb_sunny');
      case 1:
        return ('Mayormente Despejado', 'wb_sunny');
      case 2:
      case 3:
        return ('Parcialmente Nublado', 'wb_cloudy');
      case 45:
      case 48:
        return ('Niebla de Altura', 'air');
      case 71:
      case 73:
      case 75:
      case 85:
      case 86:
        return ('Nevada en Macizo Glaciar', 'severe_cold');
      case 95:
      case 96:
      case 99:
        return ('Tormenta Eléctrica Glaciar', 'thunderstorm');
      default:
        return ('Nubosidad Andina', 'wb_cloudy');
    }
  }

  Future<List<WeatherAlertModel>> getWeatherAlerts() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.weatherAlerts);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] as List<dynamic>? ?? []);
        return list.map((j) => WeatherAlertModel.fromJson(j as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [
      const WeatherAlertModel(
        uuid: 'fallback-alert-01',
        title: 'Descenso Térmico y Heladas en Laguna Huascacocha',
        severity: 'precaucion',
        severityDisplay: 'Precaución',
        description: 'Masa de aire frío provocará heladas (-3°C a -7°C) entre las 18:00 y las 06:00 horas.',
        affectedSector: 'Sectores Laguna Huascacocha y Mirador Glaciar (4,200 - 4,700 msnm)',
      )
    ];
  }

  List<WeatherStationModel> _getLocalFallbackStations() {
    return const [
      WeatherStationModel(
        uuid: 'fb-station-01',
        name: 'Pueblo de Huachón',
        altitudeMasl: 3400,
        tempDayCelsius: 14.0,
        tempNightCelsius: 4.0,
        condition: 'Parcialmente Nublado',
        weatherIcon: 'wb_cloudy',
        windKmh: 12.0,
        windGustsKmh: 20.0,
        windChillCelsius: 13.0,
        uvIndex: 8.5,
        uvLevel: 'Muy Alto',
        humidityPercentage: 62,
        pressureHpa: 690,
        riskLevel: 'bajo',
        riskLevelDisplay: 'Bajo',
        alertAdvisory: 'Clima templado andino. Aclimatación ideal antes de subir a campamentos de altura.',
        order: 1,
      ),
      WeatherStationModel(
        uuid: 'fb-station-02',
        name: 'Pampa Chichuraque',
        altitudeMasl: 3850,
        tempDayCelsius: 10.0,
        tempNightCelsius: 1.0,
        condition: 'Soleado con Viento',
        weatherIcon: 'air',
        windKmh: 22.0,
        windGustsKmh: 35.0,
        windChillCelsius: 8.0,
        uvIndex: 10.2,
        uvLevel: 'Muy Alto',
        humidityPercentage: 50,
        pressureHpa: 640,
        riskLevel: 'moderado',
        riskLevelDisplay: 'Moderado',
        alertAdvisory: 'Vientos secos de puna. Usar cortaviento y protector labial hidratante.',
        order: 2,
      ),
      WeatherStationModel(
        uuid: 'fb-station-03',
        name: 'Laguna Huascacocha',
        altitudeMasl: 4250,
        tempDayCelsius: 6.0,
        tempNightCelsius: -3.0,
        condition: 'Despejado / Frío Intenso',
        weatherIcon: 'ac_unit',
        windKmh: 28.0,
        windGustsKmh: 45.0,
        windChillCelsius: 2.0,
        uvIndex: 12.8,
        uvLevel: 'Extremo (11+)',
        humidityPercentage: 42,
        pressureHpa: 600,
        riskLevel: 'heladas',
        riskLevelDisplay: 'Heladas Nocturnas',
        alertAdvisory: '⚠️ Heladas bajo cero a partir de las 18:00 hrs. Bolsa de dormir confort -10°C obligatoria para pernoctar.',
        order: 3,
      ),
      WeatherStationModel(
        uuid: 'fb-station-04',
        name: 'Mirador Glaciar',
        altitudeMasl: 4680,
        tempDayCelsius: 2.0,
        tempNightCelsius: -7.0,
        condition: 'Nieve y Escarcha',
        weatherIcon: 'severe_cold',
        windKmh: 38.0,
        windGustsKmh: 60.0,
        windChillCelsius: -4.0,
        uvIndex: 14.5,
        uvLevel: 'Extremo Albedo',
        humidityPercentage: 35,
        pressureHpa: 560,
        riskLevel: 'extremo',
        riskLevelDisplay: 'Alto Riesgo / Extremo Albedo',
        alertAdvisory: '⚡ Radiación amplificada por nieve (+80% albedo). Lentes UV400 Cat 4 de alta montaña indispensables.',
        order: 4,
      ),
      WeatherStationModel(
        uuid: 'fb-station-05',
        name: 'Cumbre Nevado Huaguruncho',
        altitudeMasl: 5742,
        tempDayCelsius: -4.0,
        tempNightCelsius: -16.0,
        condition: 'Ventisca y Hielo Glaciar',
        weatherIcon: 'thunderstorm',
        windKmh: 55.0,
        windGustsKmh: 90.0,
        windChillCelsius: -18.0,
        uvIndex: 16.0,
        uvLevel: 'Extremo Glaciar',
        humidityPercentage: 25,
        pressureHpa: 490,
        riskLevel: 'ventisca',
        riskLevelDisplay: 'Ventisca y Congelamiento',
        alertAdvisory: '🚨 Zona técnica de alta montaña. Prohibido ascender sin equipo técnico de hielo, cuerdas y crampones.',
        order: 5,
      ),
    ];
  }
}

class _Profile {
  final String name;
  final int altitude;
  final double offsetTemp;
  final double nightOffset;
  final double uvMultiplier;
  final double windFactor;
  final int pressureOffset;
  final String risk;
  final String riskDisplay;
  final String advisory;
  final int order;

  _Profile(
    this.name,
    this.altitude,
    this.offsetTemp,
    this.nightOffset,
    this.uvMultiplier,
    this.windFactor,
    this.pressureOffset,
    this.risk,
    this.riskDisplay,
    this.advisory,
    this.order,
  );
}


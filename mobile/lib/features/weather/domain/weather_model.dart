class WeatherStationModel {
  final String uuid;
  final String name;
  final int altitudeMasl;
  final double tempDayCelsius;
  final double tempNightCelsius;
  final String condition;
  final String weatherIcon;
  final double windKmh;
  final double windGustsKmh;
  final double windChillCelsius;
  final double uvIndex;
  final String uvLevel;
  final int humidityPercentage;
  final int pressureHpa;
  final String riskLevel;
  final String riskLevelDisplay;
  final String alertAdvisory;
  final int order;
  final DateTime? updatedAt;

  const WeatherStationModel({
    required this.uuid,
    required this.name,
    required this.altitudeMasl,
    required this.tempDayCelsius,
    required this.tempNightCelsius,
    this.condition = 'Despejado',
    this.weatherIcon = 'wb_sunny',
    this.windKmh = 15.0,
    this.windGustsKmh = 25.0,
    this.windChillCelsius = 5.0,
    this.uvIndex = 10.0,
    this.uvLevel = 'Muy Alto',
    this.humidityPercentage = 50,
    this.pressureHpa = 620,
    this.riskLevel = 'bajo',
    this.riskLevelDisplay = 'Bajo',
    this.alertAdvisory = '',
    this.order = 0,
    this.updatedAt,
  });

  factory WeatherStationModel.fromJson(Map<String, dynamic> json) {
    return WeatherStationModel(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      altitudeMasl: json['altitude_masl'] is int
          ? json['altitude_masl'] as int
          : int.tryParse(json['altitude_masl']?.toString() ?? '3400') ?? 3400,
      tempDayCelsius: double.tryParse(json['temp_day_celsius']?.toString() ?? '10.0') ?? 10.0,
      tempNightCelsius: double.tryParse(json['temp_night_celsius']?.toString() ?? '2.0') ?? 2.0,
      condition: json['condition']?.toString() ?? 'Despejado',
      weatherIcon: json['weather_icon']?.toString() ?? 'wb_sunny',
      windKmh: double.tryParse(json['wind_kmh']?.toString() ?? '15.0') ?? 15.0,
      windGustsKmh: double.tryParse(json['wind_gusts_kmh']?.toString() ?? '25.0') ?? 25.0,
      windChillCelsius: double.tryParse(json['wind_chill_celsius']?.toString() ?? '5.0') ?? 5.0,
      uvIndex: double.tryParse(json['uv_index']?.toString() ?? '10.0') ?? 10.0,
      uvLevel: json['uv_level']?.toString() ?? 'Muy Alto',
      humidityPercentage: json['humidity_percentage'] is int
          ? json['humidity_percentage'] as int
          : int.tryParse(json['humidity_percentage']?.toString() ?? '50') ?? 50,
      pressureHpa: json['pressure_hpa'] is int
          ? json['pressure_hpa'] as int
          : int.tryParse(json['pressure_hpa']?.toString() ?? '620') ?? 620,
      riskLevel: json['risk_level']?.toString() ?? 'bajo',
      riskLevelDisplay: json['risk_level_display']?.toString() ?? '',
      alertAdvisory: json['alert_advisory']?.toString() ?? '',
      order: json['order'] is int ? json['order'] as int : 0,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }
}

class WeatherAlertModel {
  final String uuid;
  final String title;
  final String severity;
  final String severityDisplay;
  final String description;
  final String affectedSector;
  final DateTime? validFrom;
  final DateTime? validUntil;

  const WeatherAlertModel({
    required this.uuid,
    required this.title,
    required this.severity,
    this.severityDisplay = '',
    required this.description,
    this.affectedSector = '',
    this.validFrom,
    this.validUntil,
  });

  factory WeatherAlertModel.fromJson(Map<String, dynamic> json) {
    return WeatherAlertModel(
      uuid: json['uuid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'info',
      severityDisplay: json['severity_display']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      affectedSector: json['affected_sector']?.toString() ?? '',
      validFrom: json['valid_from'] != null ? DateTime.tryParse(json['valid_from'].toString()) : null,
      validUntil: json['valid_until'] != null ? DateTime.tryParse(json['valid_until'].toString()) : null,
    );
  }
}

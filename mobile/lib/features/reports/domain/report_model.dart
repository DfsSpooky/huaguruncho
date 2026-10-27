class ReportModel {
  final int? id;
  final String localUuid;
  final String? serverUuid;
  final String category;
  final String categoryDisplay;
  final String description;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final DateTime capturedAt;
  final String? localImagePath;
  final String? remoteImageUrl;
  final String syncStatus; // pending, syncing, synced, failed
  final String? syncError;
  final DateTime? syncedAt;

  const ReportModel({
    this.id,
    required this.localUuid,
    this.serverUuid,
    required this.category,
    required this.categoryDisplay,
    required this.description,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    required this.capturedAt,
    this.localImagePath,
    this.remoteImageUrl,
    this.syncStatus = 'pending',
    this.syncError,
    this.syncedAt,
  });

  factory ReportModel.fromDrift(dynamic pending) {
    return ReportModel(
      id: pending.id,
      localUuid: pending.localUuid,
      serverUuid: pending.serverUuid,
      category: pending.category,
      categoryDisplay: _getCategoryDisplay(pending.category),
      description: pending.description,
      latitude: pending.latitude,
      longitude: pending.longitude,
      accuracyMeters: pending.accuracyMeters,
      capturedAt: pending.capturedAt,
      localImagePath: pending.localImagePath,
      syncStatus: pending.syncStatus,
      syncError: pending.syncError,
      syncedAt: pending.syncedAt,
    );
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    String? remoteImg;
    if (json.containsKey('evidences') && json['evidences'] is List && (json['evidences'] as List).isNotEmpty) {
      remoteImg = json['evidences'][0]['image_url'] as String?;
    }

    return ReportModel(
      id: _parseIntNullable(json['id']),
      localUuid: json['local_uuid']?.toString() ?? json['uuid']?.toString() ?? '',
      serverUuid: json['uuid']?.toString(),
      category: json['category']?.toString() ?? 'basura',
      categoryDisplay: json['category_display']?.toString() ?? _getCategoryDisplay(json['category']?.toString()),
      description: json['description']?.toString() ?? '',
      latitude: _parseDoubleNullable(json['latitude']),
      longitude: _parseDoubleNullable(json['longitude']),
      accuracyMeters: _parseDoubleNullable(json['accuracy_meters']),
      capturedAt: json['captured_at'] != null ? DateTime.tryParse(json['captured_at'].toString()) ?? DateTime.now() : DateTime.now(),
      remoteImageUrl: remoteImg,
      syncStatus: 'synced',
      syncedAt: json['synced_at'] != null ? DateTime.tryParse(json['synced_at'].toString()) : null,
    );
  }

  static double? _parseDoubleNullable(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  static int? _parseIntNullable(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val);
    return null;
  }

  static String _getCategoryDisplay(String? category) {
    switch (category) {
      case 'basura':
        return 'Basura / Residuos';
      case 'incendio':
        return 'Foco de Incendio';
      case 'accidente':
        return 'Accidente / Emergencia';
      case 'senalizacion_danada':
        return 'Señalización Dañada';
      case 'flora_fauna_afectada':
        return 'Flora o Fauna Afectada';
      case 'otro':
      default:
        return 'Otro Incidente';
    }
  }
}

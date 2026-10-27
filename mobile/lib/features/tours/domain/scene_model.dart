import 'hotspot_model.dart';

class SceneModel {
  final String uuid;
  final String title;
  final String description;
  final String? panoramaImageUrl;
  final String? panoramaAsset;
  final String? panoramaLocalPath;
  final double? latitude;
  final double? longitude;
  final int? altitudeMasl;
  final double heading;
  final double initialYaw;
  final double initialPitch;
  final int sequence;
  final List<HotspotModel> hotspots;

  const SceneModel({
    required this.uuid,
    required this.title,
    required this.description,
    this.panoramaImageUrl,
    this.panoramaAsset,
    this.panoramaLocalPath,
    this.latitude,
    this.longitude,
    this.altitudeMasl,
    this.heading = 0.0,
    this.initialYaw = 0.0,
    this.initialPitch = 0.0,
    required this.sequence,
    this.hotspots = const [],
  });

  factory SceneModel.fromJson(Map<String, dynamic> json) {
    var rawHotspots = json['hotspots'] as List<dynamic>? ?? [];
    List<HotspotModel> parsedHotspots =
        rawHotspots.map((h) => HotspotModel.fromJson(h as Map<String, dynamic>)).toList();

    return SceneModel(
      uuid: json['uuid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      panoramaImageUrl: json['panorama_image_url']?.toString(),
      panoramaAsset: json['panorama_asset']?.toString(),
      panoramaLocalPath: json['panorama_local_path']?.toString(),
      latitude: _parseDoubleNullable(json['latitude']),
      longitude: _parseDoubleNullable(json['longitude']),
      altitudeMasl: _parseIntNullable(json['altitude_masl']),
      heading: _parseDouble(json['heading']),
      initialYaw: _parseDouble(json['initial_yaw']),
      initialPitch: _parseDouble(json['initial_pitch']),
      sequence: _parseInt(json['sequence'], 1),
      hotspots: parsedHotspots,
    );
  }

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  static double? _parseDoubleNullable(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? defaultVal);
    return defaultVal;
  }

  static int? _parseIntNullable(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? double.tryParse(val)?.toInt();
    return null;
  }
}

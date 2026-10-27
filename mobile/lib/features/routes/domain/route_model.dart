import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../../tours/domain/scene_model.dart';

class RouteModel {
  final int? id;
  final String uuid;
  final String name;
  final String slug;
  final String description;
  final String difficulty;
  final String difficultyDisplay;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final String safetyRecommendations;
  final String? coverImageUrl;
  final String? gpxFileUrl;
  final double elevationGainM;
  final double elevationLossM;
  final int maxAltitudeM;
  final int minAltitudeM;
  final Map<String, dynamic>? geojsonTrack;
  final List<dynamic>? elevationProfile;
  final bool isDownloaded;
  final int scenesCount;
  final List<SceneModel>? scenes;

  const RouteModel({
    this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    required this.description,
    required this.difficulty,
    required this.difficultyDisplay,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.safetyRecommendations,
    this.coverImageUrl,
    this.gpxFileUrl,
    this.elevationGainM = 0.0,
    this.elevationLossM = 0.0,
    this.maxAltitudeM = 0,
    this.minAltitudeM = 0,
    this.geojsonTrack,
    this.elevationProfile,
    this.isDownloaded = false,
    this.scenesCount = 0,
    this.scenes,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    List<SceneModel>? parsedScenes;
    if (json['scenes'] is List) {
      parsedScenes = (json['scenes'] as List)
          .map((s) => SceneModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return RouteModel(
      id: _parseInt(json['id']),
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'moderada',
      difficultyDisplay: json['difficulty_display']?.toString() ?? 'Moderada',
      distanceKm: _parseDouble(json['distance_km']),
      estimatedDurationMinutes: _parseInt(json['estimated_duration_minutes']),
      safetyRecommendations: json['safety_recommendations']?.toString() ?? '',
      coverImageUrl: json['cover_image_url']?.toString(),
      gpxFileUrl: json['gpx_file_url']?.toString(),
      elevationGainM: _parseDouble(json['elevation_gain_m']),
      elevationLossM: _parseDouble(json['elevation_loss_m']),
      maxAltitudeM: _parseInt(json['max_altitude_m']),
      minAltitudeM: _parseInt(json['min_altitude_m']),
      geojsonTrack: json['geojson_track'] as Map<String, dynamic>?,
      elevationProfile: json['elevation_profile'] as List<dynamic>?,
      isDownloaded: json['is_downloaded'] == true,
      scenesCount: _parseInt(json['scenes_count'], parsedScenes?.length ?? 0),
      scenes: parsedScenes,
    );
  }

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? defaultVal);
    return defaultVal;
  }

  /// Lista de puntos LatLng para dibujar el trazo GPX en el mapa
  List<LatLng> get coordinates {
    if (geojsonTrack == null) return [];
    try {
      final geom = geojsonTrack!['geometry'];
      if (geom != null && geom['coordinates'] is List) {
        final list = geom['coordinates'] as List;
        final result = <LatLng>[];
        for (final pt in list) {
          if (pt is List && pt.length >= 2) {
            final lng = (pt[0] as num).toDouble();
            final lat = (pt[1] as num).toDouble();
            result.add(LatLng(lat, lng));
          }
        }
        return result;
      }
    } catch (_) {}
    return [];
  }

  /// Perfil altimétrico estructurado (distancia km vs altitud m)
  List<Map<String, double>> get parsedElevationProfile {
    if (elevationProfile != null && elevationProfile!.isNotEmpty) {
      final list = <Map<String, double>>[];
      for (final item in elevationProfile!) {
        if (item is Map) {
          final d = (item['distance_km'] as num?)?.toDouble() ?? 0.0;
          final a = (item['altitude_m'] as num?)?.toDouble() ?? 0.0;
          list.add({'distance_km': d, 'altitude_m': a});
        }
      }
      if (list.isNotEmpty) return list;
    }

    // Fallback: calcular a partir de las coordenadas del trazo GeoJSON
    if (geojsonTrack != null) {
      try {
        final geom = geojsonTrack!['geometry'];
        if (geom != null && geom['coordinates'] is List) {
          final list = geom['coordinates'] as List;
          final result = <Map<String, double>>[];
          double totalD = 0.0;
          for (int i = 0; i < list.length; i++) {
            final pt = list[i];
            if (pt is List && pt.length >= 3) {
              final alt = (pt[2] as num).toDouble();
              if (i > 0) {
                final prev = list[i - 1];
                final d = _approxDistKm(
                  (prev[1] as num).toDouble(),
                  (prev[0] as num).toDouble(),
                  (pt[1] as num).toDouble(),
                  (pt[0] as num).toDouble(),
                );
                totalD += d;
              }
              result.add({'distance_km': double.parse(totalD.toStringAsFixed(3)), 'altitude_m': alt});
            }
          }
          if (result.isNotEmpty) return result;
        }
      } catch (_) {}
    }
    return [];
  }

  static double _approxDistKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) * math.cos(lat2 * (math.pi / 180.0)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }
}

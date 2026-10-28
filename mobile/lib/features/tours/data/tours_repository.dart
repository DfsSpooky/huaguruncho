import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../domain/scene_model.dart';
import '../domain/hotspot_model.dart';

class TourRouteSummary {
  final String uuid;
  final String name;
  final String difficultyDisplay;
  final double distanceKm;
  final int scenesCount;

  const TourRouteSummary({
    required this.uuid,
    required this.name,
    required this.difficultyDisplay,
    required this.distanceKm,
    required this.scenesCount,
  });

  factory TourRouteSummary.fromJson(Map<String, dynamic> json) {
    return TourRouteSummary(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Ruta 360°',
      difficultyDisplay: json['difficulty_display']?.toString() ??
          json['difficulty']?.toString() ??
          'Moderada',
      distanceKm: (json['distance_km'] is num)
          ? (json['distance_km'] as num).toDouble()
          : (double.tryParse(json['distance_km']?.toString() ?? '0') ?? 0.0),
      scenesCount: (json['scenes_count'] is num)
          ? (json['scenes_count'] as num).toInt()
          : (int.tryParse(json['scenes_count']?.toString() ?? '0') ?? 0),
    );
  }
}

class ToursRepository {
  final DioClient _dioClient;
  final AppDatabase _db;

  ToursRepository({
    required DioClient dioClient,
    required AppDatabase db,
  })  : _dioClient = dioClient,
        _db = db;

  Future<List<TourRouteSummary>> getAvailableTourRoutes() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.routes);
      if (response.statusCode == 200 && response.data != null) {
        final rawList = response.data is Map<String, dynamic>
            ? (response.data['results'] as List<dynamic>? ?? [])
            : (response.data as List<dynamic>? ?? []);
        final routes = rawList
            .whereType<Map<String, dynamic>>()
            .map(TourRouteSummary.fromJson)
            .where((r) => r.uuid.isNotEmpty && r.scenesCount > 0)
            .toList();
        if (routes.isNotEmpty) return routes;
      }
    } catch (_) {}

    try {
      final localRoutes = await _db.getAllDownloadedRoutes();
      if (localRoutes.isNotEmpty) {
        return localRoutes
            .map(
              (r) => TourRouteSummary(
                uuid: r.serverUuid,
                name: r.name,
                difficultyDisplay: r.difficulty,
                distanceKm: r.distanceKm,
                scenesCount: 1,
              ),
            )
            .toList();
      }
    } catch (_) {}

    return const [];
  }

  Future<List<SceneModel>> getScenesForRoute(String? routeUuid) async {
    String? targetRouteUuid = routeUuid;

    // Si no se especificó ruta (ej. desde la pestaña inferior 360°), obtener la primera ruta activa con escenas 360° del backend
    if (targetRouteUuid == null || targetRouteUuid.isEmpty) {
      final availableRoutes = await getAvailableTourRoutes();
      if (availableRoutes.isNotEmpty) {
        targetRouteUuid = availableRoutes.first.uuid;
      }
    }

    if (targetRouteUuid != null && targetRouteUuid.isNotEmpty) {
      // 1. Priorizar API REST en vivo para reflejar al instante los puntos, fotos y ángulos creados en el Studio
      try {
        final response = await _dioClient.dio.get(ApiEndpoints.routeScenes(targetRouteUuid));
        if (response.statusCode == 200 && response.data != null) {
          final list = response.data is List
              ? (response.data as List<dynamic>)
              : ((response.data as Map<String, dynamic>)['results'] as List<dynamic>? ?? []);

          final remoteScenes = list
              .whereType<Map<String, dynamic>>()
              .map(SceneModel.fromJson)
              .toList();

          if (remoteScenes.isNotEmpty) {
            // Enriquecer con path local si ya existe un paquete offline descargado de esa escena
            final List<SceneModel> enriched = [];
            for (final sc in remoteScenes) {
              try {
                final localScene = await _db.getSceneByUuid(sc.uuid);
                if (localScene != null &&
                    localScene.panoramaLocalPath.isNotEmpty &&
                    await File(localScene.panoramaLocalPath).exists()) {
                  enriched.add(sc.copyWith(panoramaLocalPath: localScene.panoramaLocalPath));
                } else {
                  enriched.add(sc);
                }
              } catch (_) {
                enriched.add(sc);
              }
            }
            return enriched;
          }
        }
      } catch (_) {}

      // 2. Fallback Offline desde Drift si no hay conexión a internet
      try {
        final localScenes = await _db.getScenesForRoute(targetRouteUuid);
        if (localScenes.isNotEmpty) {
          final List<SceneModel> results = [];
          for (final ls in localScenes) {
            final localHotspots = await _db.getHotspotsForScene(ls.serverUuid);
            final hotspots = localHotspots
                .map((lh) => HotspotModel(
                      uuid: lh.serverUuid,
                      sourceSceneUuid: ls.serverUuid,
                      title: lh.title,
                      content: lh.content,
                      type: lh.type,
                      yaw: lh.yaw,
                      pitch: lh.pitch,
                      targetSceneUuid: lh.targetSceneUuid,
                      icon: lh.type == 'photo_poi'
                          ? 'photo_camera'
                          : lh.type == 'audio_guide'
                              ? 'headphones'
                              : lh.type == 'warning'
                                  ? 'warning'
                                  : lh.type == 'information'
                                      ? 'info'
                                      : 'arrow_forward',
                    ))
                .toList();

            results.add(SceneModel(
              uuid: ls.serverUuid,
              routeUuid: ls.routeServerUuid,
              title: ls.title,
              description: ls.description,
              panoramaLocalPath: ls.panoramaLocalPath,
              latitude: ls.latitude,
              longitude: ls.longitude,
              sequence: ls.sequence,
              hotspots: hotspots,
            ));
          }
          return results;
        }
      } catch (_) {}
    }

    // 3. Fallback a escenas Demo Locales
    return _getDemoScenes();
  }

  Future<List<SceneModel>> _getDemoScenes() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/mock_data/demo_tour.json');
      final data = json.decode(jsonStr);
      final rawScenes = data['scenes'] as List<dynamic>;
      return rawScenes.map((s) => SceneModel.fromJson(s as Map<String, dynamic>)).toList();
    } catch (_) {
      return [
        const SceneModel(
          uuid: 'demo-scene-01-plaza',
          title: 'Plaza Principal de Huachón',
          description: 'Altitud 3,400 m s.n.m.',
          panoramaAsset: 'assets/panoramas/scene_huachon_plaza.jpg',
          sequence: 1,
          hotspots: [
            HotspotModel(
              uuid: 'demo-h1',
              title: 'Hacia Laguna Huaguruncho',
              content: 'Sendero hacia la laguna.',
              type: 'navigation',
              yaw: 35.0,
              pitch: -2.0,
              targetSceneUuid: 'demo-scene-02-laguna',
              icon: 'arrow_forward',
            )
          ],
        ),
      ];
    }
  }
}

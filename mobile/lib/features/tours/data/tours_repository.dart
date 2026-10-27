import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../domain/scene_model.dart';
import '../domain/hotspot_model.dart';

class ToursRepository {
  final DioClient _dioClient;
  final AppDatabase _db;

  ToursRepository({
    required DioClient dioClient,
    required AppDatabase db,
  })  : _dioClient = dioClient,
        _db = db;

  Future<List<SceneModel>> getScenesForRoute(String? routeUuid) async {
    // 1. Intentar desde Drift (si está descargado offline)
    if (routeUuid != null && routeUuid.isNotEmpty) {
      final localScenes = await _db.getScenesForRoute(routeUuid);
      if (localScenes.isNotEmpty) {
        List<SceneModel> results = [];
        for (final ls in localScenes) {
          final localHotspots = await _db.getHotspotsForScene(ls.serverUuid);
          final hotspots = localHotspots
              .map((lh) => HotspotModel(
                    uuid: lh.serverUuid,
                    title: lh.title,
                    content: lh.content,
                    type: lh.type,
                    yaw: lh.yaw,
                    pitch: lh.pitch,
                    targetSceneUuid: lh.targetSceneUuid,
                    icon: 'arrow_forward',
                  ))
              .toList();

          results.add(SceneModel(
            uuid: ls.serverUuid,
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

      // 2. Intentar desde API REST
      try {
        final response = await _dioClient.dio.get(ApiEndpoints.routeScenes(routeUuid));
        if (response.statusCode == 200 && response.data != null) {
          final list = response.data as List<dynamic>;
          return list.map((json) => SceneModel.fromJson(json)).toList();
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

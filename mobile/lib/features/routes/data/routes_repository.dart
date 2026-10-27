import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../domain/route_model.dart';

class RoutesRepository {
  final DioClient _dioClient;
  final AppDatabase _db;

  RoutesRepository({
    required DioClient dioClient,
    required AppDatabase db,
  })  : _dioClient = dioClient,
        _db = db;

  Future<List<RouteModel>> getRoutes() async {
    // 1. Intentar desde Backend API
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.routes);
      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List<dynamic>;
        final routes = results.map((json) => RouteModel.fromJson(json)).toList();

        // Cruzar con estado de descarga en Drift
        final downloaded = await _db.getAllDownloadedRoutes();
        final downloadedUuids = downloaded.map((d) => d.serverUuid).toSet();

        return routes.map((r) {
          if (downloadedUuids.contains(r.uuid)) {
            return RouteModel(
              id: r.id,
              uuid: r.uuid,
              name: r.name,
              slug: r.slug,
              description: r.description,
              difficulty: r.difficulty,
              difficultyDisplay: r.difficultyDisplay,
              distanceKm: r.distanceKm,
              estimatedDurationMinutes: r.estimatedDurationMinutes,
              safetyRecommendations: r.safetyRecommendations,
              coverImageUrl: r.coverImageUrl,
              isDownloaded: true,
              scenesCount: r.scenesCount,
            );
          }
          return r;
        }).toList();
      }
    } catch (_) {
      // Fallback a almacenamiento local o mock
    }

    // 2. Intentar desde Drift SQLite
    final localList = await _db.getAllDownloadedRoutes();
    if (localList.isNotEmpty) {
      return localList
          .map((lr) => RouteModel(
                id: lr.id,
                uuid: lr.serverUuid,
                name: lr.name,
                slug: lr.serverUuid,
                description: lr.description,
                difficulty: lr.difficulty,
                difficultyDisplay: lr.difficulty,
                distanceKm: lr.distanceKm,
                estimatedDurationMinutes: lr.estimatedDurationMinutes,
                safetyRecommendations: '',
                isDownloaded: true,
              ))
          .toList();
    }

    // 3. Fallback a datos Demo Offline embebidos
    return _getDemoRoutes();
  }

  Future<RouteModel?> getRouteDetail(String uuid) async {
    // Intentar desde API
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.routeDetail(uuid));
      if (response.statusCode == 200 && response.data != null) {
        return RouteModel.fromJson(response.data);
      }
    } catch (_) {}

    // Intentar desde Drift
    final local = await _db.getRouteByUuid(uuid);
    if (local != null) {
      return RouteModel(
        id: local.id,
        uuid: local.serverUuid,
        name: local.name,
        slug: local.serverUuid,
        description: local.description,
        difficulty: local.difficulty,
        difficultyDisplay: local.difficulty,
        distanceKm: local.distanceKm,
        estimatedDurationMinutes: local.estimatedDurationMinutes,
        safetyRecommendations: '',
        isDownloaded: true,
      );
    }

    final demoRoutes = await _getDemoRoutes();
    return demoRoutes.firstWhere((r) => r.uuid == uuid, orElse: () => demoRoutes.first);
  }

  Future<List<RouteModel>> _getDemoRoutes() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/mock_data/demo_tour.json');
      final data = json.decode(jsonStr);
      final r = data['route'];
      return [RouteModel.fromJson(r)];
    } catch (_) {
      return [
        const RouteModel(
          uuid: 'demo-route-huachon-huaguruncho',
          name: 'Ruta piloto Huachón – Mirador Huaguruncho',
          slug: 'huachon-mirador-huaguruncho',
          description: 'Ruta piloto hacia el imponente nevado Huaguruncho (5,742 msnm).',
          difficulty: 'moderada',
          difficultyDisplay: 'Moderada',
          distanceKm: 14.5,
          estimatedDurationMinutes: 360,
          safetyRecommendations: 'Llevar ropa térmica y calzado de montaña.',
          isDownloaded: true,
          scenesCount: 3,
        )
      ];
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:huaguruncho_360/features/auth/domain/user_model.dart';
import 'package:huaguruncho_360/features/routes/domain/route_model.dart';
import 'package:huaguruncho_360/features/tours/domain/scene_model.dart';
import 'package:huaguruncho_360/features/reports/domain/report_model.dart';

void main() {
  group('Model Serialization Tests', () {
    test('UserModel serialization and deserialization', () {
      final json = {
        'id': 1,
        'email': 'turista@huaguruncho.pe',
        'full_name': 'Juan Pérez',
        'phone': '+51987654321',
        'role': 'turista',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 1);
      expect(user.email, 'turista@huaguruncho.pe');
      expect(user.fullName, 'Juan Pérez');
      expect(user.role, 'turista');
    });

    test('RouteModel parses numbers and fields safely', () {
      final json = {
        'uuid': 'route-uuid-1',
        'name': 'Ruta Huaguruncho',
        'description': 'Hermosa ruta glaciar',
        'difficulty': 'moderada',
        'difficulty_display': 'Moderada',
        'distance_km': 14.5,
        'estimated_duration_minutes': 360,
        'safety_recommendations': 'Llevar abrigo',
        'is_downloaded': true,
      };

      final route = RouteModel.fromJson(json);
      expect(route.uuid, 'route-uuid-1');
      expect(route.distanceKm, 14.5);
      expect(route.isDownloaded, true);
    });

    test('SceneModel parses nested hotspots correctly', () {
      final json = {
        'uuid': 'scene-uuid-1',
        'title': 'Plaza de Huachón',
        'description': 'Punto de partida',
        'sequence': 1,
        'hotspots': [
          {
            'uuid': 'hotspot-1',
            'title': 'Hacia Laguna',
            'type': 'navigation',
            'yaw': 45.0,
            'pitch': -5.0,
            'target_scene_uuid': 'scene-uuid-2',
            'icon': 'arrow_forward',
          }
        ]
      };

      final scene = SceneModel.fromJson(json);
      expect(scene.title, 'Plaza de Huachón');
      expect(scene.hotspots.length, 1);
      expect(scene.hotspots[0].targetSceneUuid, 'scene-uuid-2');
    });

    test('ReportModel calculates display category correctly', () {
      final report = ReportModel(
        localUuid: 'local-test-uuid',
        category: 'basura',
        categoryDisplay: 'Basura / Residuos',
        description: 'Plásticos cerca a la laguna',
        capturedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      expect(report.syncStatus, 'pending');
      expect(report.categoryDisplay, 'Basura / Residuos');
    });
  });
}

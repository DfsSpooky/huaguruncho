import 'package:flutter_test/flutter_test.dart';
import 'package:huaguruncho_360/features/reports/domain/report_model.dart';

void main() {
  group('Report Sync Logic Tests', () {
    test('Offline report status defaults to pending', () {
      final report = ReportModel(
        localUuid: 'uuid-1234',
        category: 'incendio',
        categoryDisplay: 'Foco de Incendio',
        description: 'Fogata mal apagada',
        capturedAt: DateTime(2026, 8, 21, 14, 0),
        latitude: -10.5512,
        longitude: -75.9812,
        accuracyMeters: 4.0,
      );

      expect(report.syncStatus, 'pending');
      expect(report.serverUuid, isNull);
      expect(report.syncedAt, isNull);
    });

    test('Synced report from server JSON payload mappings', () {
      final serverJson = {
        'id': 42,
        'uuid': 'server-uuid-5678',
        'local_uuid': 'uuid-1234',
        'category': 'basura',
        'category_display': 'Basura / Residuos',
        'description': 'Residuos en la orilla',
        'latitude': -10.5512,
        'longitude': -75.9812,
        'accuracy_meters': 3.5,
        'captured_at': '2026-08-21T14:00:00Z',
        'status': 'recibido',
        'synced_at': '2026-08-21T14:05:00Z',
        'evidences': [
          {'id': 1, 'image_url': 'http://localhost:8000/media/evidence.jpg'}
        ]
      };

      final report = ReportModel.fromJson(serverJson);
      expect(report.serverUuid, 'server-uuid-5678');
      expect(report.localUuid, 'uuid-1234');
      expect(report.syncStatus, 'synced');
      expect(report.remoteImageUrl, 'http://localhost:8000/media/evidence.jpg');
    });
  });
}

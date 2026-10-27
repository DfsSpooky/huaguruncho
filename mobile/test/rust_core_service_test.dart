import 'package:flutter_test/flutter_test.dart';
import 'package:huaguruncho_360/core/rust/rust_core_service.dart';

void main() {
  group('RustCoreService FFI Integration Tests', () {
    final rust = RustCoreService.instance;

    test('Carga el motor nativo de Rust y reporta versión 2.0.0', () {
      expect(rust.isNativeLoaded, isTrue);
      expect(rust.engineVersion, contains('huaguruncho_core'));
    });

    test('Calcula distancia Haversine y duración Naismith en alta montaña', () {
      final meters = rust.haversineMeters(
        -10.551590,
        -75.930389,
        -10.521800,
        -75.918900,
      );
      expect(meters, greaterThan(3000.0));
      expect(meters, lessThan(4000.0));

      final mins = rust.estimatedDurationMinutes(
        distanceKm: 12.0,
        elevationGainM: 650.0,
        elevationLossM: 120.0,
        maxAltitudeM: 4650.0,
      );
      expect(mins, greaterThanOrEqualTo(300));
    });

    test('Evalúa telemetría GPS en tiempo real (en ruta vs desvío >50m)', () {
      final trail = [
        [-10.551590, -75.930389],
        [-10.548910, -75.954120],
        [-10.539800, -75.942000],
      ];

      final onTrail = rust.evaluateLiveTelemetry(
        currentLat: -10.548910,
        currentLon: -75.954120,
        currentAltM: 4350.0,
        maxAltM: 4796.0,
        totalDistanceKm: 10.0,
        trailLatLon: trail,
      );
      expect(onTrail.isOffTrailAlert, isFalse);
      expect(onTrail.nearestPointIndex, equals(1));
      expect(onTrail.distanceCoveredKm, closeTo(5.0, 0.1));

      final offTrail = rust.evaluateLiveTelemetry(
        currentLat: -10.600000,
        currentLon: -75.990000,
        currentAltM: 4350.0,
        maxAltM: 4796.0,
        totalDistanceKm: 10.0,
        trailLatLon: trail,
      );
      expect(offTrail.isOffTrailAlert, isTrue);
      expect(offTrail.distanceToTrailM, greaterThan(50.0));
    });

    test('Audita retorno de residuos Huella Cero y genera sello criptográfico', () {
      final meritAudit = rust.auditHuellaCero(
        localUuid: 'chk-test-merit',
        documentNumber: '70112233',
        plasticBottlesIn: 2,
        cansIn: 1,
        plasticWrappersIn: 3,
        plasticBagsIn: 1,
        batteriesIn: 2,
        gasCanistersIn: 1,
        plasticBottlesOut: 4,
        cansOut: 1,
        plasticWrappersOut: 3,
        plasticBagsOut: 1,
        batteriesOut: 2,
        gasCanistersOut: 1,
      );
      expect(meritAudit.totalItemsIn, equals(10));
      expect(meritAudit.totalItemsOut, equals(12));
      expect(meritAudit.wasteComplianceStatus, equals('extra_collected'));
      expect(meritAudit.cryptographicSeal, startsWith('H360-'));

      // Si falta una batería peligrosa aunque traiga botellas extra -> infracción
      final hazMissingAudit = rust.auditHuellaCero(
        localUuid: 'chk-test-haz',
        documentNumber: '70112233',
        plasticBottlesIn: 2,
        cansIn: 1,
        plasticWrappersIn: 3,
        plasticBagsIn: 1,
        batteriesIn: 2,
        gasCanistersIn: 1,
        plasticBottlesOut: 5,
        cansOut: 1,
        plasticWrappersOut: 3,
        plasticBagsOut: 1,
        batteriesOut: 1, // Falta 1 batería
        gasCanistersOut: 1,
      );
      expect(hazMissingAudit.hasHazardousMissing, isTrue);
      expect(hazMissingAudit.wasteComplianceStatus, equals('infraction_missing'));

      final ecoCode = rust.signEcoReport(
        localUuid: 'eco-uuid-999',
        category: 'RESIDUOS_SOLIDOS',
        latitude: -10.5512,
        longitude: -75.9301,
        capturedAtIso: '2026-10-18T18:00:00Z',
      );
      expect(ecoCode, startsWith('ECO360-'));
    });
  });
}

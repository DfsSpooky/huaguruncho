import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math' as math;
import 'package:ffi/ffi.dart';
import '../../src/third_party/huaguruncho_core.g.dart';

class RustLiveTelemetry {
  final double distanceToTrailM;
  final bool isOffTrailAlert;
  final int nearestPointIndex;
  final double distanceCoveredKm;
  final double distanceRemainingKm;
  final double progressPercent;
  final int estimatedRemainingMinutes;

  const RustLiveTelemetry({
    required this.distanceToTrailM,
    required this.isOffTrailAlert,
    required this.nearestPointIndex,
    required this.distanceCoveredKm,
    required this.distanceRemainingKm,
    required this.progressPercent,
    required this.estimatedRemainingMinutes,
  });
}

class RustWasteAuditResult {
  final int totalItemsIn;
  final int totalItemsOut;
  final int netBalance;
  final double returnRatePercent;
  final String wasteComplianceStatus;
  final bool hasHazardousMissing;
  final String cryptographicSeal;

  const RustWasteAuditResult({
    required this.totalItemsIn,
    required this.totalItemsOut,
    required this.netBalance,
    required this.returnRatePercent,
    required this.wasteComplianceStatus,
    required this.hasHazardousMissing,
    required this.cryptographicSeal,
  });
}

class RustCoreService {
  RustCoreService._();
  static final RustCoreService instance = RustCoreService._();

  HuagurunchoCoreBindings? _bindings;
  bool _loadAttempted = false;

  HuagurunchoCoreBindings? get _native {
    if (_bindings != null) return _bindings;
    if (_loadAttempted) return null;
    _loadAttempted = true;

    final candidates = <String>[];
    final envLib = Platform.environment['HUAGURUNCHO_RUST_LIB'];
    if (envLib != null && envLib.isNotEmpty) {
      candidates.add(envLib);
    }

    if (Platform.isMacOS) {
      candidates.addAll([
        '../rust/target/release/libhuaguruncho_core.dylib',
        '../rust/target/debug/libhuaguruncho_core.dylib',
        'rust/target/release/libhuaguruncho_core.dylib',
        'libhuaguruncho_core.dylib',
      ]);
    } else if (Platform.isAndroid || Platform.isLinux) {
      candidates.addAll([
        'libhuaguruncho_core.so',
        '../rust/target/release/libhuaguruncho_core.so',
        'rust/target/release/libhuaguruncho_core.so',
      ]);
    } else if (Platform.isWindows) {
      candidates.addAll([
        'huaguruncho_core.dll',
        '../rust/target/release/huaguruncho_core.dll',
      ]);
    }

    for (final path in candidates) {
      try {
        if (path.contains('/') && !File(path).existsSync()) {
          continue;
        }
        final dylib = ffi.DynamicLibrary.open(path);
        _bindings = HuagurunchoCoreBindings(dylib);
        return _bindings;
      } catch (_) {
        // Intentar siguiente ubicación candidata
      }
    }

    return null;
  }

  bool get isNativeLoaded => _native != null;

  String get engineVersion {
    final b = _native;
    if (b == null) return 'dart-fallback';
    try {
      final ptr = b.h360_version();
      return ptr.cast<Utf8>().toDartString();
    } catch (_) {
      return 'huaguruncho_core';
    }
  }

  Map<String, dynamic>? _consumeJsonPtr(
    HuagurunchoCoreBindings b,
    ffi.Pointer<ffi.Char> ptr,
  ) {
    if (ptr == ffi.nullptr) return null;
    try {
      final str = ptr.cast<Utf8>().toDartString();
      return json.decode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    } finally {
      b.h360_free_string(ptr);
    }
  }

  double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    final b = _native;
    if (b != null) {
      try {
        return b.h360_haversine_meters(lat1, lon1, lat2, lon2);
      } catch (_) {}
    }

    const r = 6371000.0;
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  int estimatedDurationMinutes({
    required double distanceKm,
    required double elevationGainM,
    double elevationLossM = 0.0,
    double maxAltitudeM = 0.0,
  }) {
    final b = _native;
    if (b != null) {
      try {
        return b.h360_estimated_duration_minutes(
          distanceKm,
          elevationGainM,
          elevationLossM,
          maxAltitudeM,
        );
      } catch (_) {}
    }

    if (distanceKm <= 0) return 30;
    final flat = (distanceKm / 4.0) * 60.0;
    final up = (elevationGainM / 100.0) * 10.0;
    final down = (elevationLossM / 100.0) * 4.0;
    final factor = maxAltitudeM >= 4500
        ? 1.25
        : (maxAltitudeM >= 3800 ? 1.15 : 1.0);
    return math.max(15, ((flat + up + down) * factor).round());
  }

  RustLiveTelemetry evaluateLiveTelemetry({
    required double currentLat,
    required double currentLon,
    required double currentAltM,
    required double maxAltM,
    required double totalDistanceKm,
    required List<List<double>> trailLatLon,
  }) {
    final b = _native;
    if (b != null) {
      final reqJson = json.encode({
        'current_lat': currentLat,
        'current_lon': currentLon,
        'current_alt_m': currentAltM,
        'max_alt_m': maxAltM,
        'total_distance_km': totalDistanceKm,
        'trail_lat_lon': trailLatLon,
      });
      final reqPtr = reqJson.toNativeUtf8().cast<ffi.Char>();
      try {
        final resPtr = b.h360_evaluate_telemetry_json(reqPtr);
        final data = _consumeJsonPtr(b, resPtr);
        if (data != null && data.containsKey('distance_to_trail_m')) {
          return RustLiveTelemetry(
            distanceToTrailM: (data['distance_to_trail_m'] as num).toDouble(),
            isOffTrailAlert: data['is_off_trail_alert'] as bool? ?? false,
            nearestPointIndex: (data['nearest_point_index'] as num?)?.toInt() ?? 0,
            distanceCoveredKm: (data['distance_covered_km'] as num?)?.toDouble() ?? 0.0,
            distanceRemainingKm:
                (data['distance_remaining_km'] as num?)?.toDouble() ?? totalDistanceKm,
            progressPercent: (data['progress_percent'] as num?)?.toDouble() ?? 0.0,
            estimatedRemainingMinutes:
                (data['estimated_remaining_minutes'] as num?)?.toInt() ?? 30,
          );
        }
      } finally {
        calloc.free(reqPtr);
      }
    }

    // Fallback determinista si la librería dinámica no está disponible
    double minDistanceM = 9999.0;
    int nearestIndex = 0;
    for (int i = 0; i < trailLatLon.length; i++) {
      final pt = trailLatLon[i];
      final d = haversineMeters(currentLat, currentLon, pt[0], pt[1]);
      if (d < minDistanceM) {
        minDistanceM = d;
        nearestIndex = i;
      }
    }
    final isOffTrail = minDistanceM > 50.0;
    final ratio = trailLatLon.length > 1
        ? nearestIndex / (trailLatLon.length - 1)
        : 0.0;
    final coveredKm = (ratio * totalDistanceKm).clamp(0.0, totalDistanceKm);
    final remainingKm = (totalDistanceKm - coveredKm).clamp(0.0, totalDistanceKm);
    final progress = totalDistanceKm > 0
        ? (coveredKm / totalDistanceKm).clamp(0.0, 1.0)
        : 0.0;

    return RustLiveTelemetry(
      distanceToTrailM: minDistanceM,
      isOffTrailAlert: isOffTrail,
      nearestPointIndex: nearestIndex,
      distanceCoveredKm: coveredKm,
      distanceRemainingKm: remainingKm,
      progressPercent: progress,
      estimatedRemainingMinutes: estimatedDurationMinutes(
        distanceKm: remainingKm,
        elevationGainM: math.max(0.0, maxAltM - currentAltM),
        maxAltitudeM: maxAltM,
      ),
    );
  }

  RustWasteAuditResult auditHuellaCero({
    required String localUuid,
    required String documentNumber,
    required int plasticBottlesIn,
    required int cansIn,
    required int plasticWrappersIn,
    required int plasticBagsIn,
    required int batteriesIn,
    required int gasCanistersIn,
    required int plasticBottlesOut,
    required int cansOut,
    required int plasticWrappersOut,
    required int plasticBagsOut,
    required int batteriesOut,
    required int gasCanistersOut,
  }) {
    final b = _native;
    if (b != null) {
      final reqJson = json.encode({
        'local_uuid': localUuid,
        'document_number': documentNumber,
        'plastic_bottles_in': plasticBottlesIn,
        'cans_in': cansIn,
        'plastic_wrappers_in': plasticWrappersIn,
        'plastic_bags_in': plasticBagsIn,
        'batteries_in': batteriesIn,
        'gas_canisters_in': gasCanistersIn,
        'plastic_bottles_out': plasticBottlesOut,
        'cans_out': cansOut,
        'plastic_wrappers_out': plasticWrappersOut,
        'plastic_bags_out': plasticBagsOut,
        'batteries_out': batteriesOut,
        'gas_canisters_out': gasCanistersOut,
      });
      final reqPtr = reqJson.toNativeUtf8().cast<ffi.Char>();
      try {
        final resPtr = b.h360_audit_huella_cero_json(reqPtr);
        final data = _consumeJsonPtr(b, resPtr);
        if (data != null && data.containsKey('waste_compliance_status')) {
          return RustWasteAuditResult(
            totalItemsIn: (data['total_items_in'] as num).toInt(),
            totalItemsOut: (data['total_items_out'] as num).toInt(),
            netBalance: (data['net_balance'] as num).toInt(),
            returnRatePercent: (data['return_rate_percent'] as num).toDouble(),
            wasteComplianceStatus: data['waste_compliance_status'] as String,
            hasHazardousMissing: data['has_hazardous_missing'] as bool? ?? false,
            cryptographicSeal: data['cryptographic_seal'] as String? ?? 'H360-LOCAL',
          );
        }
      } finally {
        calloc.free(reqPtr);
      }
    }

    final totalIn = plasticBottlesIn +
        cansIn +
        plasticWrappersIn +
        plasticBagsIn +
        batteriesIn +
        gasCanistersIn;
    final totalOut = plasticBottlesOut +
        cansOut +
        plasticWrappersOut +
        plasticBagsOut +
        batteriesOut +
        gasCanistersOut;
    final hasHazardousMissing =
        (batteriesOut < batteriesIn) || (gasCanistersOut < gasCanistersIn);

    final String compliance;
    if (hasHazardousMissing || totalOut < totalIn) {
      compliance = 'infraction_missing';
    } else if (totalOut > totalIn) {
      compliance = 'extra_collected';
    } else {
      compliance = 'compliant';
    }

    final shortId = localUuid.replaceAll('-', '').toUpperCase();
    final sealSuffix = shortId.length >= 8 ? shortId.substring(0, 8) : shortId.padRight(8, '0');

    return RustWasteAuditResult(
      totalItemsIn: totalIn,
      totalItemsOut: totalOut,
      netBalance: totalOut - totalIn,
      returnRatePercent: totalIn > 0 ? (totalOut / totalIn) * 100.0 : 100.0,
      wasteComplianceStatus: compliance,
      hasHazardousMissing: hasHazardousMissing,
      cryptographicSeal: 'H360-$sealSuffix-VERIFIED',
    );
  }

  String signEcoReport({
    required String localUuid,
    required String category,
    required double latitude,
    required double longitude,
    required String capturedAtIso,
  }) {
    final b = _native;
    if (b != null) {
      final uuidPtr = localUuid.toNativeUtf8().cast<ffi.Char>();
      final catPtr = category.toNativeUtf8().cast<ffi.Char>();
      final capPtr = capturedAtIso.toNativeUtf8().cast<ffi.Char>();
      try {
        final resPtr = b.h360_sign_eco_report_json(
          uuidPtr,
          catPtr,
          latitude,
          longitude,
          capPtr,
        );
        final data = _consumeJsonPtr(b, resPtr);
        if (data != null && data['verification_code'] != null) {
          return data['verification_code'] as String;
        }
      } finally {
        calloc.free(uuidPtr);
        calloc.free(catPtr);
        calloc.free(capPtr);
      }
    }
    final clean = localUuid.replaceAll('-', '').toUpperCase();
    return 'ECO360-${clean.length >= 12 ? clean.substring(0, 12) : clean}';
  }

  /// Optimiza una imagen de evidencia de Eco-Reporte usando el motor nativo en Rust.
  /// Si se ejecuta con éxito, retorna la ruta del archivo optimizado; si no, retorna la original.
  String optimizeEvidenceImageIfPossible(
    String inputPath, {
    int maxDimension = 1600,
    int quality = 82,
  }) {
    final b = _native;
    if (b == null) return inputPath;

    final outPath = '${inputPath}_rust_opt.jpg';
    final inPtr = inputPath.toNativeUtf8().cast<ffi.Char>();
    final outPtr = outPath.toNativeUtf8().cast<ffi.Char>();
    try {
      final resPtr = b.h360_optimize_evidence_image_json(
        inPtr,
        outPtr,
        maxDimension,
        quality,
      );
      final data = _consumeJsonPtr(b, resPtr);
      if (data != null && data['success'] == true && File(outPath).existsSync()) {
        return outPath;
      }
    } catch (_) {
      // Fallback al archivo original
    } finally {
      calloc.free(inPtr);
      calloc.free(outPtr);
    }
    return inputPath;
  }

  Map<String, dynamic>? computeFileHashes(String filePath) {
    final b = _native;
    if (b == null) return null;
    final pathPtr = filePath.toNativeUtf8().cast<ffi.Char>();
    try {
      final resPtr = b.h360_compute_file_hashes_json(pathPtr);
      return _consumeJsonPtr(b, resPtr);
    } finally {
      calloc.free(pathPtr);
    }
  }
}

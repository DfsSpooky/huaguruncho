import 'dart:io';
import 'package:dio/dio.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../constants/api_endpoints.dart';
import '../rust/rust_core_service.dart';
import '../storage/secure_storage_service.dart';
import '../services/connectivity_service.dart';

class SyncResult {
  final int totalProcessed;
  final int totalSynced;
  final int totalFailed;
  final String message;

  SyncResult({
    required this.totalProcessed,
    required this.totalSynced,
    required this.totalFailed,
    required this.message,
  });
}

class SyncService {
  final AppDatabase _db;
  final DioClient _dioClient;
  final SecureStorageService _storage;
  final ConnectivityService _connectivity;

  SyncService({
    required AppDatabase db,
    required DioClient dioClient,
    required SecureStorageService storage,
    required ConnectivityService connectivity,
  })  : _db = db,
        _dioClient = dioClient,
        _storage = storage,
        _connectivity = connectivity;

  Future<SyncResult> syncPendingReports() async {
    final hasNet = await _connectivity.hasInternetConnection();
    if (!hasNet) {
      return SyncResult(
        totalProcessed: 0,
        totalSynced: 0,
        totalFailed: 0,
        message: 'Sin conexión a internet. Los reportes se mantendrán seguros en tu dispositivo.',
      );
    }

    final hasSession = await _storage.hasValidSession();
    if (!hasSession) {
      return SyncResult(
        totalProcessed: 0,
        totalSynced: 0,
        totalFailed: 0,
        message: 'Inicia sesión para sincronizar tus reportes con la central.',
      );
    }

    final pending = await _db.getPendingSyncReports();
    if (pending.isEmpty) {
      return SyncResult(
        totalProcessed: 0,
        totalSynced: 0,
        totalFailed: 0,
        message: 'Todos tus reportes están al día.',
      );
    }

    // Cambiar estado a syncing
    for (final r in pending) {
      await _db.updateReportStatus(r.localUuid, 'syncing');
    }

    int syncedCount = 0;
    int failedCount = 0;

    try {
      final payload = {
        'reports': pending.map((r) => {
          'local_uuid': r.localUuid,
          'route_uuid': r.routeUuid,
          'category': r.category,
          'description': r.description,
          'latitude': r.latitude,
          'longitude': r.longitude,
          'accuracy_meters': r.accuracyMeters,
          'captured_at': r.capturedAt.toIso8601String(),
        }).toList(),
      };

      final response = await _dioClient.dio.post(
        ApiEndpoints.syncBatch,
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List<dynamic>;

        for (final item in results) {
          final localUuid = item['local_uuid'] as String;
          final success = item['success'] as bool? ?? false;
          final serverUuid = item['server_uuid'] as String?;
          final msg = item['message'] as String? ?? '';

          final originalReport = pending.firstWhere((r) => r.localUuid == localUuid);

          if (success && serverUuid != null) {
            bool photoSuccess = true;
            // Subir imagen si existe (optimizándola primero en Rust para redes de baja cobertura)
            if (originalReport.localImagePath != null && originalReport.localImagePath!.isNotEmpty) {
              final imgFile = File(originalReport.localImagePath!);
              if (await imgFile.exists()) {
                try {
                  final uploadPath = RustCoreService.instance
                      .optimizeEvidenceImageIfPossible(imgFile.path);
                  final formData = FormData.fromMap({
                    'image': await MultipartFile.fromFile(
                      uploadPath,
                      filename: 'evidence_$localUuid.jpg',
                    ),
                  });
                  await _dioClient.dio.post(
                    ApiEndpoints.reportEvidences(serverUuid),
                    data: formData,
                  );
                } catch (e) {
                  photoSuccess = false;
                }
              }
            }

            if (photoSuccess) {
              await _db.updateReportStatus(
                localUuid,
                'synced',
                serverUuid: serverUuid,
                syncedAt: DateTime.now(),
              );
              syncedCount++;
            } else {
              await _db.updateReportStatus(
                localUuid,
                'failed',
                serverUuid: serverUuid,
                error: 'Reporte registrado en servidor, pero la foto de evidencia está pendiente de reintento.',
              );
              failedCount++;
            }
          } else {
            await _db.updateReportStatus(
              localUuid,
              'failed',
              error: msg.isNotEmpty ? msg : 'Error al procesar en servidor',
            );
            failedCount++;
          }
        }
      }
    } catch (e) {
      for (final r in pending) {
        await _db.updateReportStatus(
          r.localUuid,
          'failed',
          error: 'Error de red durante sincronización.',
        );
      }
      return SyncResult(
        totalProcessed: pending.length,
        totalSynced: 0,
        totalFailed: pending.length,
        message: 'Ocurrió un error al contactar con el servidor. Reintentar más tarde.',
      );
    }

    return SyncResult(
      totalProcessed: pending.length,
      totalSynced: syncedCount,
      totalFailed: failedCount,
      message: 'Sincronización completada: $syncedCount enviados, $failedCount con error.',
    );
  }
}

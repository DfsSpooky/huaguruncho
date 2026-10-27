import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/local_file_service.dart';
import '../domain/offline_package_model.dart';

class OfflineRepository {
  final DioClient _dioClient;
  final AppDatabase _db;
  final LocalFileService _fileService;

  OfflineRepository({
    required DioClient dioClient,
    required AppDatabase db,
    required LocalFileService fileService,
  })  : _dioClient = dioClient,
        _db = db,
        _fileService = fileService;

  Future<OfflinePackageModel?> getPackageManifest(String routeUuid) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.routeOfflinePackage(routeUuid));
      if (response.statusCode == 200 && response.data != null) {
        return OfflinePackageModel.fromJson(response.data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> downloadRoutePackage({
    required String routeUuid,
    required Function(double progress, String currentAction) onProgress,
  }) async {
    onProgress(0.1, 'Obteniendo manifiesto del paquete...');
    final pkg = await getPackageManifest(routeUuid);
    if (pkg == null) {
      throw Exception('No se pudo descargar el manifiesto del paquete offline.');
    }

    final manifest = pkg.manifest;
    final routeData = manifest['route'] as Map<String, dynamic>;
    final scenesData = manifest['scenes'] as List<dynamic>? ?? [];

    onProgress(0.2, 'Guardando metadatos de la ruta...');

    // 1. Guardar Ruta en Drift
    await _db.insertOrUpdateRoute(
      LocalRoutesCompanion(
        serverUuid: Value(routeUuid),
        name: Value(routeData['name'] as String? ?? 'Ruta Huaguruncho'),
        description: Value(routeData['description'] as String? ?? ''),
        difficulty: Value(routeData['difficulty'] as String? ?? 'moderada'),
        distanceKm: Value((routeData['distance_km'] as num?)?.toDouble() ?? 0.0),
        estimatedDurationMinutes: Value(routeData['estimated_duration_minutes'] as int? ?? 0),
        isDownloaded: const Value(true),
        packageVersion: Value(pkg.version),
        downloadedAt: Value(DateTime.now()),
      ),
    );

    // 2. Descargar escenas e imágenes 360
    final totalScenes = scenesData.length;
    int sceneIndex = 0;

    for (final s in scenesData) {
      sceneIndex++;
      final sceneUuid = s['uuid'] as String;
      final title = s['title'] as String? ?? 'Escena $sceneIndex';
      final panoUrl = s['panorama_image_url'] as String?;

      onProgress(
        0.2 + (0.7 * (sceneIndex / (totalScenes == 0 ? 1 : totalScenes))),
        'Descargando panorama 360 ($sceneIndex/$totalScenes): $title',
      );

      String localPath = '';
      if (panoUrl != null && panoUrl.isNotEmpty) {
        try {
          final imgResponse = await _dioClient.dio.get<List<int>>(
            panoUrl,
            options: Options(responseType: ResponseType.bytes),
          );
          if (imgResponse.data != null) {
            localPath = await _fileService.saveDownloadedPanorama(imgResponse.data!, sceneUuid);
          }
        } catch (_) {
          // Si falla la descarga remota de imagen individual, dejar path vacío para fallback local
        }
      }

      await _db.insertOrUpdateScene(
        LocalScenesCompanion(
          serverUuid: Value(sceneUuid),
          routeServerUuid: Value(routeUuid),
          title: Value(title),
          description: Value(s['description'] as String? ?? ''),
          panoramaLocalPath: Value(localPath),
          latitude: Value((s['latitude'] as num?)?.toDouble()),
          longitude: Value((s['longitude'] as num?)?.toDouble()),
          sequence: Value(s['sequence'] as int? ?? sceneIndex),
        ),
      );

      // Guardar hotspots de la escena
      final hotspots = s['hotspots'] as List<dynamic>? ?? [];
      for (final h in hotspots) {
        await _db.insertOrUpdateHotspot(
          LocalHotspotsCompanion(
            serverUuid: Value(h['uuid'] as String),
            sourceSceneUuid: Value(sceneUuid),
            targetSceneUuid: Value(h['target_scene_uuid'] as String?),
            type: Value(h['type'] as String? ?? 'navigation'),
            yaw: Value((h['yaw'] as num?)?.toDouble() ?? 0.0),
            pitch: Value((h['pitch'] as num?)?.toDouble() ?? 0.0),
            title: Value(h['title'] as String? ?? ''),
            content: Value(h['content'] as String? ?? ''),
          ),
        );
      }
    }

    onProgress(1.0, '¡Descarga completada!');
  }

  Future<void> removeDownloadedRoute(String routeUuid) async {
    await _db.deleteRouteAndContent(routeUuid);
    await _fileService.deleteOfflinePanoramas();
  }

  Future<List<LocalRoute>> getDownloadedRoutes() => _db.getAllDownloadedRoutes();
}

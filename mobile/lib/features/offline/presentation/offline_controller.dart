import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../../../core/storage/local_file_service.dart';
import '../data/offline_repository.dart';
import '../../../core/database/app_database.dart';

final localFileServiceProvider = Provider<LocalFileService>((ref) {
  return LocalFileService();
});

final offlineRepositoryProvider = Provider<OfflineRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final fileService = ref.watch(localFileServiceProvider);

  return OfflineRepository(
    dioClient: dioClient,
    db: db,
    fileService: fileService,
  );
});

final downloadedRoutesProvider = FutureProvider<List<LocalRoute>>((ref) async {
  final repository = ref.watch(offlineRepositoryProvider);
  return repository.getDownloadedRoutes();
});

class DownloadState {
  final bool isDownloading;
  final double progress;
  final String statusText;
  final String? error;

  DownloadState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.statusText = '',
    this.error,
  });

  DownloadState copyWith({
    bool? isDownloading,
    double? progress,
    String? statusText,
    String? error,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      statusText: statusText ?? this.statusText,
      error: error,
    );
  }
}

class DownloadController extends StateNotifier<DownloadState> {
  final OfflineRepository _repository;

  DownloadController(this._repository) : super(DownloadState());

  Future<bool> downloadRoute(String routeUuid) async {
    state = DownloadState(isDownloading: true, progress: 0.05, statusText: 'Iniciando descarga...');
    try {
      await _repository.downloadRoutePackage(
        routeUuid: routeUuid,
        onProgress: (p, text) {
          state = state.copyWith(progress: p, statusText: text);
        },
      );
      state = state.copyWith(isDownloading: false, progress: 1.0, statusText: '¡Completado con éxito!');
      return true;
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: e.toString(),
        statusText: 'Error en la descarga',
      );
      return false;
    }
  }

  Future<void> removeRoute(String routeUuid) async {
    await _repository.removeDownloadedRoute(routeUuid);
  }
}

final downloadControllerProvider = StateNotifierProvider<DownloadController, DownloadState>((ref) {
  final repo = ref.watch(offlineRepositoryProvider);
  return DownloadController(repo);
});

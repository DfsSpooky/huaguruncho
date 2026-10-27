import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';
import '../services/connectivity_service.dart';
import 'sync_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storageService: storage);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final dioClient = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  final connectivity = ref.watch(connectivityServiceProvider);

  return SyncService(
    db: db,
    dioClient: dioClient,
    storage: storage,
    connectivity: connectivity,
  );
});

// Sync State Notifier
class SyncState {
  final bool isSyncing;
  final bool isOnline;
  final SyncResult? lastResult;
  final String? error;

  SyncState({
    this.isSyncing = false,
    this.isOnline = true,
    this.lastResult,
    this.error,
  });

  SyncState copyWith({
    bool? isSyncing,
    bool? isOnline,
    SyncResult? lastResult,
    String? error,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
      lastResult: lastResult ?? this.lastResult,
      error: error ?? this.error,
    );
  }
}

class SyncController extends StateNotifier<SyncState> {
  final SyncService _syncService;
  final ConnectivityService _connectivityService;

  SyncController({
    required SyncService syncService,
    required ConnectivityService connectivityService,
  })  : _syncService = syncService,
        _connectivityService = connectivityService,
        super(SyncState()) {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final initialNet = await _connectivityService.hasInternetConnection();
    if (mounted) {
      state = state.copyWith(isOnline: initialNet);
      if (initialNet) {
        syncNow();
      }
    }
    _connectivityService.onConnectivityChanged.listen((hasNet) {
      if (!mounted) return;
      final wasOffline = !state.isOnline;
      state = state.copyWith(isOnline: hasNet);
      if (hasNet && wasOffline) {
        syncNow();
      }
    });
  }

  Future<SyncResult> syncNow() async {
    if (state.isSyncing) {
      return SyncResult(
        totalProcessed: 0,
        totalSynced: 0,
        totalFailed: 0,
        message: 'Sincronización en curso...',
      );
    }

    final hasNet = await _connectivityService.hasInternetConnection();
    state = state.copyWith(isSyncing: true, isOnline: hasNet, error: null);
    try {
      final result = await _syncService.syncPendingReports();
      state = state.copyWith(isSyncing: false, lastResult: result);
      return result;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: 'Error inesperado durante la sincronización: $e',
      );
      return SyncResult(
        totalProcessed: 0,
        totalSynced: 0,
        totalFailed: 0,
        message: 'Error: $e',
      );
    }
  }
}

final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return SyncController(
    syncService: syncService,
    connectivityService: connectivity,
  );
});


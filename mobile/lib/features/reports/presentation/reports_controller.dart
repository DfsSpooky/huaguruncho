import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/reports_repository.dart';
import '../domain/report_model.dart';
import '../../offline/presentation/offline_controller.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/camera_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
final cameraServiceProvider = Provider<CameraService>((ref) => CameraService());

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final fileService = ref.watch(localFileServiceProvider);
  final syncService = ref.watch(syncServiceProvider);

  return ReportsRepository(
    db: db,
    fileService: fileService,
    syncService: syncService,
  );
});

final myReportsStreamProvider = StreamProvider<List<ReportModel>>((ref) {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.watchReports();
});

final reportDetailProvider = FutureProvider.family<ReportModel?, String>((ref, localUuid) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getReportByLocalUuid(localUuid);
});

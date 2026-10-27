import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/storage/local_file_service.dart';
import '../../../core/sync/sync_service.dart';
import '../domain/report_model.dart';

class ReportsRepository {
  final AppDatabase _db;
  final LocalFileService _fileService;
  final SyncService _syncService;

  ReportsRepository({
    required AppDatabase db,
    required LocalFileService fileService,
    required SyncService syncService,
  })  : _db = db,
        _fileService = fileService,
        _syncService = syncService;

  Future<String> createReport({
    required String category,
    required String description,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? tempImagePath,
    String? routeUuid,
  }) async {
    final localUuid = const Uuid().v4();
    String? permanentImagePath;

    if (tempImagePath != null && tempImagePath.isNotEmpty) {
      permanentImagePath = await _fileService.saveReportImage(tempImagePath, localUuid);
    }

    await _db.insertReport(
      PendingReportsCompanion(
        localUuid: Value(localUuid),
        routeUuid: Value(routeUuid),
        category: Value(category),
        description: Value(description),
        latitude: Value(latitude),
        longitude: Value(longitude),
        accuracyMeters: Value(accuracyMeters),
        capturedAt: Value(DateTime.now()),
        localImagePath: Value(permanentImagePath),
        syncStatus: const Value('pending'),
      ),
    );

    // Intentar auto-sincronización en segundo plano sin bloquear el guardado local
    _syncService.syncPendingReports().ignore();

    return localUuid;
  }

  Stream<List<ReportModel>> watchReports() {
    return _db.watchAllReports().map((list) => list.map((p) => ReportModel.fromDrift(p)).toList());
  }

  Future<List<ReportModel>> getAllReports() async {
    final list = await _db.getAllReports();
    return list.map((p) => ReportModel.fromDrift(p)).toList();
  }

  Future<ReportModel?> getReportByLocalUuid(String localUuid) async {
    final report = await _db.getReportByLocalUuid(localUuid);
    return report != null ? ReportModel.fromDrift(report) : null;
  }
}

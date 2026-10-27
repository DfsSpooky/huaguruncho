import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/rust/rust_core_service.dart';
import '../domain/checkpoint_model.dart';

class CheckpointRepository {
  final AppDatabase _db;
  final DioClient _dioClient;

  CheckpointRepository({
    required AppDatabase db,
    required DioClient dioClient,
  })  : _db = db,
        _dioClient = dioClient;

  CheckpointModel _mapFromDrift(LocalCheckpointRegistration entity) {
    return CheckpointModel(
      id: entity.id,
      localUuid: entity.localUuid,
      serverUuid: entity.serverUuid,
      checkpointName: entity.checkpointName,
      visitorName: entity.visitorName,
      documentType: entity.documentType,
      documentNumber: entity.documentNumber,
      phoneNumber: entity.phoneNumber,
      groupSize: entity.groupSize,
      routeName: entity.routeName,
      guideName: entity.guideName,
      entryDateTime: entity.entryDateTime,
      entryRangerName: entity.entryRangerName,
      plasticBottlesIn: entity.plasticBottlesIn,
      cansIn: entity.cansIn,
      plasticWrappersIn: entity.plasticWrappersIn,
      plasticBagsIn: entity.plasticBagsIn,
      batteriesIn: entity.batteriesIn,
      gasCanistersIn: entity.gasCanistersIn,
      otherWasteDetailsIn: entity.otherWasteDetailsIn,
      totalItemsIn: entity.totalItemsIn,
      exitDateTime: entity.exitDateTime,
      exitRangerName: entity.exitRangerName,
      plasticBottlesOut: entity.plasticBottlesOut,
      cansOut: entity.cansOut,
      plasticWrappersOut: entity.plasticWrappersOut,
      plasticBagsOut: entity.plasticBagsOut,
      batteriesOut: entity.batteriesOut,
      gasCanistersOut: entity.gasCanistersOut,
      totalItemsOut: entity.totalItemsOut,
      wasteComplianceStatus: entity.wasteComplianceStatus,
      status: entity.status,
      notes: entity.notes,
      syncStatus: entity.syncStatus,
      syncError: entity.syncError,
      syncedAt: entity.syncedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Stream<List<CheckpointModel>> watchActiveInMountain() {
    return _db.watchActiveInMountainCheckpoints().map(
      (list) => list.map(_mapFromDrift).toList(),
    );
  }

  Stream<List<CheckpointModel>> watchAll() {
    return _db.watchAllCheckpointRegistrations().map(
      (list) => list.map(_mapFromDrift).toList(),
    );
  }

  Future<CheckpointModel?> getByLocalUuid(String localUuid) async {
    final entity = await _db.getCheckpointByLocalUuid(localUuid);
    return entity != null ? _mapFromDrift(entity) : null;
  }

  Future<void> registerCheckin(CheckpointModel entry) async {
    final totalIn = entry.calculatedTotalIn;
    await _db.insertCheckpoint(
      LocalCheckpointRegistrationsCompanion(
        localUuid: Value(entry.localUuid),
        checkpointName: Value(entry.checkpointName),
        visitorName: Value(entry.visitorName),
        documentType: Value(entry.documentType),
        documentNumber: Value(entry.documentNumber),
        phoneNumber: Value(entry.phoneNumber),
        groupSize: Value(entry.groupSize),
        routeName: Value(entry.routeName),
        guideName: Value(entry.guideName),
        entryDateTime: Value(entry.entryDateTime),
        entryRangerName: Value(entry.entryRangerName),
        plasticBottlesIn: Value(entry.plasticBottlesIn),
        cansIn: Value(entry.cansIn),
        plasticWrappersIn: Value(entry.plasticWrappersIn),
        plasticBagsIn: Value(entry.plasticBagsIn),
        batteriesIn: Value(entry.batteriesIn),
        gasCanistersIn: Value(entry.gasCanistersIn),
        otherWasteDetailsIn: Value(entry.otherWasteDetailsIn),
        totalItemsIn: Value(totalIn),
        wasteComplianceStatus: const Value('pending_checkout'),
        status: const Value('en_montana'),
        syncStatus: const Value('pending'),
        createdAt: Value(entry.createdAt),
        updatedAt: Value(entry.updatedAt),
      ),
    );
  }

  Future<void> registerCheckout({
    required String localUuid,
    required DateTime exitDateTime,
    required String exitRangerName,
    required int plasticBottlesOut,
    required int cansOut,
    required int plasticWrappersOut,
    required int plasticBagsOut,
    required int batteriesOut,
    required int gasCanistersOut,
    String? notes,
  }) async {
    final current = await _db.getCheckpointByLocalUuid(localUuid);
    if (current == null) return;

    final audit = RustCoreService.instance.auditHuellaCero(
      localUuid: localUuid,
      documentNumber: current.documentNumber,
      plasticBottlesIn: current.plasticBottlesIn,
      cansIn: current.cansIn,
      plasticWrappersIn: current.plasticWrappersIn,
      plasticBagsIn: current.plasticBagsIn,
      batteriesIn: current.batteriesIn,
      gasCanistersIn: current.gasCanistersIn,
      plasticBottlesOut: plasticBottlesOut,
      cansOut: cansOut,
      plasticWrappersOut: plasticWrappersOut,
      plasticBagsOut: plasticBagsOut,
      batteriesOut: batteriesOut,
      gasCanistersOut: gasCanistersOut,
    );

    final existingNotes = notes?.trim() ?? '';
    final enrichedNotes = existingNotes.isEmpty
        ? '[Sello Rust: ${audit.cryptographicSeal}]'
        : '$existingNotes [Sello Rust: ${audit.cryptographicSeal}]';

    await _db.updateCheckpointCheckout(
      localUuid: localUuid,
      exitDateTime: exitDateTime,
      exitRangerName: exitRangerName,
      plasticBottlesOut: plasticBottlesOut,
      cansOut: cansOut,
      plasticWrappersOut: plasticWrappersOut,
      plasticBagsOut: plasticBagsOut,
      batteriesOut: batteriesOut,
      gasCanistersOut: gasCanistersOut,
      totalItemsOut: audit.totalItemsOut,
      wasteComplianceStatus: audit.wasteComplianceStatus,
      status: 'completado',
      notes: enrichedNotes,
    );
  }

  Future<int> syncPendingWithBackend() async {
    final pendingEntities = await _db.getPendingSyncCheckpoints();
    if (pendingEntities.isEmpty) return 0;

    final payload = {
      'entries': pendingEntities.map((e) => _mapFromDrift(e).toSyncJson()).toList(),
    };

    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.checkpointSyncBatch,
        data: payload,
      );

      final results = response.data['results'] as List<dynamic>? ?? [];
      final now = DateTime.now();
      int syncedCount = 0;

      for (final res in results) {
        final localUuid = res['local_uuid'] as String?;
        final serverUuid = res['server_uuid'] as String?;
        final status = res['status'] as String?;

        if (localUuid != null && status == 'synced') {
          await _db.updateCheckpointSyncStatus(
            localUuid,
            'synced',
            serverUuid: serverUuid,
            syncedAt: now,
          );
          syncedCount++;
        }
      }

      return syncedCount;
    } on DioException catch (e) {
      // Si falla la red (porque estamos en la montaña sin señal), se mantiene offline
      for (final entity in pendingEntities) {
        await _db.updateCheckpointSyncStatus(
          entity.localUuid,
          'failed',
          error: e.message ?? 'Sin conexión al servidor',
        );
      }
      rethrow;
    }
  }
}

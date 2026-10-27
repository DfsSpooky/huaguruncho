import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tables definition
class LocalRoutes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverUuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get difficulty => text()();
  RealColumn get distanceKm => real()();
  IntColumn get estimatedDurationMinutes => integer()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  IntColumn get packageVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get downloadedAt => dateTime().nullable()();
}

class LocalScenes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverUuid => text().unique()();
  TextColumn get routeServerUuid => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get panoramaLocalPath => text()();
  TextColumn get thumbnailLocalPath => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get sequence => integer().withDefault(const Constant(1))();
}

class LocalHotspots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverUuid => text().unique()();
  TextColumn get sourceSceneUuid => text()();
  TextColumn get targetSceneUuid => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('navigation'))();
  RealColumn get yaw => real().withDefault(const Constant(0.0))();
  RealColumn get pitch => real().withDefault(const Constant(0.0))();
  TextColumn get title => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
}

class PendingReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localUuid => text().unique()();
  TextColumn get serverUuid => text().nullable()();
  IntColumn get userId => integer().nullable()();
  TextColumn get routeUuid => text().nullable()();
  TextColumn get category => text()();
  TextColumn get description => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get accuracyMeters => real().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))(); // pending, syncing, synced, failed
  TextColumn get syncError => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SafetyChecklists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recommendationKey => text().unique()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalCheckpointRegistrations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localUuid => text().unique()();
  TextColumn get serverUuid => text().nullable()();
  TextColumn get checkpointName => text().withDefault(const Constant('Garita de Control Huaguruncho - Abra Huachón'))();
  TextColumn get visitorName => text()();
  TextColumn get documentType => text().withDefault(const Constant('DNI'))();
  TextColumn get documentNumber => text()();
  TextColumn get phoneNumber => text().withDefault(const Constant(''))();
  IntColumn get groupSize => integer().withDefault(const Constant(1))();
  TextColumn get routeName => text().withDefault(const Constant('Nevado Huaguruncho - Ruta Glaciar'))();
  TextColumn get guideName => text().nullable()();
  DateTimeColumn get entryDateTime => dateTime()();
  TextColumn get entryRangerName => text().nullable()();

  // Residuos Subida (Entrada)
  IntColumn get plasticBottlesIn => integer().withDefault(const Constant(0))();
  IntColumn get cansIn => integer().withDefault(const Constant(0))();
  IntColumn get plasticWrappersIn => integer().withDefault(const Constant(0))();
  IntColumn get plasticBagsIn => integer().withDefault(const Constant(0))();
  IntColumn get batteriesIn => integer().withDefault(const Constant(0))();
  IntColumn get gasCanistersIn => integer().withDefault(const Constant(0))();
  TextColumn get otherWasteDetailsIn => text().nullable()();
  IntColumn get totalItemsIn => integer().withDefault(const Constant(0))();

  // Residuos Bajada (Check-out)
  DateTimeColumn get exitDateTime => dateTime().nullable()();
  TextColumn get exitRangerName => text().nullable()();
  IntColumn get plasticBottlesOut => integer().withDefault(const Constant(0))();
  IntColumn get cansOut => integer().withDefault(const Constant(0))();
  IntColumn get plasticWrappersOut => integer().withDefault(const Constant(0))();
  IntColumn get plasticBagsOut => integer().withDefault(const Constant(0))();
  IntColumn get batteriesOut => integer().withDefault(const Constant(0))();
  IntColumn get gasCanistersOut => integer().withDefault(const Constant(0))();
  IntColumn get totalItemsOut => integer().withDefault(const Constant(0))();

  TextColumn get wasteComplianceStatus => text().withDefault(const Constant('pending_checkout'))(); // pending_checkout, compliant, extra_collected, infraction_missing
  TextColumn get status => text().withDefault(const Constant('en_montana'))(); // en_montana, completado, alerta_retraso
  TextColumn get notes => text().nullable()();

  // Sync
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))(); // pending, syncing, synced, failed
  TextColumn get syncError => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  LocalRoutes,
  LocalScenes,
  LocalHotspots,
  PendingReports,
  SafetyChecklists,
  LocalCheckpointRegistrations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(localCheckpointRegistrations);
      }
    },
  );

  // Route Queries
  Future<List<LocalRoute>> getAllDownloadedRoutes() =>
      (select(localRoutes)..where((tbl) => tbl.isDownloaded.equals(true))).get();

  Future<LocalRoute?> getRouteByUuid(String uuid) =>
      (select(localRoutes)..where((tbl) => tbl.serverUuid.equals(uuid))).getSingleOrNull();

  Future<int> insertOrUpdateRoute(LocalRoutesCompanion route) =>
      into(localRoutes).insertOnConflictUpdate(route);

  Future<int> deleteRouteAndContent(String routeUuid) async {
    await (delete(localHotspots)..where((tbl) => tbl.sourceSceneUuid.isInQuery(
      selectOnly(localScenes)..addColumns([localScenes.serverUuid])..where(localScenes.routeServerUuid.equals(routeUuid))
    ))).go();
    await (delete(localScenes)..where((tbl) => tbl.routeServerUuid.equals(routeUuid))).go();
    return (delete(localRoutes)..where((tbl) => tbl.serverUuid.equals(routeUuid))).go();
  }

  // Scene & Hotspot Queries
  Future<List<LocalScene>> getScenesForRoute(String routeUuid) =>
      (select(localScenes)..where((tbl) => tbl.routeServerUuid.equals(routeUuid))..orderBy([(t) => OrderingTerm.asc(t.sequence)])).get();

  Future<LocalScene?> getSceneByUuid(String uuid) =>
      (select(localScenes)..where((tbl) => tbl.serverUuid.equals(uuid))).getSingleOrNull();

  Future<List<LocalHotspot>> getHotspotsForScene(String sceneUuid) =>
      (select(localHotspots)..where((tbl) => tbl.sourceSceneUuid.equals(sceneUuid))).get();

  Future<int> insertOrUpdateScene(LocalScenesCompanion scene) =>
      into(localScenes).insertOnConflictUpdate(scene);

  Future<int> insertOrUpdateHotspot(LocalHotspotsCompanion hotspot) =>
      into(localHotspots).insertOnConflictUpdate(hotspot);

  // Pending Reports Queries
  Stream<List<PendingReport>> watchAllReports() =>
      (select(pendingReports)..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])).watch();

  Future<List<PendingReport>> getAllReports() =>
      (select(pendingReports)..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])).get();

  Future<List<PendingReport>> getPendingSyncReports() =>
      (select(pendingReports)..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed'))).get();

  Future<PendingReport?> getReportByLocalUuid(String localUuid) =>
      (select(pendingReports)..where((tbl) => tbl.localUuid.equals(localUuid))).getSingleOrNull();

  Future<int> insertReport(PendingReportsCompanion report) =>
      into(pendingReports).insert(report);

  Future<bool> updateReportStatus(String localUuid, String status, {String? serverUuid, String? error, DateTime? syncedAt}) {
    return (update(pendingReports)..where((tbl) => tbl.localUuid.equals(localUuid))).write(
      PendingReportsCompanion(
        syncStatus: Value(status),
        serverUuid: serverUuid != null ? Value(serverUuid) : const Value.absent(),
        syncError: Value(error),
        syncedAt: syncedAt != null ? Value(syncedAt) : const Value.absent(),
      ),
    ).then((rows) => rows > 0);
  }

  // Safety Checklist Queries
  Stream<List<SafetyChecklist>> watchChecklist() => select(safetyChecklists).watch();

  Future<List<SafetyChecklist>> getChecklist() => select(safetyChecklists).get();

  Future<void> toggleChecklistItem(String key, bool isChecked) {
    return into(safetyChecklists).insertOnConflictUpdate(
      SafetyChecklistsCompanion(
        recommendationKey: Value(key),
        isChecked: Value(isChecked),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Checkpoint Registrations (Guardaparques / Residuos) Queries
  Stream<List<LocalCheckpointRegistration>> watchAllCheckpointRegistrations() =>
      (select(localCheckpointRegistrations)..orderBy([(t) => OrderingTerm.desc(t.entryDateTime)])).watch();

  Stream<List<LocalCheckpointRegistration>> watchActiveInMountainCheckpoints() =>
      (select(localCheckpointRegistrations)
        ..where((tbl) => tbl.status.equals('en_montana'))
        ..orderBy([(t) => OrderingTerm.desc(t.entryDateTime)])).watch();

  Future<List<LocalCheckpointRegistration>> getAllCheckpointRegistrations() =>
      (select(localCheckpointRegistrations)..orderBy([(t) => OrderingTerm.desc(t.entryDateTime)])).get();

  Future<List<LocalCheckpointRegistration>> getPendingSyncCheckpoints() =>
      (select(localCheckpointRegistrations)..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed'))).get();

  Future<LocalCheckpointRegistration?> getCheckpointByLocalUuid(String localUuid) =>
      (select(localCheckpointRegistrations)..where((tbl) => tbl.localUuid.equals(localUuid))).getSingleOrNull();

  Future<int> insertCheckpoint(LocalCheckpointRegistrationsCompanion entry) =>
      into(localCheckpointRegistrations).insert(entry);

  Future<bool> updateCheckpointCheckout({
    required String localUuid,
    required DateTime exitDateTime,
    required String exitRangerName,
    required int plasticBottlesOut,
    required int cansOut,
    required int plasticWrappersOut,
    required int plasticBagsOut,
    required int batteriesOut,
    required int gasCanistersOut,
    required int totalItemsOut,
    required String wasteComplianceStatus,
    required String status,
    String? notes,
  }) {
    return (update(localCheckpointRegistrations)..where((tbl) => tbl.localUuid.equals(localUuid))).write(
      LocalCheckpointRegistrationsCompanion(
        exitDateTime: Value(exitDateTime),
        exitRangerName: Value(exitRangerName),
        plasticBottlesOut: Value(plasticBottlesOut),
        cansOut: Value(cansOut),
        plasticWrappersOut: Value(plasticWrappersOut),
        plasticBagsOut: Value(plasticBagsOut),
        batteriesOut: Value(batteriesOut),
        gasCanistersOut: Value(gasCanistersOut),
        totalItemsOut: Value(totalItemsOut),
        wasteComplianceStatus: Value(wasteComplianceStatus),
        status: Value(status),
        notes: notes != null ? Value(notes) : const Value.absent(),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }

  Future<bool> updateCheckpointSyncStatus(
    String localUuid,
    String status, {
    String? serverUuid,
    String? error,
    DateTime? syncedAt,
  }) {
    return (update(localCheckpointRegistrations)..where((tbl) => tbl.localUuid.equals(localUuid))).write(
      LocalCheckpointRegistrationsCompanion(
        syncStatus: Value(status),
        serverUuid: serverUuid != null ? Value(serverUuid) : const Value.absent(),
        syncError: Value(error),
        syncedAt: syncedAt != null ? Value(syncedAt) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'huaguruncho_360.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/sync/sync_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/checkpoint_repository.dart';
import '../domain/checkpoint_model.dart';

final checkpointRepositoryProvider = Provider<CheckpointRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final dioClient = ref.watch(dioClientProvider);
  return CheckpointRepository(db: db, dioClient: dioClient);
});

final activeInMountainStreamProvider = StreamProvider<List<CheckpointModel>>((ref) {
  final repo = ref.watch(checkpointRepositoryProvider);
  return repo.watchActiveInMountain();
});

final allCheckpointStreamProvider = StreamProvider<List<CheckpointModel>>((ref) {
  final repo = ref.watch(checkpointRepositoryProvider);
  return repo.watchAll();
});

class CheckpointState {
  final bool isSyncing;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const CheckpointState({
    this.isSyncing = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  CheckpointState copyWith({
    bool? isSyncing,
    bool? isSaving,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CheckpointState(
      isSyncing: isSyncing ?? this.isSyncing,
      isSaving: isSaving ?? this.isSaving,
      error: clearMessages ? null : (error ?? this.error),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class CheckpointController extends StateNotifier<CheckpointState> {
  final CheckpointRepository _repository;
  final Ref _ref;

  CheckpointController(this._repository, this._ref) : super(const CheckpointState());

  Future<bool> registerCheckin({
    required String visitorName,
    required String documentType,
    required String documentNumber,
    required String phoneNumber,
    required int groupSize,
    required String routeName,
    String? guideName,
    required int plasticBottlesIn,
    required int cansIn,
    required int plasticWrappersIn,
    required int plasticBagsIn,
    required int batteriesIn,
    required int gasCanistersIn,
    String? otherWasteDetailsIn,
  }) async {
    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      final authUser = _ref.read(authControllerProvider).user;
      final rangerName = authUser?.fullName ?? 'Guardaparque de Turno';
      final now = DateTime.now();
      final localUuid = const Uuid().v4();

      final totalIn = plasticBottlesIn +
          cansIn +
          plasticWrappersIn +
          plasticBagsIn +
          batteriesIn +
          gasCanistersIn;

      final model = CheckpointModel(
        localUuid: localUuid,
        visitorName: visitorName.trim(),
        documentType: documentType,
        documentNumber: documentNumber.trim(),
        phoneNumber: phoneNumber.trim(),
        groupSize: groupSize,
        routeName: routeName,
        guideName: guideName?.trim().isNotEmpty == true ? guideName!.trim() : null,
        entryDateTime: now,
        entryRangerName: rangerName,
        plasticBottlesIn: plasticBottlesIn,
        cansIn: cansIn,
        plasticWrappersIn: plasticWrappersIn,
        plasticBagsIn: plasticBagsIn,
        batteriesIn: batteriesIn,
        gasCanistersIn: gasCanistersIn,
        otherWasteDetailsIn: otherWasteDetailsIn?.trim().isNotEmpty == true ? otherWasteDetailsIn!.trim() : null,
        totalItemsIn: totalIn,
        wasteComplianceStatus: 'pending_checkout',
        status: 'en_montana',
        syncStatus: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      await _repository.registerCheckin(model);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Entrada registrada en base local (SQLite Offline). ¡Buen ascenso!',
      );

      // Intento oportunista de sincronizar si hay red (silencioso)
      _repository.syncPendingWithBackend().catchError((_) => 0);

      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> registerCheckout({
    required String localUuid,
    required int plasticBottlesOut,
    required int cansOut,
    required int plasticWrappersOut,
    required int plasticBagsOut,
    required int batteriesOut,
    required int gasCanistersOut,
    String? notes,
  }) async {
    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      final authUser = _ref.read(authControllerProvider).user;
      final rangerName = authUser?.fullName ?? 'Guardaparque de Turno';
      final now = DateTime.now();

      await _repository.registerCheckout(
        localUuid: localUuid,
        exitDateTime: now,
        exitRangerName: rangerName,
        plasticBottlesOut: plasticBottlesOut,
        cansOut: cansOut,
        plasticWrappersOut: plasticWrappersOut,
        plasticBagsOut: plasticBagsOut,
        batteriesOut: batteriesOut,
        gasCanistersOut: gasCanistersOut,
        notes: notes,
      );

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Descenso y retorno de residuos registrado correctamente en SQLite local.',
      );

      // Intento oportunista de sincronizar si hay red (silencioso)
      _repository.syncPendingWithBackend().catchError((_) => 0);

      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<void> syncNow() async {
    state = state.copyWith(isSyncing: true, clearMessages: true);
    try {
      final count = await _repository.syncPendingWithBackend();
      state = state.copyWith(
        isSyncing: false,
        successMessage: count > 0
            ? '¡Sincronización completada! $count registros actualizados en el servidor.'
            : 'Todo está al día con el servidor.',
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: 'Sin conexión disponible. Los datos se mantienen 100% seguros en SQLite local.',
      );
    }
  }
}

final checkpointControllerProvider = StateNotifierProvider<CheckpointController, CheckpointState>((ref) {
  final repository = ref.watch(checkpointRepositoryProvider);
  return CheckpointController(repository, ref);
});

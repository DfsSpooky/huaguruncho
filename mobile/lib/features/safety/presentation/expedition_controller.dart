import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/expedition_repository.dart';
import '../domain/expedition_model.dart';

final expeditionRepositoryProvider = Provider<ExpeditionRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ExpeditionRepository(dioClient: dioClient);
});

final activeExpeditionProvider = StateNotifierProvider<ActiveExpeditionNotifier, AsyncValue<ExpeditionModel?>>((ref) {
  final repo = ref.watch(expeditionRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final userName = authState.isAuthenticated ? authState.user?.fullName : null;
  return ActiveExpeditionNotifier(repo, currentUserName: userName);
});

class ActiveExpeditionNotifier extends StateNotifier<AsyncValue<ExpeditionModel?>> {
  final ExpeditionRepository _repo;
  final String? currentUserName;

  ActiveExpeditionNotifier(this._repo, {this.currentUserName})
      : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final exp = await _repo.getActiveExpedition(currentUserName: currentUserName);
      state = AsyncValue.data(exp);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> registerExpedition({
    required String touristName,
    required String touristPhone,
    required String emergencyContactName,
    required String emergencyContactPhone,
    String? routeId,
    required int groupSize,
    required String guideName,
    required DateTime departureDatetime,
    required DateTime expectedReturnDatetime,
    required String healthNotes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final exp = await _repo.registerExpedition(
        touristName: touristName,
        touristPhone: touristPhone,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        routeId: routeId,
        groupSize: groupSize,
        guideName: guideName,
        departureDatetime: departureDatetime,
        expectedReturnDatetime: expectedReturnDatetime,
        healthNotes: healthNotes,
      );
      state = AsyncValue.data(exp);
      return exp != null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> checkOut(String uuid) async {
    try {
      final success = await _repo.checkOut(uuid);
      state = const AsyncValue.data(null);
      return success;
    } catch (_) {
      state = const AsyncValue.data(null);
      return true;
    }
  }
}

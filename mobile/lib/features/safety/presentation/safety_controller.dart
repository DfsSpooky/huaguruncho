import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/safety_repository.dart';
import '../domain/safety_model.dart';

final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return SafetyRepository(dioClient: dioClient, db: db);
});

final safetyRecommendationsProvider = FutureProvider<List<SafetyModel>>((ref) async {
  final repository = ref.watch(safetyRepositoryProvider);
  return repository.getRecommendations();
});

class SafetyChecklistNotifier extends StateNotifier<List<SafetyModel>> {
  final SafetyRepository _repository;

  SafetyChecklistNotifier(this._repository) : super([]) {
    load();
  }

  Future<void> load() async {
    final list = await _repository.getRecommendations();
    state = list;
  }

  Future<void> toggleItem(int id, bool isChecked) async {
    await _repository.toggleChecklistItem(id, isChecked);
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isChecked: isChecked);
      }
      return item;
    }).toList();
  }
}

final safetyChecklistControllerProvider =
    StateNotifierProvider<SafetyChecklistNotifier, List<SafetyModel>>((ref) {
  final repo = ref.watch(safetyRepositoryProvider);
  return SafetyChecklistNotifier(repo);
});

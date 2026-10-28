import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/tours_repository.dart';
import '../domain/scene_model.dart';

final toursRepositoryProvider = Provider<ToursRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return ToursRepository(dioClient: dioClient, db: db);
});

final currentTourRouteUuidProvider = StateProvider<String?>((ref) => null);
final currentTourSceneIndexProvider = StateProvider<int>((ref) => 0);

final availableTourRoutesProvider = FutureProvider<List<TourRouteSummary>>((ref) async {
  final repository = ref.watch(toursRepositoryProvider);
  return repository.getAvailableTourRoutes();
});

final tourScenesProvider = FutureProvider.family<List<SceneModel>, String?>((ref, routeUuid) async {
  final repository = ref.watch(toursRepositoryProvider);
  return repository.getScenesForRoute(routeUuid);
});

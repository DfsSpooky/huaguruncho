import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/routes_repository.dart';
import '../domain/route_model.dart';

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return RoutesRepository(dioClient: dioClient, db: db);
});

final routesListProvider = FutureProvider<List<RouteModel>>((ref) async {
  final repository = ref.watch(routesRepositoryProvider);
  return repository.getRoutes();
});

final routeDetailProvider = FutureProvider.family<RouteModel?, String>((ref, uuid) async {
  final repository = ref.watch(routesRepositoryProvider);
  return repository.getRouteDetail(uuid);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/community_services_repository.dart';
import '../domain/community_service_model.dart';

final communityServicesRepositoryProvider = Provider<CommunityServicesRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return CommunityServicesRepository(dioClient: dio);
});

final communityServicesListProvider = FutureProvider<List<CommunityServiceModel>>((ref) async {
  final repo = ref.watch(communityServicesRepositoryProvider);
  return repo.getServices();
});

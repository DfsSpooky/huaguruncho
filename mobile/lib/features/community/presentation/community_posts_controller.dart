import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/community_posts_repository.dart';
import '../domain/community_post_model.dart';

final communityPostsRepositoryProvider = Provider<CommunityPostsRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return CommunityPostsRepository(dioClient: dio);
});

final selectedCommunityFilterProvider = StateProvider<String>((ref) => 'Todos');

final communityPostsListProvider = FutureProvider<List<CommunityPostModel>>((ref) async {
  final repo = ref.watch(communityPostsRepositoryProvider);
  final filter = ref.watch(selectedCommunityFilterProvider);
  return repo.getPosts(category: filter);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/audio_guides_repository.dart';
import '../domain/audio_guide_model.dart';

final audioGuidesRepositoryProvider = Provider<AudioGuidesRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AudioGuidesRepository(dioClient: dio);
});

final selectedAudioGuideIndexProvider = StateProvider<int>((ref) => 0);

final audioGuidesListProvider = FutureProvider<List<AudioGuideModel>>((ref) async {
  final repo = ref.watch(audioGuidesRepositoryProvider);
  return repo.getAudioGuides();
});

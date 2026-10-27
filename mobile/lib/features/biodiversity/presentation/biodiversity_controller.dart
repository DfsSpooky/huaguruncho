import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/biodiversity_repository.dart';
import '../domain/species_model.dart';

final biodiversityRepositoryProvider = Provider<BiodiversityRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return BiodiversityRepository(dioClient: dio);
});

final selectedBiodiversityCategoryProvider = StateProvider<String>((ref) => 'Todos');

final biodiversityListProvider = FutureProvider<List<SpeciesModel>>((ref) async {
  final repo = ref.watch(biodiversityRepositoryProvider);
  final category = ref.watch(selectedBiodiversityCategoryProvider);
  return repo.getSpecies(category: category);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/emergency_repository.dart';
import '../domain/emergency_contact_model.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return EmergencyRepository(dioClient: dio);
});

final emergencyContactsProvider = FutureProvider<List<EmergencyContactModel>>((ref) async {
  final repo = ref.watch(emergencyRepositoryProvider);
  return repo.getEmergencyContacts();
});

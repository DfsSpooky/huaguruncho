import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/municipal_notices_repository.dart';
import '../domain/municipal_notice_model.dart';

final municipalNoticesRepositoryProvider = Provider<MunicipalNoticesRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MunicipalNoticesRepository(dioClient: dioClient);
});

final municipalNoticesProvider = FutureProvider<List<MunicipalNoticeModel>>((ref) async {
  final repository = ref.watch(municipalNoticesRepositoryProvider);
  return repository.getNotices();
});

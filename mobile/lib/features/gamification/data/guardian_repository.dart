import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/sync/sync_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/guardian_models.dart';

abstract class GuardianRepository {
  Future<List<GuardianBadgeModel>> getBadges();
  Future<List<TrailPassportStampModel>> getPassportStamps();
  Future<void> markStampAsCollected(String uuid);
}

class GuardianRepositoryImpl implements GuardianRepository {
  final DioClient _dioClient;
  final String _userScope;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  GuardianRepositoryImpl({
    required DioClient dioClient,
    String userScope = 'guest',
  })  : _dioClient = dioClient,
        _userScope = userScope;

  String get _collectedStampsKey => 'collected_stamps_uuids_$_userScope';

  static const List<GuardianBadgeModel> _fallbackBadges = [
    GuardianBadgeModel(
      uuid: 'badge-01',
      slug: 'caminante-lnt',
      title: 'Caminante No Deje Rastro (LNT)',
      quechuaTitle: 'Allin Purikuy',
      description: 'Completar la lectura de normas de sostenibilidad y descargar la ruta para uso offline.',
      tier: 'bronce',
      tierDisplay: 'Bronce',
      icon: 'eco',
      xpPoints: 50,
      order: 1,
      isUnlocked: true,
    ),
    GuardianBadgeModel(
      uuid: 'badge-02',
      slug: 'centinela-ambiental',
      title: 'Centinela Ambiental de Huachón',
      quechuaTitle: 'Huachón Pachamama Waqaychaq',
      description: 'Emitir un reporte ambiental georreferenciado verificado por la comunidad.',
      tier: 'plata',
      tierDisplay: 'Plata',
      icon: 'verified_user',
      xpPoints: 100,
      order: 2,
      isUnlocked: true,
    ),
    GuardianBadgeModel(
      uuid: 'badge-03',
      slug: 'explorador-huascacocha',
      title: 'Explorador de Huascacocha',
      quechuaTitle: 'Huascacocha Taripaq',
      description: 'Llegar al campamento base de la laguna y completar el avistamiento de aves altoandinas.',
      tier: 'oro',
      tierDisplay: 'Oro',
      icon: 'water_drop',
      xpPoints: 200,
      order: 3,
      isUnlocked: true,
    ),
    GuardianBadgeModel(
      uuid: 'badge-04',
      slug: 'apu-guardian-glacial',
      title: 'Apu Guardián Glacial Huaguruncho',
      quechuaTitle: 'Huaguruncho Hatun Guardián',
      description: 'Alcanzar el Mirador del Glaciar a 4,680 m s.n.m., escuchar las audioguías en quechua y compartir tu testimonio.',
      tier: 'diamante',
      tierDisplay: 'Diamante Glacial',
      icon: 'military_tech',
      xpPoints: 500,
      order: 4,
      isUnlocked: false,
    ),
  ];

  static const List<TrailPassportStampModel> _fallbackStamps = [
    TrailPassportStampModel(
      uuid: 'stamp-01',
      name: 'Sello Plaza Mayor de Huachón',
      quechuaName: 'Huachón Hatun Kancha Sello',
      altitudeMasl: 3400,
      landmarkIcon: 'location_city',
      secretCode: 'STAMP-HUA-3400',
      order: 1,
      latitude: -10.597500,
      longitude: -75.952000,
      isCollected: true,
    ),
    TrailPassportStampModel(
      uuid: 'stamp-02',
      name: 'Sello Pampa Chichuraque',
      quechuaName: 'Chichuraque Pampa Sello',
      altitudeMasl: 3850,
      landmarkIcon: 'forest',
      secretCode: 'STAMP-CHI-3850',
      order: 2,
      latitude: -10.563000,
      longitude: -75.961000,
      isCollected: false,
    ),
    TrailPassportStampModel(
      uuid: 'stamp-03',
      name: 'Sello Laguna Huascacocha',
      quechuaName: 'Huascacocha Qucha Sello',
      altitudeMasl: 4250,
      landmarkIcon: 'waves',
      secretCode: 'STAMP-HUA-4250',
      order: 3,
      latitude: -10.534000,
      longitude: -75.968000,
      isCollected: false,
    ),
    TrailPassportStampModel(
      uuid: 'stamp-04',
      name: 'Sello Morrena Glaciar Huaguruncho',
      quechuaName: 'Huaguruncho Riti Qhawana Sello',
      altitudeMasl: 4680,
      landmarkIcon: 'terrain',
      secretCode: 'STAMP-GLA-4680',
      order: 4,
      latitude: -10.518000,
      longitude: -75.972000,
      isCollected: false,
    ),
    TrailPassportStampModel(
      uuid: 'stamp-05',
      name: 'Sello Cumbre Nevado Huaguruncho',
      quechuaName: 'Huaguruncho Pikchu Sello',
      altitudeMasl: 5742,
      landmarkIcon: 'military_tech',
      secretCode: 'STAMP-CUM-5742',
      order: 5,
      latitude: -10.511000,
      longitude: -75.974000,
      isCollected: false,
    ),
  ];

  Future<Set<String>> getCollectedStampUuids() async {
    try {
      final raw = await _storage.read(key: _collectedStampsKey);
      if (raw != null && raw.isNotEmpty) {
        return raw.split(',').where((s) => s.isNotEmpty).toSet();
      }
    } catch (_) {}
    return {'stamp-01'};
  }

  @override
  Future<void> markStampAsCollected(String uuid) async {
    final collected = await getCollectedStampUuids();
    collected.add(uuid);
    await _storage.write(key: _collectedStampsKey, value: collected.join(','));
  }

  @override
  Future<List<GuardianBadgeModel>> getBadges() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.badges);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] as List<dynamic>? ?? []);
        final parsed = list.map((e) => GuardianBadgeModel.fromJson(e as Map<String, dynamic>)).toList();
        return parsed.isNotEmpty ? parsed : _fallbackBadges;
      }
    } catch (_) {}
    return _fallbackBadges;
  }

  @override
  Future<List<TrailPassportStampModel>> getPassportStamps() async {
    final collectedUuids = await getCollectedStampUuids();
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.passportStamps);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] as List<dynamic>? ?? []);
        final parsed = list.map((e) => TrailPassportStampModel.fromJson(e as Map<String, dynamic>)).toList();
        if (parsed.isNotEmpty) {
          return parsed.map((s) {
            final isCollected = collectedUuids.contains(s.uuid) || s.isCollected;
            return s.copyWith(isCollected: isCollected);
          }).toList();
        }
      }
    } catch (_) {}
    return _fallbackStamps.map((s) {
      final isCollected = collectedUuids.contains(s.uuid) || s.isCollected;
      return s.copyWith(isCollected: isCollected);
    }).toList();
  }
}

final guardianRepositoryProvider = Provider<GuardianRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final user = ref.watch(authControllerProvider).user;
  return GuardianRepositoryImpl(
    dioClient: dio,
    userScope: user?.id.toString() ?? 'guest',
  );
});

final guardianBadgesProvider = FutureProvider<List<GuardianBadgeModel>>((ref) async {
  final repo = ref.watch(guardianRepositoryProvider);
  return repo.getBadges();
});

final passportStampsProvider = FutureProvider<List<TrailPassportStampModel>>((ref) async {
  final repo = ref.watch(guardianRepositoryProvider);
  return repo.getPassportStamps();
});


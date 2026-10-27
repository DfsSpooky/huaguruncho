import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../domain/safety_model.dart';

class SafetyRepository {
  final DioClient _dioClient;
  final AppDatabase _db;

  SafetyRepository({
    required DioClient dioClient,
    required AppDatabase db,
  })  : _dioClient = dioClient,
        _db = db;

  Future<List<SafetyModel>> getRecommendations() async {
    List<SafetyModel> rawList = [];

    // 1. Intentar desde API
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.safetyRecommendations);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        rawList = list.map((json) => SafetyModel.fromJson(json)).toList();
      }
    } catch (_) {}

    // 2. Si falló la red, usar recomendaciones offline por defecto
    if (rawList.isEmpty) {
      rawList = _getDefaultOfflineRecommendations();
    }

    // 3. Cruzar con estado persistente del checklist en Drift
    final checklist = await _db.getChecklist();
    final checkedMap = {for (var c in checklist) c.recommendationKey: c.isChecked};

    return rawList.map((r) {
      final isChecked = checkedMap[r.id.toString()] ?? false;
      return r.copyWith(isChecked: isChecked);
    }).toList();
  }

  Future<void> toggleChecklistItem(int recommendationId, bool isChecked) async {
    await _db.toggleChecklistItem(recommendationId.toString(), isChecked);
  }

  List<SafetyModel> _getDefaultOfflineRecommendations() {
    return const [
      SafetyModel(
        id: 1,
        category: 'equipamiento',
        categoryDisplay: 'Equipamiento',
        title: 'Botas de montaña con caña alta',
        description: 'Suela antideslizante para barro y rocas sueltas.',
        order: 1,
      ),
      SafetyModel(
        id: 2,
        category: 'equipamiento',
        categoryDisplay: 'Equipamiento',
        title: 'Sistema de vestimenta por capas',
        description: 'Primera capa transpirable, segunda térmica y tercera impermeable.',
        order: 2,
      ),
      SafetyModel(
        id: 3,
        category: 'salud',
        categoryDisplay: 'Aclimatación y Salud',
        title: 'Aclimatación previa en Pasco',
        description: 'Permanecer 24 a 48 horas en altitud antes de ascensos sobre 4,000 msnm.',
        order: 1,
      ),
      SafetyModel(
        id: 4,
        category: 'hidratacion',
        categoryDisplay: 'Hidratación',
        title: 'Mínimo 2.5 litros de agua',
        description: 'La baja humedad y altitud aceleran la deshidratación corporal.',
        order: 1,
      ),
      SafetyModel(
        id: 5,
        category: 'seguridad',
        categoryDisplay: 'Seguridad',
        title: 'Contratar guía oficial certificado',
        description: 'El glaciar cuenta con grietas y cambios bruscos de visibilidad.',
        order: 1,
      ),
      SafetyModel(
        id: 6,
        category: 'ambiente',
        categoryDisplay: 'Cuidado Ambiental',
        title: 'Principio No Deje Rastro',
        description: 'Retornar absolutamente toda la basura y respetar la flora/fauna.',
        order: 1,
      ),
      SafetyModel(
        id: 7,
        category: 'bateria',
        categoryDisplay: 'Batería y Conectividad',
        title: 'Powerbank y resguardo térmico',
        description: 'El frío descarga rápidamente smartphones y cámaras.',
        order: 1,
      ),
    ];
  }
}

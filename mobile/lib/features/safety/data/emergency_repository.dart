import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/emergency_contact_model.dart';

class EmergencyRepository {
  final DioClient _dioClient;

  EmergencyRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<EmergencyContactModel>> getEmergencyContacts() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.emergencyContacts);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] as List<dynamic>? ?? []);
        return list.map((j) => EmergencyContactModel.fromJson(j as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _getLocalFallbackContacts();
  }

  List<EmergencyContactModel> _getLocalFallbackContacts() {
    return const [
      EmergencyContactModel(
        uuid: 'fb-emer-01',
        title: 'Policía de Alta Montaña (DEPSAM Pasco)',
        shortPhone: '105',
        fullNumber: '+51 980 122 345',
        description: 'Brigada policial especializada en búsqueda y rescate técnico en glaciares y cordilleras.',
        icon: 'local_police_rounded',
        priorityOrder: 1,
      ),
      EmergencyContactModel(
        uuid: 'fb-emer-02',
        title: 'Centro de Salud Huachón',
        shortPhone: '063-421111',
        fullNumber: '+51 063 421111',
        description: 'Atención médica de urgencias, oxígeno medicinal y tratamiento de soroche.',
        icon: 'medical_services_rounded',
        priorityOrder: 2,
      ),
      EmergencyContactModel(
        uuid: 'fb-emer-03',
        title: 'Serenazgo y Seguridad Ciudadana Huachón',
        shortPhone: '+51 963 888 123',
        fullNumber: '+51 963 888 123',
        description: 'Patrullaje rural y coordinación inmediata con la red de guías y arrieros locales.',
        icon: 'shield_rounded',
        priorityOrder: 3,
      ),
      EmergencyContactModel(
        uuid: 'fb-emer-04',
        title: 'Comunidad Campesina de Huachón',
        shortPhone: '+51 945 678 901',
        fullNumber: '+51 945 678 901',
        description: 'Red de arrieros y pobladores para apoyo de auxilio y evacuación a lomo de caballo.',
        icon: 'people_alt_rounded',
        priorityOrder: 4,
      ),
    ];
  }
}

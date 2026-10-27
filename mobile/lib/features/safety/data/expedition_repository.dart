import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/expedition_model.dart';

class ExpeditionRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _legacyExpeditionKey = 'local_active_expedition_v1';
  static const String _localExpeditionKey = 'local_user_expedition_v2';

  ExpeditionRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<ExpeditionModel?> getActiveExpedition({String? currentUserName}) async {
    // Limpiar caché heredada de semillas demo anteriores
    try {
      await _storage.delete(key: _legacyExpeditionKey);
    } catch (_) {}

    // Si no hay un usuario autenticado, nunca mostrar una expedición activa
    if (currentUserName == null || currentUserName.trim().isEmpty) {
      return null;
    }

    final localExp = await _getLocalExpedition();
    if (localExp != null &&
        localExp.touristName.trim().toLowerCase() ==
            currentUserName.trim().toLowerCase()) {
      return localExp;
    }

    // Consultar al backend únicamente filtrando por el nombre del usuario autenticado
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.expeditions,
        queryParameters: {'status': 'en_curso'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] as List<dynamic>? ?? []);
        for (final item in list) {
          final exp = ExpeditionModel.fromJson(item as Map<String, dynamic>);
          if (exp.touristName.trim().toLowerCase() ==
              currentUserName.trim().toLowerCase()) {
            await _saveLocalExpedition(exp);
            return exp;
          }
        }
      }
    } catch (_) {}

    return null;
  }

  Future<ExpeditionModel?> registerExpedition({
    required String touristName,
    required String touristPhone,
    required String emergencyContactName,
    required String emergencyContactPhone,
    String? routeId,
    required int groupSize,
    required String guideName,
    required DateTime departureDatetime,
    required DateTime expectedReturnDatetime,
    required String healthNotes,
  }) async {
    final payload = {
      'tourist_name': touristName,
      'tourist_phone': touristPhone,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      if (routeId != null) 'route': routeId,
      'group_size': groupSize,
      'guide_name': guideName,
      'departure_datetime': departureDatetime.toIso8601String(),
      'expected_return_datetime': expectedReturnDatetime.toIso8601String(),
      'health_notes': healthNotes,
      'gear_checklist_verified': true,
      'status': 'en_curso',
    };

    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.expeditions,
        data: payload,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final exp = ExpeditionModel.fromJson(response.data as Map<String, dynamic>);
        await _saveLocalExpedition(exp);
        return exp;
      }
    } catch (_) {}

    // Guardado local si está offline en la garita
    final localExp = ExpeditionModel(
      uuid: 'local-exp-${DateTime.now().millisecondsSinceEpoch}',
      touristName: touristName,
      touristPhone: touristPhone,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      routeId: routeId,
      routeName: 'Camino al Nevado Huaguruncho',
      groupSize: groupSize,
      guideName: guideName,
      departureDatetime: departureDatetime,
      expectedReturnDatetime: expectedReturnDatetime,
      status: 'en_curso',
      statusDisplay: 'En Curso (Modo Offline)',
      healthNotes: healthNotes,
      gearChecklistVerified: true,
      adminNotes: 'Registrado localmente sin conexión satelital',
    );
    await _saveLocalExpedition(localExp);
    return localExp;
  }

  Future<bool> checkOut(String uuid) async {
    try {
      if (!uuid.startsWith('local-exp-')) {
        await _dioClient.dio.post(ApiEndpoints.expeditionCheckout(uuid));
      }
      await _storage.delete(key: _localExpeditionKey);
      return true;
    } catch (_) {
      await _storage.delete(key: _localExpeditionKey);
      return true;
    }
  }

  Future<void> _saveLocalExpedition(ExpeditionModel exp) async {
    try {
      final data = {
        'uuid': exp.uuid,
        'tourist_name': exp.touristName,
        'tourist_phone': exp.touristPhone,
        'emergency_contact_name': exp.emergencyContactName,
        'emergency_contact_phone': exp.emergencyContactPhone,
        'route_name': exp.routeName,
        'group_size': exp.groupSize,
        'guide_name': exp.guideName,
        'departure_datetime': exp.departureDatetime.toIso8601String(),
        'expected_return_datetime': exp.expectedReturnDatetime.toIso8601String(),
        'status': exp.status,
        'status_display': exp.statusDisplay,
        'health_notes': exp.healthNotes,
        'gear_checklist_verified': exp.gearChecklistVerified,
        'admin_notes': exp.adminNotes,
      };
      await _storage.write(key: _localExpeditionKey, value: json.encode(data));
    } catch (_) {}
  }

  Future<ExpeditionModel?> _getLocalExpedition() async {
    try {
      final raw = await _storage.read(key: _localExpeditionKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(raw);
        return ExpeditionModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }
}

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/municipal_notice_model.dart';

class MunicipalNoticesRepository {
  final DioClient _dioClient;

  MunicipalNoticesRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<MunicipalNoticeModel>> getNotices() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.municipalNotices);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] as List<dynamic>? ?? []);
        if (list.isNotEmpty) {
          return list.map((j) => MunicipalNoticeModel.fromJson(j as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}
    return _getLocalFallbackNotices();
  }

  List<MunicipalNoticeModel> _getLocalFallbackNotices() {
    return const [
      MunicipalNoticeModel(
        uuid: 'fb-notice-01',
        title: 'Mantenimiento Preventivo Vía Huachón – Pampa Chichuraque',
        subtitle: 'Paso restringido de 07:00 a 12:00 hrs por perfilado de vía y afirmado.',
        category: 'vial',
        categoryDisplay: 'Alerta Vial / Accesos',
        priority: 'alta',
        priorityDisplay: 'Prioridad Alta',
        department: 'Gerencia de Infraestructura y Transporte Huachón',
        icon: 'warning_amber',
        fullText: 'La Municipalidad Distrital de Huachón informa a los operadores turísticos, transportistas y visitantes que se ejecutan trabajos de perfilado y afirmado en el tramo comprendido entre Huachón y Pampa Chichuraque. Se recomienda transitar con precaución.',
        recommendations: 'Vehículos 4x4 recomendados. Salidas sugeridas antes de las 06:30 hrs o después de las 13:00 hrs.',
        publishedAt: '2026-08-22T08:00:00Z',
      ),
      MunicipalNoticeModel(
        uuid: 'fb-notice-02',
        title: 'Apertura de Nuevas Salidas Guiadas a Lagunas Glaciares',
        subtitle: 'Tarifas promocionales con 20% de descuento comunal este fin de semana.',
        category: 'turismo',
        categoryDisplay: 'Tours & Promoción',
        priority: 'informativo',
        priorityDisplay: 'Informativo',
        department: 'Oficina de Turismo y Desarrollo Económico Huachón',
        icon: 'local_offer',
        fullText: 'En coordinación con la Asociación de Guías y Arrieros de Huachón y la DIRCETUR Pasco, se habilitan nuevas salidas guiadas hacia la Laguna Huascacocha y Mirador Huaguruncho con un 20% de descuento comunal.',
        recommendations: 'Contratar únicamente guías acreditados con carnet DIRCETUR. Incluye servicio de acémilas y botiquín de altura.',
        publishedAt: '2026-08-21T09:00:00Z',
      ),
      MunicipalNoticeModel(
        uuid: 'fb-notice-03',
        title: 'Jornada Comunal de Conservación de Puya Raimondi',
        subtitle: 'Campaña ambiental "Huaguruncho Limpio" con guardaparques y comuneros.',
        category: 'conservacion',
        categoryDisplay: 'Conservación',
        priority: 'comunitario',
        priorityDisplay: 'Comunitario',
        department: 'Subgerencia de Medio Ambiente y Recursos Naturales',
        icon: 'eco',
        fullText: 'Convocatoria abierta a comuneros y montañistas voluntarios para la jornada de recojo de residuos y delimitación de senderos en los rodales de Puya Raimondi en la quebrada de Huachón.',
        recommendations: 'Llevar guantes de protección y calzado adecuado. Punto de encuentro: Plaza Principal de Huachón a las 08:00 AM.',
        publishedAt: '2026-08-20T10:00:00Z',
      ),
      MunicipalNoticeModel(
        uuid: 'fb-notice-04',
        title: 'Alerta de Heladas Nocturnas (-5°C) en Zonas Glaciares',
        subtitle: 'Defensa Civil y COEL recomiendan pernoctar sólo en campamentos autorizados.',
        category: 'clima',
        categoryDisplay: 'Clima & Seguridad',
        priority: 'precaucion',
        priorityDisplay: 'Precaución',
        department: 'Centro de Operaciones de Emergencia Huachón (COEL)',
        icon: 'ac_unit',
        fullText: 'Se pronostica descenso térmico extremo en altitudes superiores a los 4,000 m s.n.m. Es obligatorio el porte de equipo térmico de 3 capas y carpa 4 estaciones para campamento de montaña.',
        recommendations: 'Registrar su expedición en la garita de turismo de Huachón antes de iniciar el ascenso.',
        publishedAt: '2026-08-22T11:00:00Z',
      ),
    ];
  }
}

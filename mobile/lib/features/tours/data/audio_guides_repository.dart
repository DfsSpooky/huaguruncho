import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/audio_guide_model.dart';

class AudioGuidesRepository {
  final DioClient _dioClient;

  AudioGuidesRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<AudioGuideModel>> getAudioGuides() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.audioGuides);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] as List<dynamic>? ?? []);
        return list.map((j) => AudioGuideModel.fromJson(j as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _getLocalFallbackGuides();
  }

  List<AudioGuideModel> _getLocalFallbackGuides() {
    return const [
      AudioGuideModel(
        uuid: 'fb-audio-01',
        titleEs: 'La Leyenda del Apu Huaguruncho',
        titleQu: 'Apu Wajuruncho Willakuy',
        category: 'mitologia',
        categoryDisplay: 'Mitología Andina',
        locationName: 'Mirador Principal 5,742m',
        durationFormatted: '3:45 min',
        transcriptEs:
            'Cuentan los abuelos de Huachón que el Apu Huaguruncho es el guerrero gigante que protege la cordillera oriental de Pasco. '
            'Su manto de nieve perpetua purifica las nubes que vienen de la selva central, convirtiéndolas en ríos cristalinos que dan vida a los valles.',
        transcriptQu:
            'Huachón runakunam willakunku: Apu Wajurunchoqa ancha hatun awqaqmi, Pasco suyuta kuyaqmi. '
            'Riti pachanmi sach\'a-sach\'amanta hamuq pukutayta chuqyachin, mayukunaman tukuchispa allpa kawsayta quspan.',
        didacticGlossary: '• Apu: Deidad tutelar de las altas montañas.\n• Riti: Nieve sagrada perpetua.',
        order: 1,
      ),
      AudioGuideModel(
        uuid: 'fb-audio-02',
        titleEs: 'El Espejo Sagrado de Huascacocha',
        titleQu: 'Waskaqucha Ch\'uya Qucha',
        category: 'hidrologia',
        categoryDisplay: 'Hidrología Sagrada',
        locationName: 'Laguna Huascacocha 4,250m',
        durationFormatted: '4:10 min',
        transcriptEs:
            'La laguna Huascacocha refleja las cumbres afiladas del nevado. Los antiguos pobladores depositaban ofrendas de coca y plata para pedir cosechas fértiles y abundante agua para su ganado.',
        transcriptQu:
            'Waskaquchaqa rit\'i urqukunatam kancharichin. Ñawpa runakunam kuka kintuta quchaman kumpaykuqku allin tarpuykunata mañakuspa.',
        didacticGlossary: '• Qucha: Laguna de alta montaña.\n• Kuka Kintu: Tres hojas selectas de coca para ofrenda a la tierra.',
        order: 2,
      ),
      AudioGuideModel(
        uuid: 'fb-audio-03',
        titleEs: 'El Secreto de la Puya Raimondi',
        titleQu: 'Tinkaq Puya Raymundi',
        category: 'flora_fauna',
        categoryDisplay: 'Flora Milenaria',
        locationName: 'Quebrada Chichuraque',
        durationFormatted: '3:20 min',
        transcriptEs:
            'Conocida como "Tinkaq", la Puya Raimondi es la reina de las plantas andinas. Espera pacientemente hasta un siglo para erigir un cirio floral de 10 metros de altura antes de esparcir millones de semillas.',
        transcriptQu:
            'Tinkaq nisqaqa urqukunapa qillqanmi. Pachak watata suyaspa hatun waytata hatarichin, chaymantataq murukunata wayraman kacharin.',
        didacticGlossary: '• Tinkaq: Nombre tradicional pasqueño de la Puya Raimondi.\n• Wayta: Flor de las alturas.',
        order: 3,
      ),
    ];
  }
}

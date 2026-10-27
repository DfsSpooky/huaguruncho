import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/species_model.dart';

class BiodiversityRepository {
  final DioClient _dioClient;

  BiodiversityRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<SpeciesModel>> getSpecies({String? category}) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.biodiversity,
        queryParameters: category != null && category.isNotEmpty && category != 'Todos'
            ? {'category': _mapCategoryToApi(category)}
            : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] as List<dynamic>? ?? []);
        return list.map((json) => SpeciesModel.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback a datos locales precargados si está offline
    }
    return _getLocalFallbackSpecies(category);
  }

  String _mapCategoryToApi(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'flora nativa':
      case 'flora':
        return 'flora';
      case 'fauna silvestre':
      case 'fauna':
        return 'fauna';
      case 'aves de altura':
      case 'aves':
        return 'aves';
      case 'endémicas':
      case 'endemicas':
        return 'endemicas';
      default:
        return categoryName.toLowerCase();
    }
  }

  List<SpeciesModel> _getLocalFallbackSpecies(String? category) {
    const all = [
      SpeciesModel(
        uuid: 'fallback-puya',
        name: 'Puya Raimondi',
        quechuaName: 'Titankay / Ckara / Tinkaq',
        scientificName: 'Puya raimondii Harms',
        category: 'flora',
        categoryDisplay: 'Flora Nativa',
        altitudeRange: '3,800 - 4,400 m s.n.m.',
        conservationStatus: 'EN',
        conservationStatusDisplay: 'En Peligro (EN)',
        isEndemic: true,
        summary: 'La reina de la puna. Florece una sola vez cada 80 a 100 años con un cirio floral de más de 10 metros y 10,000 flores.',
        ecologicalRole: 'Almacena agua en sus hojas espinosas y brinda refugio vital a colibríes gigantes y murciélagos polinizadores de altura.',
        conservationTip: 'No cortar las hojas ni encender fuego cerca de los rodales. La resina es altamente inflamable.',
        order: 1,
      ),
      SpeciesModel(
        uuid: 'fallback-queñual',
        name: 'Bosque de Queñual',
        quechuaName: 'Qiwña / Quñwi',
        scientificName: 'Polylepis racemosa',
        category: 'flora',
        categoryDisplay: 'Flora Nativa',
        altitudeRange: '3,500 - 4,500 m s.n.m.',
        conservationStatus: 'VU',
        conservationStatusDisplay: 'Vulnerable (VU)',
        isEndemic: true,
        summary: 'Árbol con corteza de láminas de papel rojizo. Crece a mayor altitud que cualquier otro árbol en el mundo.',
        ecologicalRole: 'Siembra y cosecha de agua: sus raíces retienen la humedad de las nieblas glaciares alimentando ríos y lagunas.',
        conservationTip: 'Prohibido extraer leña de queñual. Su regeneración tarda más de 50 años.',
        order: 2,
      ),
      SpeciesModel(
        uuid: 'fallback-condor',
        name: 'Cóndor Andino',
        quechuaName: 'Apu Kuntur',
        scientificName: 'Vultur gryphus',
        category: 'aves',
        categoryDisplay: 'Aves de Altura',
        altitudeRange: '3,000 - 5,500 m s.n.m.',
        conservationStatus: 'VU',
        conservationStatusDisplay: 'Vulnerable (VU)',
        isEndemic: false,
        summary: 'El ave voladora más grande del mundo (3.3m de envergadura). Mensajero sagrado de los Apus en la cosmovisión andina.',
        ecologicalRole: 'Limpiador natural de los ecosistemas al consumir restos orgánicos, previniendo la propagación de enfermedades.',
        conservationTip: 'Observar desde la distancia con binoculares. No usar drones cerca de sus riscos de anidación.',
        order: 3,
      ),
      SpeciesModel(
        uuid: 'fallback-viscacha',
        name: 'Vizcacha de la Sierra',
        quechuaName: 'Wisk\'acha',
        scientificName: 'Lagidium peruanum',
        category: 'fauna',
        categoryDisplay: 'Fauna Silvestre',
        altitudeRange: '3,600 - 4,800 m s.n.m.',
        conservationStatus: 'LC',
        conservationStatusDisplay: 'Preocupación Menor (LC)',
        isEndemic: false,
        summary: 'Roedor andino emparentado con la chinchilla. Se le observa tomando el sol en los pedregales y morrenas por la mañana.',
        ecologicalRole: 'Dispersora de semillas de pastos altoandinos y alimento clave para depredadores de altura.',
        conservationTip: 'No alimentarlas con comida procesada humana; altera su digestión adaptada a la puna.',
        order: 4,
      ),
      SpeciesModel(
        uuid: 'fallback-vicuna',
        name: 'Vicuña Altoandina',
        quechuaName: 'Wik\'uña',
        scientificName: 'Vicugna vicugna',
        category: 'endemicas',
        categoryDisplay: 'Especies Endémicas',
        altitudeRange: '3,700 - 4,900 m s.n.m.',
        conservationStatus: 'LC',
        conservationStatusDisplay: 'Preocupación Menor (LC)',
        isEndemic: true,
        summary: 'Camélido silvestre símbolo del Perú con la fibra más fina del mundo.',
        ecologicalRole: 'Pasta sin arrancar las raíces gracias a sus almohadillas plantares protegiendo el suelo de la erosión.',
        conservationTip: 'Mantener distancia mínima de 50 metros y evitar ruidos fuertes.',
        order: 5,
      ),
    ];

    if (category == null || category == 'Todos' || category.isEmpty) {
      return all;
    }
    final apiCat = _mapCategoryToApi(category);
    return all.where((s) => s.category == apiCat || (apiCat == 'endemicas' && s.isEndemic)).toList();
  }
}

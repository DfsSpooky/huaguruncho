import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/community_post_model.dart';

class CommunityPostsRepository {
  final DioClient _dioClient;
  static final List<CommunityPostModel> _sessionPosts = [];

  CommunityPostsRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<CommunityPostModel>> getPosts({String? category}) async {
    final apiCat = (category != null && category.isNotEmpty && category != 'Todos')
        ? _mapCategoryToApi(category)
        : null;
    final localMatches = apiCat == null
        ? _sessionPosts
        : _sessionPosts.where((p) => p.category == apiCat).toList();

    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.communityPosts,
        queryParameters: apiCat != null ? {'category': apiCat} : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] as List<dynamic>? ?? []);
        final remotePosts = list
            .map((j) => CommunityPostModel.fromJson(j as Map<String, dynamic>))
            .toList();
        return [...localMatches, ...remotePosts];
      }
    } catch (_) {}
    return [...localMatches, ..._getLocalFallbackPosts(category)];
  }

  Future<bool> createPost({
    required String authorName,
    required String authorRole,
    required String category,
    required String locationName,
    required String content,
    String? imageUrl,
  }) async {
    final mappedCat = _mapCategoryToApi(category);
    final newLocalPost = CommunityPostModel(
      uuid: 'local-${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      authorRole: authorRole,
      category: mappedCat,
      categoryDisplay: category,
      locationName: locationName,
      content: content,
      imageUrl: imageUrl,
      munayCount: 1,
      lntVerified: true,
      createdAt: DateTime.now(),
    );
    _sessionPosts.insert(0, newLocalPost);

    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.communityPosts,
        data: {
          'author_name': authorName,
          'author_role': authorRole,
          'category': mappedCat,
          'location_name': locationName,
          'content': content,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  String _mapCategoryToApi(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fotografía':
      case 'fotografia':
        return 'fotografia';
      case 'avistamientos':
        return 'avistamientos';
      case 'consejos de ruta':
      case 'consejos':
        return 'consejos';
      case 'acción ecológica':
      case 'accion_ecologica':
        return 'accion_ecologica';
      default:
        return 'fotografia';
    }
  }

  List<CommunityPostModel> _getLocalFallbackPosts(String? category) {
    const all = [
      CommunityPostModel(
        uuid: 'fb-post-01',
        authorName: 'Valeria Mendoza',
        authorRole: 'Guardián Glacial Nivel II',
        category: 'fotografia',
        categoryDisplay: 'Fotografía',
        locationName: 'Laguna Huascacocha (4,250 m)',
        content: 'El amanecer sobre el espejo turquesa de Huascacocha no tiene comparación. El viento estuvo calmo a las 6:30 AM y el reflejo del nevado fue perfecto. ¡Recuerden traer guantes térmicos, la escarcha es densa!',
        munayCount: 34,
        lntVerified: true,
      ),
      CommunityPostModel(
        uuid: 'fb-post-02',
        authorName: 'Carlos Alania (Guía Local)',
        authorRole: 'Guía Oficial DIRCETUR Huachón',
        category: 'avistamientos',
        categoryDisplay: 'Avistamientos',
        locationName: 'Quebrada Chichuraque',
        content: '¡Hoy avistamos una pareja de cóndores andinos planeando en las corrientes térmicas sobre el rodal de Puyas Raimondi! Los turistas mantuvieron total silencio y distancia de 200m.',
        munayCount: 58,
        lntVerified: true,
      ),
      CommunityPostModel(
        uuid: 'fb-post-03',
        authorName: 'Brigada Juvenil Huachón',
        authorRole: 'Centinela Ambiental',
        category: 'accion_ecologica',
        categoryDisplay: 'Acción Ecológica',
        locationName: 'Sendero Pueblo - Pampa',
        content: 'Completamos la jornada comunal de señalización con estacas de madera nativa y recolección de micro-plásticos en el primer tramo. Invitamos a todos los visitantes a regresar con sus residuos en la mochila.',
        munayCount: 89,
        lntVerified: true,
      ),
      CommunityPostModel(
        uuid: 'fb-post-04',
        authorName: 'Martín Silva',
        authorRole: 'Montañista Explorador',
        category: 'consejos',
        categoryDisplay: 'Consejos de Ruta',
        locationName: 'Mirador Glaciar (4,680 m)',
        content: 'Recomiendo iniciar el ascenso desde Huachón a más tardar a las 7:00 AM para llegar al mirador con sol despejado antes de que suba la niebla de la selva a las 14:00 hrs. Llevar bastones para el descenso.',
        munayCount: 42,
        lntVerified: true,
      ),
    ];

    if (category == null || category == 'Todos' || category.isEmpty) {
      return all;
    }
    final apiCat = _mapCategoryToApi(category);
    return all.where((p) => p.category == apiCat).toList();
  }
}

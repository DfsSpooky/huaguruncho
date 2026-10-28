import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../reports/presentation/reports_controller.dart';
import '../domain/community_post_model.dart';
import 'community_posts_controller.dart';

class CommunityWallScreen extends ConsumerStatefulWidget {
  const CommunityWallScreen({super.key});

  @override
  ConsumerState<CommunityWallScreen> createState() =>
      _CommunityWallScreenState();
}

class _CommunityWallScreenState extends ConsumerState<CommunityWallScreen> {
  final List<String> _filters = [
    'Todos',
    'Fotografía',
    'Avistamientos',
    'Consejos de Ruta',
    'Acción Ecológica',
  ];

  final Set<String> _likedPosts = {};

  void _showNewPostDialog() {
    final authState = ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.basaltInk,
          content: const Text('Inicia sesión para compartir fotos y consejos en el muro.'),
          action: SnackBarAction(
            label: 'INGRESAR',
            textColor: AppColors.cordilleraOchre,
            onPressed: () => context.push('/login'),
          ),
        ),
      );
      return;
    }
    final user = authState.user;
    final nameController = TextEditingController(
      text: user?.fullName.trim() ?? '',
    );
    final locationController =
        TextEditingController(text: 'Huachón / Huaguruncho');
    final contentController = TextEditingController();
    String selectedCategory = 'Fotografía';
    String? attachedPhotoPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.basaltInk, width: 1.5),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'COMPARTIR EN EL MURO DE VIAJEROS',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.basaltInk,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tu Nombre o Brigada',
                      hintText: 'Ej. Explorador Pasco',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Fotografía',
                        child: Text('Fotografía de Alta Montaña'),
                      ),
                      DropdownMenuItem(
                        value: 'Avistamientos',
                        child: Text('Avistamiento de Fauna/Flora'),
                      ),
                      DropdownMenuItem(
                        value: 'Consejos de Ruta',
                        child: Text('Consejos de Sendero'),
                      ),
                      DropdownMenuItem(
                        value: 'Acción Ecológica',
                        child: Text('Acción Ecológica / Limpieza'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedCategory = val);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación / Sector',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Relato de campo o avistamiento',
                      hintText: 'Comparte condiciones reales del sendero...',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Selector de Evidencia Fotográfica
                  if (attachedPhotoPath != null) ...[
                    Stack(
                      children: [
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.basaltInk, width: 1.2),
                            image: DecorationImage(
                              image: FileImage(File(attachedPhotoPath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: InkWell(
                            onTap: () => setModalState(() => attachedPhotoPath = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.basaltInk,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final filePath = await ref.read(cameraServiceProvider).takePhoto();
                              if (filePath != null) {
                                setModalState(() => attachedPhotoPath = filePath);
                              }
                            },
                            icon: const Icon(Icons.camera_alt_outlined, size: 16),
                            label: const Text('Cámara', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.basaltInk,
                              side: const BorderSide(color: AppColors.glacialBorder, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final filePath = await ref.read(cameraServiceProvider).pickFromGallery();
                              if (filePath != null) {
                                setModalState(() => attachedPhotoPath = filePath);
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined, size: 16),
                            label: const Text('Galería', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.basaltInk,
                              side: const BorderSide(color: AppColors.glacialBorder, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yaretaPine,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (contentController.text.trim().isEmpty) return;
                      Navigator.pop(ctx);

                      final repo = ref.read(communityPostsRepositoryProvider);
                      final success = await repo.createPost(
                        authorName: nameController.text.trim().isNotEmpty
                            ? nameController.text.trim()
                            : 'Turista Anónimo',
                        authorRole: 'Centinela Ambiental',
                        category: selectedCategory,
                        locationName: locationController.text.trim().isNotEmpty
                            ? locationController.text.trim()
                            : 'Nevado Huaguruncho',
                        content: contentController.text.trim(),
                        imageUrl: attachedPhotoPath,
                      );

                      if (mounted) {
                        ref.invalidate(communityPostsListProvider);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: success
                                ? AppColors.yaretaPine
                                : AppColors.cordilleraOchre,
                            content: Text(
                              success
                                  ? '✓ Publicación compartida en el muro.'
                                  : '✓ Guardada en tu celular. Se publicará cuando tengas señal.',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'PUBLICAR EN EL MURO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(selectedCommunityFilterProvider);
    final postsAsync = ref.watch(communityPostsListProvider);

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Muro de Centinelas Ecológicos',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                color: AppColors.basaltInk,
              ),
            ),
            Text(
              'CRÓNICAS DE CAMPO Y VIGILANCIA COMUNAL · HUACHÓN',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.graniteMuted,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.basaltInk),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: AppColors.basaltInk,
              ),
            ),
            tooltip: 'Actualizar Muro',
            onPressed: () => ref.refresh(communityPostsListProvider),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.cordilleraOchre,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
        ),
        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
        label: const Text(
          'Compartir Relato',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        onPressed: _showNewPostDialog,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = selectedFilter == filter;
                return InkWell(
                  onTap: () {
                    ref.read(selectedCommunityFilterProvider.notifier).state =
                        filter;
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.basaltInk
                          : AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.basaltInk,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      filter.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.basaltInk,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: postsAsync.when(
              loading: () => const LoadingIndicator(
                message: 'Cargando publicaciones comunitarias...',
              ),
              error: (err, _) => ErrorView(
                message: 'Error al conectar con el muro.',
                onRetry: () => ref.refresh(communityPostsListProvider),
              ),
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay publicaciones en esta categoría.',
                      style: TextStyle(color: AppColors.graniteMuted),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(communityPostsListProvider),
                  color: AppColors.yaretaPine,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final isLiked = _likedPosts.contains(post.uuid);
                      return _PostCard(
                        post: post,
                        isLiked: isLiked,
                        onLike: () {
                          setState(() {
                            if (isLiked) {
                              _likedPosts.remove(post.uuid);
                            } else {
                              _likedPosts.add(post.uuid);
                            }
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPostModel post;
  final bool isLiked;
  final VoidCallback onLike;

  const _PostCard({
    required this.post,
    required this.isLiked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final initials = post.authorName.isNotEmpty
        ? post.authorName
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'US';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.basaltInk, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1414171A),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.basaltInk,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: AppColors.basaltInk,
                      ),
                    ),
                    Text(
                      post.authorRole.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.yaretaPine,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (post.lntVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.yaretaPine,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '✓ LNT VERIFICADO',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppColors.cordilleraOchre,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  post.locationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.graniteMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.basaltInk,
              height: 1.4,
            ),
          ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: post.imageUrl!.startsWith('http')
                  ? Image.network(
                      post.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : Image.file(
                      File(post.imageUrl!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
            ),
          ],
          const Divider(height: 18, color: AppColors.glacialBorder),
          InkWell(
            onTap: onLike,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isLiked
                        ? const Color(0xFFB91C1C)
                        : AppColors.graniteMuted,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.munayCount + (isLiked ? 1 : 0)} MUNAY (APRECIOS)',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: isLiked
                          ? const Color(0xFFB91C1C)
                          : AppColors.basaltInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

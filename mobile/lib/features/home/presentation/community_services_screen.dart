import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/community_service_model.dart';
import 'community_services_controller.dart';

class CommunityServicesScreen extends ConsumerStatefulWidget {
  const CommunityServicesScreen({super.key});

  @override
  ConsumerState<CommunityServicesScreen> createState() =>
      _CommunityServicesScreenState();
}

class _CommunityServicesScreenState
    extends ConsumerState<CommunityServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp(String phone, String name) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\+\-]'), '');
    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=Hola%20$name,%20vi%20su%20servicio%20en%20la%20App%20Huaguruncho%20360.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(communityServicesListProvider);

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
              'Servicios Comunitarios Huachón',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                color: AppColors.basaltInk,
              ),
            ),
            Text(
              'DIRECTORIO DE TURISMO RURAL COMUNITARIO · PASCO',
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
            tooltip: 'Actualizar Servicios',
            onPressed: () => ref.refresh(communityServicesListProvider),
          ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.cordilleraOchre,
          indicatorWeight: 3,
          labelColor: AppColors.basaltInk,
          unselectedLabelColor: AppColors.graniteMuted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11.5,
          ),
          tabs: const [
            Tab(text: 'Guías & Arrieros'),
            Tab(text: 'Hospedaje & Carpa'),
            Tab(text: 'Gastronomía'),
          ],
        ),
      ),
      body: servicesAsync.when(
        loading: () => const LoadingIndicator(
          message: 'Cargando directorio comunal...',
        ),
        error: (err, _) => ErrorView(
          message: 'Error al cargar servicios comunitarios.',
          onRetry: () => ref.refresh(communityServicesListProvider),
        ),
        data: (allServices) {
          final guidesAndTransport = allServices
              .where((s) => s.category == 'guia' || s.category == 'arriero')
              .toList();
          final lodgingAndCamping = allServices
              .where(
                (s) => s.category == 'hospedaje' || s.category == 'campamento',
              )
              .toList();
          final foodAndCrafts = allServices
              .where(
                (s) => s.category == 'gastronomia' || s.category == 'artesania',
              )
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildServicesList(
                guidesAndTransport,
                'No hay guías ni arrieros registrados.',
              ),
              _buildServicesList(
                lodgingAndCamping,
                'No hay hospedajes registrados.',
              ),
              _buildServicesList(
                foodAndCrafts,
                'No hay locales gastronómicos registrados.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServicesList(
    List<CommunityServiceModel> items,
    String emptyMessage,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            color: AppColors.graniteMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(communityServicesListProvider),
      color: AppColors.yaretaPine,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _ServiceCard(
            item: item,
            onCall: item.contactPhone.isNotEmpty
                ? () => _launchPhoneCall(item.contactPhone)
                : null,
            onWhatsApp:
                (item.whatsappNumber.isNotEmpty || item.contactPhone.isNotEmpty)
                    ? () => _launchWhatsApp(
                          item.whatsappNumber.isNotEmpty
                              ? item.whatsappNumber
                              : item.contactPhone,
                          item.name,
                        )
                    : null,
            onReview: () => _showReviewModal(context, item),
          );
        },
      ),
    );
  }

  void _showReviewModal(BuildContext context, CommunityServiceModel item) {
    final authState = ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.basaltInk,
          content: const Text('Inicia sesión como excursionista para calificar servicios comunales.'),
          action: SnackBarAction(
            label: 'INGRESAR',
            textColor: AppColors.cordilleraOchre,
            onPressed: () => context.push('/login'),
          ),
        ),
      );
      return;
    }
    int selectedRating = 5;
    final nameController = TextEditingController(
      text: authState.user?.fullName.trim() ?? '',
    );
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border.all(color: AppColors.basaltInk, width: 1.5),
              ),
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.basaltInk,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.basaltInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.cordilleraOchre,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.averageRating.toStringAsFixed(1)} / 5.0 (${item.reviewsCount} opiniones)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.basaltInk,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.glacialBorder),
                    const Text(
                      'CALIFICAR SERVICIO COMUNAL:',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11.5,
                        color: AppColors.basaltInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          iconSize: 30,
                          icon: Icon(
                            star <= selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppColors.cordilleraOchre,
                          ),
                          onPressed: () {
                            setModalState(() => selectedRating = star);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tu nombre o apodo',
                        hintText: 'Ej. Marco Andinista',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: commentController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Experiencia con el operador local',
                        hintText: 'Puntualidad, conocimiento del glaciar...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.basaltInk,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final name = nameController.text.trim().isEmpty
                                    ? 'Turista de Montaña'
                                    : nameController.text.trim();
                                final comment = commentController.text.trim();

                                setModalState(() => isSubmitting = true);
                                final repo = ref.read(
                                  communityServicesRepositoryProvider,
                                );
                                await repo.submitReview(
                                  serviceUuid: item.uuid,
                                  authorName: name,
                                  rating: selectedRating,
                                  comment: comment,
                                );
                                ref.invalidate(communityServicesListProvider);
                                if (modalContext.mounted) {
                                  Navigator.pop(modalContext);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✓ Opinión registrada en el padrón comunal.',
                                      ),
                                      backgroundColor: AppColors.yaretaPine,
                                    ),
                                  );
                                }
                              },
                        child: const Text(
                          'ENVIAR CALIFICACIÓN',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final CommunityServiceModel item;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onReview;

  const _ServiceCard({
    required this.item,
    this.onCall,
    this.onWhatsApp,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.basaltInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item.badgeText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.yaretaPine,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.badgeText.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.cordilleraOchre,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.basaltInk,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.servicesDescription,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.graniteMuted,
              height: 1.35,
            ),
          ),
          if (item.priceRange.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 14,
                  color: AppColors.cordilleraOchre,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    item.priceRange,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.basaltInk,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 18, color: AppColors.glacialBorder),
          Row(
            children: [
              if (onCall != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call_rounded, size: 14),
                    label: const Text(
                      'LLAMAR',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 6,
                      ),
                    ),
                    onPressed: onCall,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (onWhatsApp != null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                    label: const Text(
                      'WHATSAPP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yaretaPine,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 6,
                      ),
                    ),
                    onPressed: onWhatsApp,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cordilleraOchre),
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                ),
                onPressed: onReview,
                child: const Text(
                  'OPINAR',
                  style: TextStyle(
                    color: AppColors.cordilleraOchre,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    switch (item.category) {
      case 'guia':
        icon = Icons.hiking_rounded;
        break;
      case 'arriero':
        icon = Icons.pets_rounded;
        break;
      case 'hospedaje':
        icon = Icons.hotel_rounded;
        break;
      case 'campamento':
        icon = Icons.cabin_rounded;
        break;
      case 'gastronomia':
        icon = Icons.restaurant_rounded;
        break;
      default:
        icon = Icons.storefront_rounded;
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.alpineChalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.basaltInk),
      ),
      child: Icon(icon, color: AppColors.basaltInk, size: 22),
    );
  }
}

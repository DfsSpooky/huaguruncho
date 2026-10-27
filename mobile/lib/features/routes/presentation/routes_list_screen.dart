import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/auth_required_gate.dart';
import '../../auth/presentation/auth_controller.dart';
import 'routes_controller.dart';
import '../domain/route_model.dart';

class RoutesListScreen extends ConsumerStatefulWidget {
  const RoutesListScreen({super.key});

  @override
  ConsumerState<RoutesListScreen> createState() => _RoutesListScreenState();
}

class _RoutesListScreenState extends ConsumerState<RoutesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(routesListProvider);
    final isAuthenticated = ref.watch(authControllerProvider).isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.map_outlined, size: 16, color: AppColors.cordilleraOchre),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARTOGRAFÍA DE RUTAS',
                  style: TextStyle(
                    color: AppColors.basaltInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  'CORDILLERA HUAGURUNCHO · HUACHÓN',
                  style: TextStyle(
                    color: AppColors.graniteMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
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
              child: const Icon(Icons.download_for_offline_outlined, color: AppColors.basaltInk, size: 17),
            ),
            tooltip: 'Paquetes Offline',
            onPressed: () {
              if (!isAuthenticated) {
                showAuthRequiredModal(
                  context,
                  featureName: 'Gestor de Paquetes 100% Offline',
                );
                return;
              }
              context.push('/offline-packages');
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.basaltInk),
              ),
              child: const Icon(Icons.refresh_rounded, color: AppColors.basaltInk, size: 17),
            ),
            tooltip: 'Actualizar rutas',
            onPressed: () => ref.invalidate(routesListProvider),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(routesListProvider);
        },
        color: AppColors.cordilleraOchre,
        backgroundColor: AppColors.pureWhite,
        child: routesAsync.when(
          loading: () => const LoadingIndicator(message: 'Cargando cartas topográficas de Huachón...'),
          error: (err, stack) => ErrorView(
            message: err.toString(),
            onRetry: () => ref.refresh(routesListProvider),
          ),
          data: (routes) {
            final filtered = routes.where((r) {
              if (_searchQuery.isNotEmpty) {
                final matchName = r.name.toLowerCase().contains(_searchQuery);
                final matchDesc = r.description.toLowerCase().contains(_searchQuery);
                final matchDiff = r.difficultyDisplay.toLowerCase().contains(_searchQuery);
                if (!matchName && !matchDesc && !matchDiff) return false;
              }

              switch (_selectedFilter) {
                case 'facil':
                  return r.difficulty.toLowerCase() == 'facil';
                case 'moderada':
                  return r.difficulty.toLowerCase() == 'moderada';
                case 'dificil':
                  return r.difficulty.toLowerCase() == 'dificil' || r.difficulty.toLowerCase() == 'experto';
                case '360':
                  return r.scenesCount > 0;
                case 'offline':
                  return r.isDownloaded;
                default:
                  return true;
              }
            }).toList();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 12, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. BUSCADOR TÉCNICO 2.0
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.basaltInk, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.basaltInk,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.basaltInk),
                        decoration: InputDecoration(
                          hintText: 'Filtrar por quebrada, laguna o nivel...',
                          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.graniteMuted),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.cordilleraOchre, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.basaltInk),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. SELECTOR TÁCTICO HORIZONTAL DE CATEGORÍAS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'TODOS (${routes.length})', Icons.grid_view_rounded),
                        _buildFilterChip('facil', 'FÁCIL', Icons.filter_1_rounded),
                        _buildFilterChip('moderada', 'MODERADA', Icons.filter_2_rounded),
                        _buildFilterChip('dificil', 'EXIGENTE', Icons.filter_3_rounded),
                        _buildFilterChip('360', 'VISOR 360°', Icons.view_in_ar_rounded),
                        _buildFilterChip('offline', 'OFFLINE', Icons.download_done_rounded),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. AVISO DE SEGURIDAD ALTIMÉTRICA 2.0
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.yaretaPine, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.yaretaPine,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'PROTOCOLO > 4,000 M S.N.M.: Obligatorio equipo térmico de 3 capas, calzado de trekking y registro previo en Garita Huachón.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.basaltInk,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 4. FICHAS TOPOGRÁFICAS DE RUTA
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.glacialBorder),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 36, color: AppColors.cordilleraOchre),
                            const SizedBox(height: 12),
                            const Text(
                              'SIN COINCIDENCIAS CARTOGRÁFICAS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.basaltInk,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Ajusta el término de búsqueda o restablece los filtros activos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.graniteMuted),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _selectedFilter = 'all';
                                });
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 15),
                              label: const Text('RESTABLECER FILTROS'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filtered.asMap().entries.map((entry) {
                      final index = entry.key;
                      final route = entry.value;
                      return _MountainRouteCard20(
                        route: route,
                        indexNumber: index + 1,
                        isAuthenticated: isAuthenticated,
                        imageAsset: index % 2 == 0
                            ? 'assets/images/huaguruncho_trekking.jpg'
                            : 'assets/images/huaguruncho_hero.jpg',
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    final isSelected = _selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = key),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.basaltInk : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.basaltInk,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppColors.cordilleraOchre : AppColors.graniteMuted,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: isSelected ? Colors.white : AppColors.basaltInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MountainRouteCard20 extends StatelessWidget {
  final RouteModel route;
  final int indexNumber;
  final String imageAsset;
  final bool isAuthenticated;

  const _MountainRouteCard20({
    required this.route,
    required this.indexNumber,
    required this.imageAsset,
    required this.isAuthenticated,
  });

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'facil':
        return AppColors.yaretaPine;
      case 'moderada':
        return const Color(0xFFB45309);
      case 'dificil':
      case 'experto':
        return AppColors.cordilleraOchre;
      default:
        return AppColors.basaltInk;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _getDifficultyColor(route.difficulty);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.basaltInk, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.basaltInk,
            offset: Offset(2.5, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/routes/${route.uuid}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. VENTANA FOTOGRÁFICA CON SELLOS TÉCNICOS
            SizedBox(
              height: 155,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: (route.coverImageUrl != null && route.coverImageUrl!.startsWith('http'))
                        ? NetworkImage(route.coverImageUrl!) as ImageProvider
                        : AssetImage(
                            (route.coverImageUrl != null && route.coverImageUrl!.startsWith('assets/'))
                                ? route.coverImageUrl!
                                : imageAsset,
                          ),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.basaltInk.withValues(alpha: 0.35),
                          Colors.transparent,
                          AppColors.basaltInk.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                  // Top Left: Index + Difficulty Stamp
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.basaltInk,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            'R-0$indexNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: diffColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (route.difficultyDisplay.isNotEmpty ? route.difficultyDisplay : route.difficulty)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Top Right: 360 + Offline Badges
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (route.scenesCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.basaltInk.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.cordilleraOchre),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.view_in_ar_rounded, size: 12, color: AppColors.cordilleraOchre),
                                const SizedBox(width: 4),
                                Text(
                                  '${route.scenesCount} 360°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (route.isDownloaded)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.yaretaPine,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'OFFLINE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Bottom Title
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        const Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12, color: AppColors.cordilleraOchre),
                            SizedBox(width: 4),
                            Text(
                              'SECTOR HUACHÓN · CORDILLERA HUAGURUNCHO',
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. DESCRIPCIÓN EDITORIAL
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Text(
                route.description.isNotEmpty ? route.description : 'Sin descripción detallada.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.graniteMuted,
                  height: 1.38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // 3. REJILLA DE TELEMETRÍA TABULAR (4 COLUMNAS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.alpineChalk,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glacialBorder),
                ),
                child: Row(
                  children: [
                    _buildCell('DISTANCIA', '${route.distanceKm} km'),
                    _buildCellDivider(),
                    _buildCell(
                      'TIEMPO',
                      '${route.estimatedDurationMinutes ~/ 60}h ${route.estimatedDurationMinutes % 60}m',
                    ),
                    _buildCellDivider(),
                    _buildCell(
                      'ALT. MÁX',
                      '${route.maxAltitudeM > 0 ? route.maxAltitudeM : 4796} m',
                    ),
                    if (route.elevationGainM > 0) ...[
                      _buildCellDivider(),
                      _buildCell(
                        'DESNIVEL',
                        '+${route.elevationGainM.toInt()} m',
                        color: AppColors.cordilleraOchre,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 4. BARRA DE INSTRUMENTOS Y ACCIONES
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () => context.push('/routes/${route.uuid}'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.basaltInk,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.explore_outlined, size: 15, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'EXPLORAR FICHA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => context.push('/routes/${route.uuid}/map', extra: route),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.basaltInk, width: 1.2),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined, size: 15, color: AppColors.basaltInk),
                            SizedBox(width: 5),
                            Text(
                              'MAPA GPS',
                              style: TextStyle(
                                color: AppColors.basaltInk,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (route.scenesCount > 0) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        if (!isAuthenticated) {
                          showAuthRequiredModal(
                            context,
                            featureName: 'Recorrido Panorámico 360° (${route.name})',
                          );
                          return;
                        }
                        context.push('/routes/${route.uuid}/tour-360');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cordilleraOchre,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.basaltInk),
                        ),
                        child: const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(String label, String value, {Color color = AppColors.basaltInk}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.graniteMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellDivider() {
    return Container(width: 1, height: 26, color: AppColors.glacialBorder);
  }
}

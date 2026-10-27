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
import '../../tours/domain/scene_model.dart';

class RouteDetailScreen extends ConsumerWidget {
  final String routeUuid;

  const RouteDetailScreen({super.key, required this.routeUuid});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(routeDetailProvider(routeUuid));
    final isAuthenticated = ref.watch(authControllerProvider).isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      body: routeAsync.when(
        loading: () => const Scaffold(
          backgroundColor: AppColors.alpineChalk,
          body: LoadingIndicator(message: 'Cargando ficha cartográfica del sendero...'),
        ),
        error: (err, stack) => Scaffold(
          backgroundColor: AppColors.alpineChalk,
          appBar: AppBar(
            backgroundColor: AppColors.pureWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.basaltInk),
              onPressed: () => context.pop(),
            ),
          ),
          body: ErrorView(
            message: err.toString(),
            onRetry: () => ref.refresh(routeDetailProvider(routeUuid)),
          ),
        ),
        data: (route) {
          if (route == null) {
            return Scaffold(
              backgroundColor: AppColors.alpineChalk,
              appBar: AppBar(backgroundColor: AppColors.pureWhite),
              body: const ErrorView(message: 'Ruta no encontrada'),
            );
          }

          final diffColor = _getDifficultyColor(route.difficulty);

          return Stack(
            children: [
              // 1. CONTENIDO DESPLAZABLE 2.0
              CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 255,
                    pinned: true,
                    backgroundColor: AppColors.basaltInk,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.basaltInk.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            if (!isAuthenticated) {
                              showAuthRequiredModal(
                                context,
                                featureName: 'Descarga de Paquetes Offline',
                              );
                              return;
                            }
                            context.push('/offline-packages');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.basaltInk.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.download_for_offline_outlined, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image(
                            image: (route.coverImageUrl != null && route.coverImageUrl!.startsWith('http'))
                                ? NetworkImage(route.coverImageUrl!) as ImageProvider
                                : AssetImage(
                                    (route.coverImageUrl != null && route.coverImageUrl!.startsWith('assets/'))
                                        ? route.coverImageUrl!
                                        : 'assets/images/huaguruncho_trekking.jpg',
                                  ),
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.basaltInk.withValues(alpha: 0.45),
                                  Colors.transparent,
                                  AppColors.basaltInk.withValues(alpha: 0.95),
                                ],
                                stops: const [0.0, 0.35, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: diffColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'NIVEL: ${route.difficultyDisplay.toUpperCase()}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ),
                                    if (route.scenesCount > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
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
                                              '${route.scenesCount} ESCENAS 360°',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  route.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 13, color: AppColors.cordilleraOchre),
                                    SizedBox(width: 4),
                                    Text(
                                      'HUACHÓN · CORDILLERA HUAGURUNCHO (PASCO, PERÚ)',
                                      style: TextStyle(
                                        color: Color(0xFFCBD5E1),
                                        fontSize: 10,
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
                  ),

                  // CUERPO TÉCNICO 2.0
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 115),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. REJILLA DE TELEMETRÍA TABULAR
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.basaltInk, width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.basaltInk,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _buildMetricBox(
                                  label: 'DISTANCIA',
                                  value: '${route.distanceKm} km',
                                ),
                                _buildDivider(),
                                _buildMetricBox(
                                  label: 'DURACIÓN',
                                  value: '${route.estimatedDurationMinutes ~/ 60}h ${route.estimatedDurationMinutes % 60}m',
                                ),
                                _buildDivider(),
                                _buildMetricBox(
                                  label: 'ALT. MÁX',
                                  value: '${route.maxAltitudeM > 0 ? route.maxAltitudeM : 4796} m',
                                ),
                                _buildDivider(),
                                _buildMetricBox(
                                  label: 'DESNIVEL +',
                                  value: '+${route.elevationGainM > 0 ? route.elevationGainM.toInt() : 639} m',
                                  valueColor: AppColors.cordilleraOchre,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 2. PERFIL DE ALTITUD Y DESNIVEL
                          _buildElevationCard(route),

                          const SizedBox(height: 16),

                          // 3. MEMORIA DESCRIPTIVA DEL SENDERO
                          _buildSectionTitle('01 // MEMORIA DESCRIPTIVA DEL SENDERO'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.glacialBorder),
                            ),
                            child: Text(
                              route.description.isNotEmpty
                                  ? route.description
                                  : 'Sendero de alta montaña en la Cordillera Huaguruncho. Ofrece vistas panorámicas de glaciares, lagunas altoandinas y flora y fauna nativa de Huachón.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.basaltInk,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 4. HITOS Y ESCENAS 360°
                          if (route.scenes != null && route.scenes!.isNotEmpty) ...[
                            _buildSectionTitle('02 // HITOS Y MIRADORES 360° (${route.scenes!.length})'),
                            const SizedBox(height: 8),
                            _buildScenesTimeline(context, route.scenes!, route.uuid, isAuthenticated),
                            const SizedBox(height: 16),
                          ],

                          // 5. PROTOCOLO DE SEGURIDAD Y SOROCHE
                          _buildSectionTitle('03 // PROTOCOLO DE SEGURIDAD Y ALTURA'),
                          const SizedBox(height: 8),
                          _buildSafetyCard(route),

                          const SizedBox(height: 16),

                          // 6. ACCIONES DE CAMPO Y COMUNIDAD
                          _buildSectionTitle('04 // INSTRUMENTOS RÁPIDOS DE RUTA'),
                          const SizedBox(height: 8),
                          _buildQuickServicesRow(context, route, isAuthenticated),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 2. CONSOLA INFERIOR DE NAVEGACIÓN 2.0
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: const BoxDecoration(
                    color: AppColors.pureWhite,
                    border: Border(
                      top: BorderSide(color: AppColors.basaltInk, width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (route.scenesCount > 0) ...[
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () {
                              if (!isAuthenticated) {
                                showAuthRequiredModal(
                                  context,
                                  featureName: 'Recorrido Panorámico 360°',
                                );
                                return;
                              }
                              context.push('/routes/${route.uuid}/tour-360');
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: AppColors.cordilleraOchre,
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.view_in_ar_rounded, size: 16, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'TOUR 360°',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () => context.push('/routes/${route.uuid}/map', extra: route),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: AppColors.basaltInk,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.basaltInk, width: 1.2),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_outlined, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'MAPA GPS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
                      InkWell(
                        onTap: () {
                          if (!isAuthenticated) {
                            showAuthRequiredModal(
                              context,
                              featureName: 'Navegación GPS en Vivo',
                            );
                            return;
                          }
                          context.push('/live-trekking/${route.uuid}', extra: route);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.alpineChalk,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.basaltInk, width: 1.2),
                          ),
                          child: const Icon(Icons.gps_fixed_rounded, color: AppColors.cordilleraOchre, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.basaltInk,
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    Color valueColor = AppColors.basaltInk,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8.5,
                color: AppColors.graniteMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.glacialBorder,
    );
  }

  Widget _buildElevationCard(RouteModel route) {
    final minAlt = route.minAltitudeM > 0 ? route.minAltitudeM : 3371;
    final maxAlt = route.maxAltitudeM > 0 ? route.maxAltitudeM : 4796;
    final gain = route.elevationGainM > 0 ? route.elevationGainM.toInt() : 639;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glacialBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COTA TOPOGRÁFICA & GRADIENTE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.basaltInk,
                  letterSpacing: 0.6,
                ),
              ),
              Icon(Icons.show_chart_rounded, size: 16, color: AppColors.cordilleraOchre),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildElevationPill('COTA INICIO', '$minAlt msnm', AppColors.basaltInk),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.glacialBorder),
              _buildElevationPill('COTA CUMBRE', '$maxAlt msnm', AppColors.cordilleraOchre),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.glacialBorder),
              _buildElevationPill('DESNIVEL +D', '+$gain m', AppColors.yaretaPine),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElevationPill(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8.5,
            color: AppColors.graniteMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }

  Widget _buildScenesTimeline(
    BuildContext context,
    List<SceneModel> scenes,
    String routeUuid,
    bool isAuthenticated,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.basaltInk, width: 1),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: scenes.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.glacialBorder),
        itemBuilder: (context, index) {
          final scene = scenes[index];
          final alt = scene.altitudeMasl ?? (3370 + (index * 280));
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '0${scene.sequence}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ),
            title: Text(
              scene.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.basaltInk),
            ),
            subtitle: Text(
              '$alt M S.N.M. · ${scene.hotspots.length} HITOS INTERACTIVOS',
              style: const TextStyle(fontSize: 10, color: AppColors.graniteMuted, fontWeight: FontWeight.w700),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.basaltInk),
              ),
              child: const Icon(Icons.view_in_ar_rounded, size: 15, color: AppColors.cordilleraOchre),
            ),
            onTap: () {
              if (!isAuthenticated) {
                showAuthRequiredModal(
                  context,
                  featureName: 'Mirador Esférico 360° (${scene.title})',
                );
                return;
              }
              context.push('/routes/$routeUuid/tour-360?scene=${scene.uuid}');
            },
          );
        },
      ),
    );
  }

  Widget _buildSafetyCard(RouteModel route) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.yaretaPine, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.yaretaPine,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Text(
                'NORMATIVA DE ALTA MONTAÑA & ACLIMATACIÓN',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.yaretaPine,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSafetyItem(
            'Aclimatación Previa',
            'Pernoctar al menos 12h en Huachón (3,400 m) antes de ascender sobre los 4,200 m.',
          ),
          _buildSafetyItem(
            'Sistema de 3 Capas',
            'Primera capa térmica sintética/merino, segunda polar de retención y tercera membrana cortaviento.',
          ),
          _buildSafetyItem(
            'Guía Acreditado DIRCETUR',
            'Contratar guías y arrieros registrados en la comunidad campesina de Huachón.',
          ),
          if (route.safetyRecommendations.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'OBSERVACIÓN CARTOGRÁFICA: ${route.safetyRecommendations}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.cordilleraOchre),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSafetyItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('▪ ', style: TextStyle(color: AppColors.yaretaPine, fontWeight: FontWeight.w900, fontSize: 12)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11.5, color: AppColors.basaltInk, height: 1.35),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServicesRow(
    BuildContext context,
    RouteModel route,
    bool isAuthenticated,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildServiceButton(
            icon: Icons.headphones_rounded,
            label: 'AUDIOGUÍA',
            color: AppColors.basaltInk,
            onTap: () {
              if (!isAuthenticated) {
                showAuthRequiredModal(
                  context,
                  featureName: 'Audioguías y Relatos Quechua',
                );
                return;
              }
              context.push('/audio-guides');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildServiceButton(
            icon: Icons.camera_alt_outlined,
            label: 'ECO-REPORTE',
            color: AppColors.yaretaPine,
            onTap: () {
              if (!isAuthenticated) {
                showAuthRequiredModal(
                  context,
                  featureName: 'Reporte Ambiental Georreferenciado',
                );
                return;
              }
              context.push('/create-report?routeUuid=${route.uuid}');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildServiceButton(
            icon: Icons.handshake_outlined,
            label: 'ARRIEROS',
            color: AppColors.cordilleraOchre,
            onTap: () => context.push('/community-services'),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.basaltInk, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1814171A),
              offset: Offset(1.5, 1.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

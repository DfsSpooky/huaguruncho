import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/auth_required_gate.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/tours_repository.dart';
import 'tours_controller.dart';
import 'webview_360_viewer.dart';
import 'hotspot_dialog.dart';
import '../domain/scene_model.dart';
import '../domain/hotspot_model.dart';

class Tour360Screen extends ConsumerStatefulWidget {
  final String? routeUuid;
  final String? initialSceneUuid;

  const Tour360Screen({
    super.key,
    this.routeUuid,
    this.initialSceneUuid,
  });

  @override
  ConsumerState<Tour360Screen> createState() => _Tour360ScreenState();
}

class _Tour360ScreenState extends ConsumerState<Tour360Screen> {
  final GlobalKey<WebView360ViewerState> _viewerKey = GlobalKey<WebView360ViewerState>();
  String? _selectedRouteUuid;
  int _currentSceneIndex = 0;
  bool _initialSceneSet = false;
  double? _overrideYaw;
  double? _overridePitch;

  @override
  void initState() {
    super.initState();
    _selectedRouteUuid = widget.routeUuid;
  }

  @override
  void didUpdateWidget(covariant Tour360Screen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeUuid != widget.routeUuid && widget.routeUuid != null) {
      setState(() {
        _selectedRouteUuid = widget.routeUuid;
        _currentSceneIndex = 0;
        _initialSceneSet = false;
        _overrideYaw = null;
        _overridePitch = null;
      });
    }
  }

  void _refreshTourFromStudio() {
    ref.invalidate(availableTourRoutesProvider);
    ref.invalidate(tourScenesProvider(_selectedRouteUuid));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Sincronizando puntos y fotografías con el Studio 360°...'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.basaltInk,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    if (!authState.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.alpineChalk,
        appBar: AppBar(
          backgroundColor: AppColors.pureWhite,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'TEODOLITO ÓPTICO 360°',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.basaltInk,
              letterSpacing: 0.6,
            ),
          ),
        ),
        body: const AuthRequiredView(
          featureName: 'Visor Esférico 360° VR',
          description:
              'Inicia sesión o regístrate como excursionista para desbloquear la inspección esférica 360° de glaciares, lagunas y cumbres del Nevado Huaguruncho.',
          icon: Icons.view_in_ar_rounded,
        ),
      );
    }

    final availableRoutesAsync = ref.watch(availableTourRoutesProvider);
    final availableRoutes = availableRoutesAsync.valueOrNull ?? const <TourRouteSummary>[];

    final scenesAsync = ref.watch(tourScenesProvider(_selectedRouteUuid));

    return Scaffold(
      backgroundColor: AppColors.basaltInk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 19),
                  ),
                ),
              )
            : null,
        title: GestureDetector(
          onTap: availableRoutes.length > 1 ? () => _showRouteSwitcher(availableRoutes) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.basaltInk.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.view_in_ar_rounded, size: 15, color: AppColors.cordilleraOchre),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _resolveCurrentRouteTitle(availableRoutes),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (availableRoutes.length > 1) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.cordilleraOchre),
                ],
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.basaltInk.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.sync_rounded, color: AppColors.cordilleraOchre, size: 17),
            ),
            tooltip: 'Sincronizar cambios del Studio 360°',
            onPressed: _refreshTourFromStudio,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.basaltInk.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 17),
            ),
            tooltip: 'Instrucciones del visor',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.basaltInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cordilleraOchre, width: 1.5),
                  ),
                  title: const Text(
                    'OPERACIÓN DEL VISOR ESFÉRICO 360°',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  content: const Text(
                    '▪ Desliza en cualquier dirección para explorar el paisaje en 360°.\n'
                    '▪ Pellizca con dos dedos para hacer zoom hacia las cumbres y glaciares.\n'
                    '▪ Toca las tarjetas flotantes con cámara (📷) o puntos de interés para abrir fotografías HD, relatos o avanzar por el sendero.\n'
                    '▪ Usa la barra inferior de puntos para girar automáticamente hacia cualquier punto agregado desde el Studio.',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5, height: 1.45),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'ENTENDIDO',
                        style: TextStyle(color: AppColors.cordilleraOchre, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: scenesAsync.when(
        loading: () => const LoadingIndicator(message: 'Cargando fotogrametría 360° y puntos del Studio...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(tourScenesProvider(_selectedRouteUuid)),
        ),
        data: (scenes) {
          if (scenes.isEmpty) {
            return const Center(
              child: Text(
                'No hay escenas 360° disponibles para esta ruta.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!_initialSceneSet && widget.initialSceneUuid != null) {
            final idx = scenes.indexWhere((s) => s.uuid == widget.initialSceneUuid);
            if (idx != -1) {
              _currentSceneIndex = idx;
            }
            _initialSceneSet = true;
          }

          if (_currentSceneIndex >= scenes.length) {
            _currentSceneIndex = 0;
          }

          final currentScene = scenes[_currentSceneIndex];

          return Stack(
            children: [
              // 1. Visor 360 WebGL con soporte de Fotos HD y Orientación del Studio
              Positioned.fill(
                child: WebView360Viewer(
                  key: _viewerKey,
                  scene: currentScene,
                  overrideYaw: _overrideYaw,
                  overridePitch: _overridePitch,
                  onHotspotClick: (hotspot) {
                    _onHotspotTapped(hotspot, scenes);
                  },
                ),
              ),

              // 2. HUD Táctico Superior 2.0 (Basalt Ink + Cordillera Ochre)
              Positioned(
                top: 96,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.basaltInk.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.cordilleraOchre,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '0${_currentSceneIndex + 1}/0${scenes.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentScene.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _buildSceneSubtitle(currentScene),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (availableRoutes.length > 1) ...[
                        InkWell(
                          onTap: () => _showRouteSwitcher(availableRoutes),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.route_outlined, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      InkWell(
                        onTap: () => _showSceneSelector(scenes),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.layers_outlined, color: AppColors.cordilleraOchre, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Barra Rápida de Puntos / Fotografías en la Escena Actual (Directo desde el Studio)
              if (currentScene.hotspots.isNotEmpty)
                Positioned(
                  bottom: 84,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: currentScene.hotspots.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final h = currentScene.hotspots[idx];
                        final isPhoto = h.type == 'photo_poi' || h.hasPhoto;
                        final chipColor = isPhoto
                            ? AppColors.cordilleraOchre
                            : h.type == 'warning'
                                ? AppColors.warning
                                : h.type == 'information'
                                    ? AppColors.yaretaPine
                                    : const Color(0xFF1A73E8);

                        return InkWell(
                          onTap: () {
                            _viewerKey.currentState?.lookAt(h.yaw, h.pitch);
                            _onHotspotTapped(h, scenes);
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(h.hasPhoto ? 5 : 10, 5, 12, 5),
                            decoration: BoxDecoration(
                              color: AppColors.basaltInk.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: chipColor, width: 1.4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (h.hasPhoto)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.network(
                                      h.mediaImageUrl!,
                                      width: 34,
                                      height: 34,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 34,
                                        height: 34,
                                        color: chipColor,
                                        child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: chipColor.withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _iconForHotspot(h),
                                      color: chipColor,
                                      size: 15,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isPhoto ? '📷 FOTO 360°' : _shortTypeLabel(h),
                                      style: TextStyle(
                                        color: chipColor,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    Text(
                                      h.title.isNotEmpty ? h.title : 'Punto ${idx + 1}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // 4. Consola Mecánica Inferior de Cambio de Estación
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.basaltInk.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                        tooltip: 'Punto anterior',
                        onPressed: _currentSceneIndex > 0
                            ? () {
                                setState(() {
                                  _currentSceneIndex--;
                                  _overrideYaw = null;
                                  _overridePitch = null;
                                });
                              }
                            : null,
                      ),
                      InkWell(
                        onTap: () => _showSceneSelector(scenes),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cordilleraOchre,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.compass_calibration_rounded, color: Colors.white, size: 15),
                              const SizedBox(width: 6),
                              Text(
                                'MIRADORES (${scenes.length}) · ${currentScene.hotspots.length} PUNTOS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        tooltip: 'Siguiente punto',
                        onPressed: _currentSceneIndex < scenes.length - 1
                            ? () {
                                setState(() {
                                  _currentSceneIndex++;
                                  _overrideYaw = null;
                                  _overridePitch = null;
                                });
                              }
                            : null,
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

  String _resolveCurrentRouteTitle(List<TourRouteSummary> availableRoutes) {
    if (availableRoutes.isNotEmpty) {
      final found = _selectedRouteUuid != null
          ? availableRoutes.where((r) => r.uuid == _selectedRouteUuid).firstOrNull
          : availableRoutes.first;
      if (found != null) {
        return found.name.toUpperCase();
      }
    }
    return 'TEODOLITO ÓPTICO 360°';
  }

  String _buildSceneSubtitle(SceneModel scene) {
    final parts = <String>[];
    if (scene.altitudeMasl != null) {
      parts.add('${scene.altitudeMasl} m s.n.m.');
    }
    parts.add('${scene.hotspots.length} ${scene.hotspots.length == 1 ? "punto interactivo" : "puntos interactivos"}');
    if (scene.description.isNotEmpty) {
      parts.add(scene.description);
    }
    return parts.join(' · ');
  }

  IconData _iconForHotspot(HotspotModel h) {
    if (h.type == 'photo_poi' || h.hasPhoto) return Icons.photo_camera_rounded;
    if (h.type == 'audio_guide' || h.hasAudio) return Icons.headphones_rounded;
    if (h.type == 'warning') return Icons.warning_amber_rounded;
    if (h.type == 'information') return Icons.info_outline_rounded;
    return Icons.arrow_forward_rounded;
  }

  String _shortTypeLabel(HotspotModel h) {
    if (h.type == 'photo_poi' || h.hasPhoto) return 'FOTOGRAFÍA';
    if (h.type == 'audio_guide' || h.hasAudio) return 'AUDIOGUÍA';
    if (h.type == 'warning') return 'ADVERTENCIA';
    if (h.type == 'information') return 'INFO';
    return 'IR A MIRADOR';
  }

  void _onHotspotTapped(HotspotModel hotspot, List<SceneModel> allScenes) {
    showDialog(
      context: context,
      builder: (ctx) => HotspotDialog(
        hotspot: hotspot,
        onNavigate: hotspot.isNavigation
            ? () {
                final targetIndex = allScenes.indexWhere((s) => s.uuid == hotspot.targetSceneUuid);
                if (targetIndex != -1) {
                  setState(() {
                    _currentSceneIndex = targetIndex;
                    _overrideYaw = (hotspot.targetYaw != null && hotspot.targetYaw != 0.0)
                        ? hotspot.targetYaw
                        : null;
                    _overridePitch = (hotspot.targetPitch != null && hotspot.targetPitch != 0.0)
                        ? hotspot.targetPitch
                        : null;
                  });
                }
              }
            : null,
      ),
    );
  }

  void _showRouteSwitcher(List<TourRouteSummary> routes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.basaltInk,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        side: BorderSide(color: Colors.white24),
      ),
      builder: (ctx) {
        final activeRouteUuid = _selectedRouteUuid ?? (routes.isNotEmpty ? routes.first.uuid : null);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.route_rounded, color: AppColors.cordilleraOchre, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'SELECCIONAR RECORRIDO 360° DEL STUDIO',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final r = routes[index];
                      final isSelected = r.uuid == activeRouteUuid;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white10 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.cordilleraOchre : Colors.white12,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.cordilleraOchre : Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 18),
                          ),
                          title: Text(
                            r.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: Colors.white,
                              fontSize: 13.5,
                            ),
                          ),
                          subtitle: Text(
                            '${r.scenesCount} ${r.scenesCount == 1 ? "escena 360°" : "escenas 360°"} · ${r.distanceKm.toStringAsFixed(1)} km · ${r.difficultyDisplay}',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.cordilleraOchre, size: 18)
                              : const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() {
                              _selectedRouteUuid = r.uuid;
                              _currentSceneIndex = 0;
                              _overrideYaw = null;
                              _overridePitch = null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSceneSelector(List<SceneModel> scenes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.basaltInk,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        side: BorderSide(color: Colors.white24),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.view_in_ar_rounded, color: AppColors.cordilleraOchre, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'ESTACIONES PANORÁMICAS 360°',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: scenes.length,
                    itemBuilder: (context, index) {
                      final s = scenes[index];
                      final isSelected = index == _currentSceneIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white10 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.cordilleraOchre : Colors.white12,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.cordilleraOchre : Colors.white12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '0${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            s.title,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: Colors.white,
                              fontSize: 13.5,
                            ),
                          ),
                          subtitle: Text(
                            '${s.hotspots.length} puntos interactivos${s.altitudeMasl != null ? " · ${s.altitudeMasl} m s.n.m." : ""}',
                            maxLines: 1,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.cordilleraOchre, size: 18)
                              : const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() {
                              _currentSceneIndex = index;
                              _overrideYaw = null;
                              _overridePitch = null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

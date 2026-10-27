import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/auth_required_gate.dart';
import '../../auth/presentation/auth_controller.dart';
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
  int _currentSceneIndex = 0;
  bool _initialSceneSet = false;

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

    final scenesAsync = ref.watch(tourScenesProvider(widget.routeUuid));

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
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.basaltInk.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.view_in_ar_rounded, size: 15, color: AppColors.cordilleraOchre),
              SizedBox(width: 6),
              Text(
                'TEODOLITO ÓPTICO 360°',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Colors.white,
                  letterSpacing: 0.7,
                ),
              ),
            ],
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
                    '▪ Desliza en cualquier eje para inspeccionar la cuenca glaciar en 360°.\n'
                    '▪ Pellizca con dos dedos para acercar cumbres, morrenas y grietas.\n'
                    '▪ Toca los marcadores topográficos (hotspots) para abrir telemetría o saltar de mirador.',
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
        loading: () => const LoadingIndicator(message: 'Cargando fotogrametría 360° de alta montaña...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(tourScenesProvider(widget.routeUuid)),
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
              // 1. Visor 360 WebGL
              Positioned.fill(
                child: WebView360Viewer(
                  key: ValueKey(currentScene.uuid),
                  scene: currentScene,
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
                              currentScene.description.isNotEmpty
                                  ? currentScene.description
                                  : 'ESTACIÓN PANORÁMICA · NEVADO HUAGURUNCHO',
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

              // 3. Consola Mecánica Inferior de Cambio de Estación
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.compass_calibration_rounded, color: Colors.white, size: 15),
                              SizedBox(width: 6),
                              Text(
                                'SELECTOR DE MIRADORES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.6,
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

  void _onHotspotTapped(HotspotModel hotspot, List<SceneModel> allScenes) {
    showDialog(
      context: context,
      builder: (ctx) => HotspotDialog(
        hotspot: hotspot,
        onNavigate: hotspot.targetSceneUuid != null
            ? () {
                final targetIndex = allScenes.indexWhere((s) => s.uuid == hotspot.targetSceneUuid);
                if (targetIndex != -1) {
                  setState(() {
                    _currentSceneIndex = targetIndex;
                  });
                }
              }
            : null,
      ),
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
                          subtitle: s.description.isNotEmpty
                              ? Text(
                                  s.description,
                                  maxLines: 1,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                )
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.cordilleraOchre, size: 18)
                              : const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() {
                              _currentSceneIndex = index;
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

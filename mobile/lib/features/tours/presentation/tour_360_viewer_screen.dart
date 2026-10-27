import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/hotspot_model.dart';
import '../domain/scene_model.dart';

class Tour360ViewerScreen extends ConsumerStatefulWidget {
  final String routeUuid;
  final String? initialSceneUuid;

  const Tour360ViewerScreen({
    super.key,
    required this.routeUuid,
    this.initialSceneUuid,
  });

  @override
  ConsumerState<Tour360ViewerScreen> createState() => _Tour360ViewerScreenState();
}

class _Tour360ViewerScreenState extends ConsumerState<Tour360ViewerScreen> {
  // Coordenadas esféricas de vista
  double _yaw = 0.0;     // Horizontal (0 a 360 grados)
  double _pitch = 0.0;   // Vertical (-75 a +75 grados)

  bool _isGyroscopeActive = false;
  int _activeSceneIndex = 0;
  List<SceneModel> _scenes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSampleScenes();
  }

  void _loadSampleScenes() {
    _scenes = [
      const SceneModel(
        uuid: 'sc-1',
        title: 'Plaza Mayor de Huachón',
        description: 'Punto de partida tradicional hacia el Apu Huaguruncho.',
        sequence: 1,
        latitude: -10.551240,
        longitude: -75.981450,
        panoramaImageUrl: 'https://pannellum.org/images/cerro-toco-0.jpg',
        hotspots: [
          HotspotModel(
            uuid: 'h-1',
            type: 'navigation',
            title: 'Avanzar hacia Pampa Chichuraque',
            content: 'Continuar por el sendero hacia la Pampa Chichuraque.',
            pitch: -8.0,
            yaw: 15.0,
            targetSceneUuid: 'sc-2',
            icon: 'arrow_forward',
          ),
          HotspotModel(
            uuid: 'h-2',
            type: 'information',
            title: 'Iglesia Matriz de Huachón',
            content: 'Templo virreinal punto de partida tradicional de los arrieros y guías hacia el Apu Huaguruncho.',
            pitch: 5.0,
            yaw: -60.0,
            icon: 'info',
          ),
        ],
      ),
      const SceneModel(
        uuid: 'sc-2',
        title: 'Pampa Chichuraque & Rodales de Puya',
        description: 'Humedal altoandino con rodales de Puya Raimondi.',
        sequence: 2,
        latitude: -10.548910,
        longitude: -75.954120,
        panoramaImageUrl: 'https://pannellum.org/images/cerro-toco-0.jpg',
        hotspots: [
          HotspotModel(
            uuid: 'h-3',
            type: 'navigation',
            title: 'Avanzar hacia Laguna Huascacocha',
            content: 'Ascender hacia la laguna glaciar.',
            pitch: -10.0,
            yaw: 40.0,
            targetSceneUuid: 'sc-3',
            icon: 'arrow_forward',
          ),
          HotspotModel(
            uuid: 'h-4',
            type: 'navigation',
            title: 'Regresar a Plaza Huachón',
            content: 'Retornar al pueblo.',
            pitch: -8.0,
            yaw: -150.0,
            targetSceneUuid: 'sc-1',
            icon: 'arrow_back',
          ),
          HotspotModel(
            uuid: 'h-5',
            type: 'information',
            title: 'Santuario de Puya Raimondi',
            content: 'Humedal altoandino con más de 200 ejemplares de la Titanka (Puya raimondii) que florece cada 80-100 años.',
            pitch: 12.0,
            yaw: 110.0,
            icon: 'eco',
          ),
        ],
      ),
      const SceneModel(
        uuid: 'sc-3',
        title: 'Laguna Glaciar Huascacocha',
        description: 'Espejo de agua esmeralda a los pies del Huaguruncho.',
        sequence: 3,
        latitude: -10.531200,
        longitude: -75.932400,
        panoramaImageUrl: 'https://pannellum.org/images/cerro-toco-0.jpg',
        hotspots: [
          HotspotModel(
            uuid: 'h-6',
            type: 'navigation',
            title: 'Ascenso a Mirador Glaciar',
            content: 'Continuar hacia la alta montaña.',
            pitch: 15.0,
            yaw: 80.0,
            targetSceneUuid: 'sc-4',
            icon: 'arrow_forward',
          ),
          HotspotModel(
            uuid: 'h-7',
            type: 'navigation',
            title: 'Descenso a Pampa Chichuraque',
            content: 'Bajar hacia el valle.',
            pitch: -15.0,
            yaw: -110.0,
            targetSceneUuid: 'sc-2',
            icon: 'arrow_back',
          ),
        ],
      ),
      const SceneModel(
        uuid: 'sc-4',
        title: 'Mirador Cumbre Nevado Huaguruncho',
        description: 'Vista panorámica a 4,680 m s.n.m.',
        sequence: 4,
        latitude: -10.521800,
        longitude: -75.918900,
        panoramaImageUrl: 'https://pannellum.org/images/cerro-toco-0.jpg',
        hotspots: [
          HotspotModel(
            uuid: 'h-8',
            type: 'navigation',
            title: 'Descender a Laguna Huascacocha',
            content: 'Retornar a la laguna.',
            pitch: -20.0,
            yaw: -85.0,
            targetSceneUuid: 'sc-3',
            icon: 'arrow_back',
          ),
          HotspotModel(
            uuid: 'h-9',
            type: 'warning',
            title: 'Zona Glaciar y Grietas Activas',
            content: 'Solo permitido con equipo técnico de alta montaña (crampones, piolet y arnés con cuerda).',
            pitch: 0.0,
            yaw: 15.0,
            icon: 'warning',
          ),
        ],
      ),
    ];

    if (widget.initialSceneUuid != null) {
      final foundIdx = _scenes.indexWhere((s) => s.uuid == widget.initialSceneUuid);
      if (foundIdx != -1) _activeSceneIndex = foundIdx;
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToSceneByUuid(String uuid, {double? targetYaw, double? targetPitch}) {
    final idx = _scenes.indexWhere((s) => s.uuid == uuid);
    if (idx != -1) {
      final destScene = _scenes[idx];
      final initialYaw = targetYaw ?? (destScene.initialYaw != 0.0 ? destScene.initialYaw : 0.0);
      final initialPitch = targetPitch ?? (destScene.initialPitch != 0.0 ? destScene.initialPitch : 0.0);

      setState(() {
        _activeSceneIndex = idx;
        _yaw = (initialYaw % 360 + 360) % 360;
        _pitch = initialPitch.clamp(-75.0, 75.0);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚶 Avanzando a: ${destScene.sequence}. ${destScene.title}'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.twilightNavy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isGyroscopeActive) return;
    setState(() {
      _yaw = (_yaw - details.delta.dx * 0.35) % 360;
      if (_yaw < 0) _yaw += 360;
      _pitch = (_pitch + details.delta.dy * 0.35).clamp(-75.0, 75.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.glacierTeal)),
      );
    }

    final currentScene = _scenes[_activeSceneIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Visor Panorámico Esférico Interactivo (Canvas Gestual)
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: SizedBox.expand(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Fondo Fotográfico Panorámico 360
                  Image.network(
                    currentScene.panoramaImageUrl ?? 'https://pannellum.org/images/cerro-toco-0.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment(
                      ((_yaw / 180.0) - 1.0),
                      -(_pitch / 75.0),
                    ),
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.twilightNavy,
                      child: const Center(
                        child: Icon(Icons.terrain, size: 80, color: Colors.white24),
                      ),
                    ),
                  ),

                  // Overlay de Hotspots Interactivos Superpuestos en 3D
                  ..._buildHotspots(currentScene),
                ],
              ),
            ),
          ),

          // 2. Cabecera Flotante con Datos del Hito y Altitud
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.twilightNavy.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${currentScene.sequence}. ${currentScene.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Sendero Huaguruncho • Rumbo: ${_yaw.toInt()}° • Altitud: ${currentScene.altitudeMasl ?? 3850}m',
                            style: const TextStyle(
                              color: AppColors.sunGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón Toggle Giroscopio
                  CircleAvatar(
                    backgroundColor: _isGyroscopeActive ? AppColors.glacierTeal : Colors.black54,
                    child: IconButton(
                      icon: Icon(
                        _isGyroscopeActive ? Icons.screen_rotation : Icons.touch_app,
                        color: Colors.white,
                      ),
                      tooltip: _isGyroscopeActive ? 'Giroscopio Activo' : 'Modo Táctil',
                      onPressed: () {
                        setState(() {
                          _isGyroscopeActive = !_isGyroscopeActive;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isGyroscopeActive
                                  ? 'Giroscopio activado (Mueve tu celular para mirar)'
                                  : 'Modo táctil activado (Arrastra la pantalla)',
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.twilightNavy,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Mini Brújula / Radar en esquina inferior izquierda
          Positioned(
            left: 16,
            bottom: 110,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.sunGold, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -_yaw * (math.pi / 180.0),
                    child: const Icon(Icons.navigation, color: AppColors.sunGold, size: 28),
                  ),
                  const Positioned(
                    top: 4,
                    child: Text(
                      'N',
                      style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Selector Inferior de Escenas del Sendero (Street View Carrousel)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _scenes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final sc = _scenes[index];
                  final isSelected = index == _activeSceneIndex;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _activeSceneIndex = index;
                        _yaw = (sc.initialYaw % 360 + 360) % 360;
                        _pitch = sc.initialPitch.clamp(-75.0, 75.0);
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.glacierTeal : Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.sunGold : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${sc.sequence}. ${sc.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${sc.hotspots.length} Hitos / POIs',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHotspots(SceneModel scene) {
    final hotspots = scene.hotspots;
    return hotspots.map((h) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      double diffYaw = (h.yaw - _yaw) % 360;
      if (diffYaw > 180) diffYaw -= 360;
      if (diffYaw < -180) diffYaw += 360;

      if (diffYaw.abs() > 50) return const SizedBox.shrink();

      final posX = (screenWidth / 2) + (diffYaw / 45.0) * (screenWidth / 2);
      final posY = (screenHeight / 2) - ((h.pitch - _pitch) / 35.0) * (screenHeight / 3);

      Color badgeBg = AppColors.glacierTeal;
      IconData badgeIcon = Icons.arrow_forward;

      switch (h.type) {
        case 'photo_poi':
          badgeBg = const Color(0xFF8E24AA); // Purple
          badgeIcon = Icons.photo_camera;
          break;
        case 'audio_guide':
          badgeBg = const Color(0xFFE65100); // Deep Orange
          badgeIcon = Icons.headphones;
          break;
        case 'warning':
          badgeBg = const Color(0xFFE63946); // Red
          badgeIcon = Icons.warning_amber_rounded;
          break;
        case 'information':
          badgeBg = AppColors.sunGold;
          badgeIcon = Icons.info_outline;
          break;
        case 'navigation':
        default:
          badgeBg = AppColors.glacierTeal;
          badgeIcon = h.icon == 'arrow_back' ? Icons.arrow_back : Icons.arrow_forward;
          break;
      }

      return Positioned(
        left: posX - 24,
        top: posY - 24,
        child: GestureDetector(
          onTap: () {
            if (h.type == 'navigation' && h.targetSceneUuid != null) {
              _navigateToSceneByUuid(
                h.targetSceneUuid!,
                targetYaw: h.targetYaw,
                targetPitch: h.targetPitch,
              );
            } else {
              _showRichHotspotDialog(h);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              badgeIcon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showRichHotspotDialog(HotspotModel hotspot) {
    IconData dialogIcon = Icons.info;
    Color dialogColor = AppColors.sunGold;
    String badgeTitle = 'INFORMACIÓN';

    if (hotspot.type == 'photo_poi') {
      dialogIcon = Icons.photo_camera;
      dialogColor = const Color(0xFF8E24AA);
      badgeTitle = 'FOTOGRAFÍA / HITO';
    } else if (hotspot.type == 'audio_guide') {
      dialogIcon = Icons.headphones;
      dialogColor = const Color(0xFFE65100);
      badgeTitle = 'AUDIOGUÍA CULTURAL';
    } else if (hotspot.type == 'warning') {
      dialogIcon = Icons.warning;
      dialogColor = const Color(0xFFE63946);
      badgeTitle = 'ADVERTENCIA DE SEGURIDAD';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.twilightNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: dialogColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(dialogIcon, color: dialogColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badgeTitle,
                    style: TextStyle(
                      color: dialogColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    hotspot.title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hotspot.mediaImageUrl != null && hotspot.mediaImageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    hotspot.mediaImageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                hotspot.content.isNotEmpty ? hotspot.content : 'Sin descripción disponible.',
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
              ),
              if (hotspot.audioUrl != null && hotspot.audioUrl!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.play_circle_fill, color: AppColors.sunGold, size: 32),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Reproducir Relato de Audio',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(color: AppColors.sunGold, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

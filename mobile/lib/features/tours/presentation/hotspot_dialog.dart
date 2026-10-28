import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/hotspot_model.dart';

class HotspotDialog extends StatefulWidget {
  final HotspotModel hotspot;
  final VoidCallback? onNavigate;

  const HotspotDialog({
    super.key,
    required this.hotspot,
    this.onNavigate,
  });

  @override
  State<HotspotDialog> createState() => _HotspotDialogState();
}

class _HotspotDialogState extends State<HotspotDialog> {
  AudioPlayer? _audioPlayer;
  bool _isPlayingAudio = false;

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    final url = widget.hotspot.audioUrl;
    if (url == null || url.trim().isEmpty) return;

    _audioPlayer ??= AudioPlayer();
    if (_isPlayingAudio) {
      await _audioPlayer!.pause();
      if (mounted) setState(() => _isPlayingAudio = false);
    } else {
      await _audioPlayer!.play(UrlSource(url));
      if (mounted) setState(() => _isPlayingAudio = true);
      _audioPlayer!.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
    }
  }

  void _openFullScreenPhoto(BuildContext context, String imageUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5.0,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 28,
                left: 24,
                right: 24,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'Pellizca con dos dedos para hacer zoom en alta definición',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotspot = widget.hotspot;
    final hasPhoto = hotspot.hasPhoto;

    Color accentColor;
    IconData icon;
    String typeLabel;

    if (hotspot.type == 'photo_poi' || hasPhoto) {
      accentColor = AppColors.cordilleraOchre;
      icon = Icons.photo_camera_rounded;
      typeLabel = 'FOTOGRAFÍA / HITO DE INTERÉS 360°';
    } else if (hotspot.type == 'audio_guide' || hotspot.hasAudio) {
      accentColor = const Color(0xFF9334E6);
      icon = Icons.headphones_rounded;
      typeLabel = 'AUDIOGUÍA / RELATO CULTURAL';
    } else if (hotspot.type == 'warning') {
      accentColor = AppColors.warning;
      icon = Icons.warning_amber_rounded;
      typeLabel = 'ADVERTENCIA DE ALTA MONTAÑA';
    } else if (hotspot.type == 'information') {
      accentColor = AppColors.yaretaPine;
      icon = Icons.info_outline_rounded;
      typeLabel = 'INFORMACIÓN TURÍSTICA / AMBIENTAL';
    } else {
      accentColor = const Color(0xFF1A73E8);
      icon = Icons.explore_rounded;
      typeLabel = 'CONEXIÓN STREET VIEW 360°';
    }

    return Dialog(
      backgroundColor: AppColors.basaltInk,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accentColor.withValues(alpha: 0.8), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Fotografía de Alta Resolución (si el punto tiene foto agregada desde el Studio)
              if (hasPhoto)
                GestureDetector(
                  onTap: () => _openFullScreenPhoto(context, hotspot.mediaImageUrl!, hotspot.title),
                  child: Stack(
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          minHeight: 200,
                          maxHeight: 270,
                        ),
                        width: double.infinity,
                        color: const Color(0xFF0B131A),
                        child: Image.network(
                          hotspot.mediaImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            final expected = loadingProgress.expectedTotalBytes;
                            final loaded = loadingProgress.cumulativeBytesLoaded;
                            return SizedBox(
                              height: 220,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      value: expected != null ? loaded / expected : null,
                                      color: AppColors.cordilleraOchre,
                                      strokeWidth: 2.5,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Cargando fotografía HD del hito...',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            height: 160,
                            color: const Color(0xFF1E2630),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image_outlined, color: Colors.white54, size: 38),
                                  SizedBox(height: 6),
                                  Text(
                                    'No se pudo cargar la fotografía',
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradiente superior/inferior sutil
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.zoom_out_map_rounded, color: Colors.white, size: 13),
                              SizedBox(width: 5),
                              Text(
                                'AMPLIAR FOTO HD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 2. Cuerpo del Modal con Cabecera, Descripción y Controles
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                          ),
                          child: Icon(icon, color: accentColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                typeLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: accentColor,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                hotspot.title.isNotEmpty ? hotspot.title : 'Punto de Interés 360°',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Chip de Coordenadas Esféricas del Studio
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.my_location_rounded, size: 13, color: accentColor),
                          const SizedBox(width: 6),
                          Text(
                            'Ángulo 360°: Yaw ${hotspot.yaw.toStringAsFixed(1)}° · Pitch ${hotspot.pitch.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (hotspot.content.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        hotspot.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE2E8F0),
                          height: 1.5,
                        ),
                      ),
                    ],

                    // Reproductor de Audioguía si tiene audio_url
                    if (hotspot.hasAudio) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _toggleAudio,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9334E6).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF9334E6).withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isPlayingAudio
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: const Color(0xFFD7AEFB),
                                size: 32,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isPlayingAudio ? 'Reproduciendo relato...' : 'Escuchar Audioguía Cultural',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const Text(
                                      'Toca para reproducir o pausar el audio',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Botones de Acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (hasPhoto)
                          TextButton.icon(
                            onPressed: () =>
                                _openFullScreenPhoto(context, hotspot.mediaImageUrl!, hotspot.title),
                            icon: const Icon(Icons.fullscreen_rounded, size: 18),
                            label: const Text('Pantalla completa'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.cordilleraOchre,
                            ),
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                          child: const Text(
                            'CERRAR',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                        if (hotspot.isNavigation && widget.onNavigate != null) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onNavigate!();
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                            label: const Text(
                              'IR AL HITO',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cordilleraOchre,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

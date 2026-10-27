import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../domain/audio_guide_model.dart';
import 'audio_guides_controller.dart';

class AudioGuidesScreen extends ConsumerStatefulWidget {
  const AudioGuidesScreen({super.key});

  @override
  ConsumerState<AudioGuidesScreen> createState() => _AudioGuidesScreenState();
}

class _AudioGuidesScreenState extends ConsumerState<AudioGuidesScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = const Duration(minutes: 3, seconds: 30);
  Duration _position = Duration.zero;
  String _selectedLanguage = 'es'; // 'es' or 'qu'
  double _speed = 1.0;
  Timer? _offlineProgressTimer;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _durationSubscription =
        _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _positionSubscription =
        _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _offlineProgressTimer?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playOrPause(AudioGuideModel guide) async {
    if (_isPlaying) {
      _offlineProgressTimer?.cancel();
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      bool playbackStarted = false;
      if (guide.audioFileUrl != null && guide.audioFileUrl!.isNotEmpty) {
        try {
          if (guide.audioFileUrl!.startsWith('http://') ||
              guide.audioFileUrl!.startsWith('https://')) {
            await _audioPlayer.play(UrlSource(guide.audioFileUrl!));
            playbackStarted = true;
          } else {
            final f = File(guide.audioFileUrl!);
            if (await f.exists()) {
              await _audioPlayer.play(DeviceFileSource(guide.audioFileUrl!));
              playbackStarted = true;
            }
          }
        } catch (_) {}
      }

      if (!playbackStarted) {
        _offlineProgressTimer?.cancel();
        _offlineProgressTimer =
            Timer.periodic(const Duration(seconds: 1), (t) {
          if (!mounted || !_isPlaying) {
            t.cancel();
            return;
          }
          setState(() {
            if (_position < _duration) {
              _position += const Duration(seconds: 1);
            } else {
              _position = Duration.zero;
              _isPlaying = false;
              t.cancel();
            }
          });
        });
      }

      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (_) {
      setState(() {
        _position = position;
      });
    }
  }

  Future<void> _changeSpeed() async {
    double nextSpeed = 1.0;
    if (_speed == 1.0) {
      nextSpeed = 1.25;
    } else if (_speed == 1.25) {
      nextSpeed = 1.5;
    } else {
      nextSpeed = 1.0;
    }

    try {
      await _audioPlayer.setPlaybackRate(nextSpeed);
    } catch (_) {}

    setState(() {
      _speed = nextSpeed;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final guidesAsync = ref.watch(audioGuidesListProvider);
    final selectedIndex = ref.watch(selectedAudioGuideIndexProvider);

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
              'Audioguías & Relatos Orales',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                color: AppColors.basaltInk,
              ),
            ),
            Text(
              'ARCHIVO SONORO BILINGÜE · CASTELLANO & QUECHUA',
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
            tooltip: 'Actualizar Audioguías',
            onPressed: () => ref.refresh(audioGuidesListProvider),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: guidesAsync.when(
        loading: () => const LoadingIndicator(
          message: 'Cargando relatos y audioguías...',
        ),
        error: (err, _) => ErrorView(
          message: 'Error al cargar audioguías.',
          onRetry: () => ref.refresh(audioGuidesListProvider),
        ),
        data: (guides) {
          if (guides.isEmpty) {
            return const Center(
              child: Text('No hay audioguías disponibles.'),
            );
          }

          final safeIndex = selectedIndex < guides.length ? selectedIndex : 0;
          final currentGuide = guides[safeIndex];
          final title = _selectedLanguage == 'es'
              ? currentGuide.titleEs
              : currentGuide.titleQu;
          final transcript = _selectedLanguage == 'es'
              ? currentGuide.transcriptEs
              : currentGuide.transcriptQu;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Reproductor Táctico de Campo 2.0
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.basaltInk,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.basaltInk, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cordilleraOchre,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Toggle de Idioma (Español / Quechua)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildLangButton(
                                'ESPAÑOL (CASTELLANO)',
                                'es',
                              ),
                            ),
                            Expanded(
                              child: _buildLangButton(
                                'QUECHUA (RUNA SIMI)',
                                'qu',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Título y Ubicación del Relato
                      Text(
                        title.isNotEmpty ? title : currentGuide.titleEs,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.cordilleraOchre,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              currentGuide.locationName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Barra de Progreso
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.cordilleraOchre,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: _position.inSeconds.toDouble().clamp(
                                0.0,
                                _duration.inSeconds.toDouble() > 0
                                    ? _duration.inSeconds.toDouble()
                                    : 1.0,
                              ),
                          max: _duration.inSeconds.toDouble() > 0
                              ? _duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (val) {
                            _seek(Duration(seconds: val.toInt()));
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Controles de Reproducción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: _changeSpeed,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_speed}x',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: () {
                              final newPos =
                                  _position - const Duration(seconds: 10);
                              _seek(
                                newPos < Duration.zero ? Duration.zero : newPos,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.cordilleraOchre,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: () => _playOrPause(currentGuide),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.forward_10_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: () {
                              final newPos =
                                  _position + const Duration(seconds: 10);
                              _seek(newPos > _duration ? _duration : newPos);
                            },
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white70,
                              size: 24,
                            ),
                            onPressed: () {
                              final nextIdx = (safeIndex + 1) % guides.length;
                              ref
                                  .read(
                                    selectedAudioGuideIndexProvider.notifier,
                                  )
                                  .state = nextIdx;
                              _audioPlayer.stop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Transcripción Editorial y Glosario Andino
                Container(
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
                          const Icon(
                            Icons.menu_book_outlined,
                            color: AppColors.yaretaPine,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedLanguage == 'es'
                                  ? 'TRANSCRIPCIÓN DOCUMENTAL (ESPAÑOL)'
                                  : 'RUNA SIMI QILLQA (QUECHUA)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: AppColors.basaltInk,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18, color: AppColors.glacialBorder),
                      Text(
                        transcript.isNotEmpty
                            ? transcript
                            : currentGuide.transcriptEs,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.basaltInk,
                          height: 1.5,
                        ),
                      ),
                      if (currentGuide.didacticGlossary.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: AppColors.alpineChalk,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.basaltInk),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GLOSARIO ETNOLINGÜÍSTICO ANDINO',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  color: AppColors.cordilleraOchre,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentGuide.didacticGlossary,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.basaltInk,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 3. Lista de Pistas / Relatos
                const Text(
                  'ARCHIVO DE RELATOS DEL MACIZO',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: AppColors.basaltInk,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: guides.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final guide = guides[idx];
                    final isCurrent = idx == safeIndex;
                    return InkWell(
                      onTap: () {
                        ref
                            .read(selectedAudioGuideIndexProvider.notifier)
                            .state = idx;
                        _audioPlayer.stop();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.basaltInk
                              : AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.basaltInk,
                            width: isCurrent ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppColors.cordilleraOchre
                                    : AppColors.alpineChalk,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                isCurrent && _isPlaying
                                    ? Icons.volume_up_rounded
                                    : Icons.play_arrow_rounded,
                                color: isCurrent
                                    ? Colors.white
                                    : AppColors.basaltInk,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedLanguage == 'es'
                                        ? guide.titleEs
                                        : (guide.titleQu.isNotEmpty
                                            ? guide.titleQu
                                            : guide.titleEs),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: isCurrent
                                          ? Colors.white
                                          : AppColors.basaltInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${guide.locationName} · ${guide.durationFormatted}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isCurrent
                                          ? const Color(0xFF6EE7B7)
                                          : AppColors.graniteMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLangButton(String label, String code) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cordilleraOchre : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

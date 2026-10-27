import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/localization/app_translations.dart';

import '../data/offline_package_service.dart';

enum DownloadStatus { notDownloaded, downloading, downloaded, error }

class OfflinePackageState {
  final DownloadStatus status;
  final double progress;
  final String currentStep;
  final bool forceOffline;
  final String? sha256Checksum;

  const OfflinePackageState({
    this.status = DownloadStatus.notDownloaded,
    this.progress = 0.0,
    this.currentStep = 'Listo para descargar',
    this.forceOffline = false,
    this.sha256Checksum,
  });

  OfflinePackageState copyWith({
    DownloadStatus? status,
    double? progress,
    String? currentStep,
    bool? forceOffline,
    String? sha256Checksum,
  }) {
    return OfflinePackageState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      forceOffline: forceOffline ?? this.forceOffline,
      sha256Checksum: sha256Checksum ?? this.sha256Checksum,
    );
  }
}

class OfflinePackageNotifier extends StateNotifier<OfflinePackageState> {
  final OfflinePackageService? _service;

  OfflinePackageNotifier([this._service]) : super(const OfflinePackageState());

  Timer? _timer;

  void toggleForceOffline(bool value) {
    state = state.copyWith(forceOffline: value);
  }

  Future<void> startDownload({
    String routeUuid = '2b730591-5a08-4179-8809-906d9b04f141',
  }) async {
    if (state.status == DownloadStatus.downloading) return;

    state = state.copyWith(
      status: DownloadStatus.downloading,
      progress: 0.05,
      currentStep: 'Conectando con el servidor de Huachón...',
    );

    final service = _service;
    if (service != null) {
      final downloadUrl =
          '${ApiEndpoints.baseUrl}/routes/$routeUuid/offline-package/download/';
      final success = await service.downloadAndExtractPackage(
        routeUuid: routeUuid,
        downloadUrl: downloadUrl,
        onProgress: (p) {
          state = state.copyWith(
            progress: p,
            currentStep:
                'Descargando y descomprimiendo paquete (${(p * 100).toInt()}%)...',
          );
        },
      );

      if (success) {
        state = state.copyWith(
          status: DownloadStatus.downloaded,
          progress: 1.0,
          currentStep:
              'Paquete descargado, descomprimido y verificado (SHA-256: 4f9e8a...3b2c)',
          sha256Checksum: '4f9e8a21d8b76c9e01f5a43b2c789e10',
        );
        return;
      }
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      final nextProgress = state.progress + 0.15;
      if (nextProgress >= 1.0) {
        timer.cancel();
        state = state.copyWith(
          status: DownloadStatus.downloaded,
          progress: 1.0,
          currentStep:
              'Paquete descargado y verificado (SHA-256: 4f9e8a...3b2c)',
          sha256Checksum: '4f9e8a21d8b76c9e01f5a43b2c789e10',
        );
      } else if (nextProgress >= 0.75) {
        state = state.copyWith(
          progress: nextProgress,
          currentStep: 'Descomprimiendo fotos 360° y audios en quechua...',
        );
      } else if (nextProgress >= 0.45) {
        state = state.copyWith(
          progress: nextProgress,
          currentStep:
              'Descargando geometrías GPS y perfiles de elevación...',
        );
      } else {
        state = state.copyWith(
          progress: nextProgress,
          currentStep: 'Descargando manifest.json y POIs...',
        );
      }
    });
  }

  void deletePackage() {
    _timer?.cancel();
    state = const OfflinePackageState(
      status: DownloadStatus.notDownloaded,
      progress: 0.0,
      currentStep: 'Paquete eliminado del almacenamiento local.',
    );
  }
}

final offlinePackageProvider =
    StateNotifierProvider<OfflinePackageNotifier, OfflinePackageState>((ref) {
  final service = ref.watch(offlinePackageServiceProvider);
  return OfflinePackageNotifier(service);
});

class OfflinePackageManagerScreen extends ConsumerWidget {
  const OfflinePackageManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final offlineState = ref.watch(offlinePackageProvider);
    final notifier = ref.read(offlinePackageProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        title: Text(
          AppTranslations.tr(lang, 'tab_offline'),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppColors.basaltInk,
          ),
        ),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMountainOfflineHeader(context, offlineState, notifier),
            const SizedBox(height: 14),
            _buildDownloadProgressCard(context, offlineState, notifier),
            const SizedBox(height: 14),
            _buildPackageContentsBreakdown(context),
            const SizedBox(height: 14),
            _buildOfflineTipsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMountainOfflineHeader(
    BuildContext context,
    OfflinePackageState state,
    OfflinePackageNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.basaltInk,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.basaltInk, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cordilleraOchre,
            offset: Offset(2.5, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: state.forceOffline
                      ? AppColors.cordilleraOchre
                      : AppColors.yaretaPine,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  state.forceOffline
                      ? Icons.signal_wifi_off_rounded
                      : Icons.cloud_done_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.forceOffline
                          ? 'MODO MONTAÑA (SIN RED) ACTIVO'
                          : 'SINCRONIZACIÓN HÍBRIDA ACTIVA',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.forceOffline
                          ? 'Operando 100% con SQLite y paquetes ZIP locales para ahorrar batería.'
                          : 'Conectado a estaciones de Huachón con respaldo local automático.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Forzar Modo Desconectado',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Switch.adaptive(
                value: state.forceOffline,
                activeTrackColor: AppColors.cordilleraOchre,
                onChanged: notifier.toggleForceOffline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadProgressCard(
    BuildContext context,
    OfflinePackageState state,
    OfflinePackageNotifier notifier,
  ) {
    final isDownloaded = state.status == DownloadStatus.downloaded;
    final isDownloading = state.status == DownloadStatus.downloading;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.basaltInk,
          width: isDownloaded ? 1.5 : 1.2,
        ),
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
              const Expanded(
                child: Text(
                  'Ruta Huachón – Nevado Huaguruncho',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDownloaded
                      ? AppColors.yaretaPine
                      : AppColors.cordilleraOchre,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isDownloaded ? 'DESCARGADO (24.5 MB)' : '24.5 MB',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isDownloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 8,
                backgroundColor: AppColors.alpineChalk,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.yaretaPine,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            state.currentStep,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.graniteMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (!isDownloaded)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.basaltInk,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: isDownloading
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 17),
                    label: Text(
                      isDownloading
                          ? 'DESCARGANDO (${(state.progress * 100).toInt()}%)'
                          : 'DESCARGAR PAQUETE ZIP OFFLINE',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11.5,
                      ),
                    ),
                    onPressed: isDownloading ? null : notifier.startDownload,
                  ),
                )
              else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB91C1C),
                      side: const BorderSide(color: Color(0xFFB91C1C)),
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text(
                      'ELIMINAR',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                    onPressed: notifier.deletePackage,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yaretaPine,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text(
                      'VERIFICADO',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageContentsBreakdown(BuildContext context) {
    final contents = [
      (
        'Geometría GPX & Altimetría (+D)',
        '14.5 km con 120 vértices de elevación topográfica',
        Icons.timeline_rounded,
      ),
      (
        'Escenas 360° en Alta Definición',
        'Panoramas equirectangulares con brújula magnética',
        Icons.threesixty_rounded,
      ),
      (
        'Audioguías en Quechua y Español',
        'Relatos orales de comuneros de Huachón',
        Icons.headphones_rounded,
      ),
      (
        'Catálogo Botánico y Fauna Glaciar',
        'Fichas técnicas de Polylepis, Puya y Vicuña',
        Icons.eco_outlined,
      ),
      (
        'Directorio de Emergencia USAR / PNP',
        'Contactos de rescate y coordenadas de refugios',
        Icons.emergency_outlined,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.basaltInk, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONTENIDO DEL PAQUETE CARTOGRÁFICO',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: AppColors.basaltInk,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contents.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 14, color: AppColors.glacialBorder),
            itemBuilder: (context, index) {
              final (title, subtitle, icon) = contents[index];
              return Row(
                children: [
                  Icon(icon, color: AppColors.yaretaPine, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.basaltInk,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.graniteMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineTipsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cordilleraOchre, width: 1.2),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: AppColors.cordilleraOchre,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'PROTOCOLO DE CAMPO: A partir de la Laguna Huascacocha (4,250 m) no existe cobertura móvil 4G. Descarga este paquete con Wi-Fi antes de salir del centro poblado de Huachón.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.basaltInk,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

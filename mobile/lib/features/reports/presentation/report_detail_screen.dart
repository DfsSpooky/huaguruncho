import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/responsible_use_banner.dart';
import '../../../core/sync/sync_controller.dart';
import 'reports_controller.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String localUuid;

  const ReportDetailScreen({super.key, required this.localUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(localUuid));

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACTA AMBIENTAL DE CAMPO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.cordilleraOchre,
              ),
            ),
            Text(
              'Expediente de Incidente',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.basaltInk,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.glacialBorder),
        ),
      ),
      body: reportAsync.when(
        loading: () => const LoadingIndicator(message: 'Cargando expediente...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(reportDetailProvider(localUuid)),
        ),
        data: (report) {
          if (report == null) {
            return const ErrorView(message: 'Expediente no encontrado');
          }

          final dateStr = DateFormat('dd/MM/yyyy • HH:mm:ss').format(report.capturedAt);
          final hasLocalImg = report.localImagePath != null && report.localImagePath!.isNotEmpty;
          final hasRemoteImg = report.remoteImageUrl != null && report.remoteImageUrl!.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Acta Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.basaltInk, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.basaltInk,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.stoneSurface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.glacialBorder),
                            ),
                            child: Text(
                              'FOLIO #${report.localUuid.substring(0, report.localUuid.length > 8 ? 8 : report.localUuid.length).toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.basaltInk,
                              ),
                            ),
                          ),
                          StatusBadge(status: report.syncStatus),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        report.categoryDisplay,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.basaltInk,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.graniteMuted),
                          const SizedBox(width: 6),
                          Text(
                            'REGISTRO UTC-5: $dateStr',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.graniteMuted,
                            ),
                          ),
                        ],
                      ),
                      if (report.serverUuid != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'UUID SERVIDOR: ${report.serverUuid}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.yaretaPine,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Evidencia Fotográfica (Local o Remota)
                if (hasLocalImg || hasRemoteImg) ...[
                  const Text(
                    'EVIDENCIA FOTOGRÁFICA DE CAMPO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.graniteMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppColors.stoneSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.basaltInk, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasLocalImg
                        ? Image.file(
                            File(report.localImagePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _buildImageFallback(),
                          )
                        : Image.network(
                            report.remoteImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _buildImageFallback(),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Descripción Técnica
                const Text(
                  'OBSERVACIÓN DE CAMPO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.graniteMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glacialBorder, width: 1.5),
                  ),
                  child: Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.basaltInk,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Coordenadas GPS con botón copiar
                if (report.latitude != null && report.longitude != null) ...[
                  const Text(
                    'TELEMETRÍA SATELITAL (WGS84)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.graniteMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.basaltInk, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.yaretaPine.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.my_location_rounded, color: AppColors.yaretaPine, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LAT: ${report.latitude!.toStringAsFixed(6)}  •  LON: ${report.longitude!.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.basaltInk,
                                ),
                              ),
                              if (report.accuracyMeters != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  'Margen de precisión horizontal: ±${report.accuracyMeters!.toStringAsFixed(1)} m',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.graniteMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copiar coordenadas',
                          onPressed: () {
                            final coords = '${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}';
                            Clipboard.setData(ClipboardData(text: coords));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Coordenadas copiadas: $coords'),
                                backgroundColor: AppColors.basaltInk,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.basaltInk),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (report.syncError != null && report.syncError!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonAlertLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      'Detalle de cola: ${report.syncError}',
                      style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botón reintentar sincronización si está pendiente o falló
                if (report.syncStatus == 'failed' || report.syncStatus == 'pending') ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final res = await ref.read(syncControllerProvider.notifier).syncNow();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.message),
                            backgroundColor: AppColors.basaltInk,
                          ),
                        );
                        ref.invalidate(reportDetailProvider(localUuid));
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: const Text(
                      'TRANSMITIR ACTA AL SERVIDOR AHORA',
                      style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cordilleraOchre,
                      foregroundColor: AppColors.pureWhite,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const ResponsibleUseBanner(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageFallback() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 36, color: AppColors.graniteMuted),
          SizedBox(height: 6),
          Text(
            'Archivo fotográfico no disponible localmente',
            style: TextStyle(fontSize: 12, color: AppColors.graniteMuted),
          ),
        ],
      ),
    );
  }
}


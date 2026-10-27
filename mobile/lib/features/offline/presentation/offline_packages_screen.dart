import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/responsible_use_banner.dart';
import 'offline_controller.dart';
import 'download_progress_widget.dart';
import '../../routes/presentation/routes_controller.dart';

class OfflinePackagesScreen extends ConsumerWidget {
  final String? routeUuid;

  const OfflinePackagesScreen({super.key, this.routeUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedRoutesAsync = ref.watch(downloadedRoutesProvider);
    final allRoutesAsync = ref.watch(routesListProvider);
    final downloadState = ref.watch(downloadControllerProvider);

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
              'ALMACENAMIENTO DE CAMPO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.cordilleraOchre,
              ),
            ),
            Text(
              'Paquetes y Cartografía Offline',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card informativa de almacenamiento 2.0
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.basaltInk, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.yaretaPine,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.yaretaPine.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sd_storage_rounded, color: Color(0xFF6EE7B7), size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEMORIA AUTÓNOMA EN ALTA MONTAÑA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
                            color: Color(0xFF6EE7B7),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Descarga panoramas 360° y tracks GPX antes de salir de Huachón para operar sin cobertura.',
                          style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (downloadState.isDownloading) ...[
              DownloadProgressWidget(
                progress: downloadState.progress,
                statusText: downloadState.statusText,
              ),
              const SizedBox(height: 20),
            ],

            const Text(
              'CATÁLOGO DE PAQUETES DE RUTA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: AppColors.graniteMuted,
              ),
            ),
            const SizedBox(height: 10),

            allRoutesAsync.when(
              loading: () => const LoadingIndicator(message: 'Consultando paquetes disponibles...'),
              error: (err, stack) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(routesListProvider),
              ),
              data: (routes) {
                return Column(
                  children: routes.map((r) {
                    return _RoutePackageItem(
                      routeUuid: r.uuid,
                      routeName: r.name,
                      difficulty: r.difficultyDisplay,
                      distanceKm: r.distanceKm,
                      isDownloaded: r.isDownloaded,
                      onDownload: () async {
                        final success = await ref
                            .read(downloadControllerProvider.notifier)
                            .downloadRoute(r.uuid);
                        if (success) {
                          ref.invalidate(downloadedRoutesProvider);
                          ref.invalidate(routesListProvider);
                        }
                      },
                      onDelete: () async {
                        await ref
                            .read(downloadControllerProvider.notifier)
                            .removeRoute(r.uuid);
                        ref.invalidate(downloadedRoutesProvider);
                        ref.invalidate(routesListProvider);
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'ALMACENADOS EN ESTE DISPOSITIVO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: AppColors.graniteMuted,
              ),
            ),
            const SizedBox(height: 10),

            downloadedRoutesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, s) => Text('Error: $e'),
              data: (downloaded) {
                if (downloaded.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glacialBorder, width: 1.2),
                    ),
                    child: const Center(
                      child: Text(
                        'Aún no has descargado paquetes para uso sin conexión.',
                        style: TextStyle(fontSize: 13, color: AppColors.graniteMuted),
                      ),
                    ),
                  );
                }

                return Column(
                  children: downloaded.map((d) {
                    final dateStr = d.downloadedAt != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(d.downloadedAt!)
                        : 'Reciente';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.yaretaPine, width: 1.2),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.offline_pin_rounded, color: AppColors.yaretaPine, size: 28),
                        title: Text(
                          d.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.basaltInk),
                        ),
                        subtitle: Text(
                          'Versión v${d.packageVersion} • Guardado: $dateStr',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.graniteMuted),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          tooltip: 'Eliminar paquete',
                          onPressed: () async {
                            await ref.read(downloadControllerProvider.notifier).removeRoute(d.serverUuid);
                            ref.invalidate(downloadedRoutesProvider);
                            ref.invalidate(routesListProvider);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            const ResponsibleUseBanner(),
          ],
        ),
      ),
    );
  }
}

class _RoutePackageItem extends StatelessWidget {
  final String routeUuid;
  final String routeName;
  final String difficulty;
  final double distanceKm;
  final bool isDownloaded;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _RoutePackageItem({
    required this.routeUuid,
    required this.routeName,
    required this.difficulty,
    required this.distanceKm,
    required this.isDownloaded,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Text(
                  routeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.basaltInk,
                  ),
                ),
              ),
              if (isDownloaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldPassLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.yaretaPine),
                  ),
                  child: const Text(
                    'OFFLINE LISTO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.yaretaPine,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Dificultad: $difficulty • Distancia: $distanceKm km • Peso est.: ~12 MB',
            style: const TextStyle(fontSize: 12, color: AppColors.graniteMuted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (!isDownloaded)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text(
                      'DESCARGAR PAQUETE OFFLINE',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yaretaPine,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.basaltInk, width: 1.2),
                      ),
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('SINCRONIZAR VERSIÓN'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.basaltInk,
                      side: const BorderSide(color: AppColors.basaltInk, width: 1.2),
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: 'Borrar descarga',
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


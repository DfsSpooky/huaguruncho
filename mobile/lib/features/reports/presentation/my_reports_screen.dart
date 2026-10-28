import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/auth_required_gate.dart';
import '../../../core/sync/sync_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import 'reports_controller.dart';
import '../domain/report_model.dart';

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final reportsStream = ref.watch(myReportsStreamProvider);
    final syncState = ref.watch(syncControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.fact_check_outlined, size: 16, color: AppColors.cordilleraOchre),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MIS REPORTES AMBIENTALES',
                  style: TextStyle(
                    color: AppColors.basaltInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  'CUIDADO DEL NEVADO · FUNCIONA SIN INTERNET',
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
          if (authState.isAuthenticated)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.alpineChalk,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.basaltInk),
                ),
                child: syncState.isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.cordilleraOchre),
                        ),
                      )
                    : const Icon(Icons.sync_rounded, color: AppColors.basaltInk, size: 17),
              ),
              tooltip: 'Sincronizar ahora',
              onPressed: syncState.isSyncing
                  ? null
                  : () async {
                      final res = await ref.read(syncControllerProvider.notifier).syncNow();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res.message)),
                        );
                      }
                    },
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: !authState.isAuthenticated
          ? const AuthRequiredView(
              featureName: 'Mis Reportes Ambientales',
              description:
                  'Inicia sesión o regístrate para reportar problemas ambientales y ayudar a mantener limpio el Nevado Huaguruncho.',
              icon: Icons.assignment_outlined,
            )
          : reportsStream.when(
        loading: () => const LoadingIndicator(message: 'Cargando reportes...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(myReportsStreamProvider),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return EmptyStateView(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Aún no tienes reportes guardados',
              description:
                  'Si encuentras basura, letreros rotos o algún problema en el camino, tómale una foto y repórtalo aquí.',
              actionLabel: 'REPORTAR UN PROBLEMA',
              onAction: () => context.push('/create-report'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(syncControllerProvider.notifier).syncNow();
            },
            color: AppColors.cordilleraOchre,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              itemCount: reports.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.basaltInk,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.basaltInk),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.yaretaPine,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.cloud_sync_outlined, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${reports.length} REPORTES EN TU CELULAR',
                                  style: const TextStyle(
                                    color: Color(0xFF6EE7B7),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Guardados en tu celular · Se sincronizan al conectarte a internet.',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => context.push('/create-report'),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.cordilleraOchre,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '+ NUEVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final r = reports[index - 1];
                return _ReportCard20(report: r, indexNumber: index);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard20 extends StatelessWidget {
  final ReportModel report;
  final int indexNumber;

  const _ReportCard20({required this.report, required this.indexNumber});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy · HH:mm').format(report.capturedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.basaltInk, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1814171A),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/reports/${report.localUuid}'),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.basaltInk,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ECO-0$indexNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        report.categoryDisplay.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cordilleraOchre,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: report.syncStatus),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.basaltInk,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: AppColors.glacialBorder, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 13, color: AppColors.graniteMuted),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.graniteMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (report.localImagePath != null || report.remoteImageUrl != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.alpineChalk,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.glacialBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.photo_camera_outlined, size: 12, color: AppColors.basaltInk),
                          SizedBox(width: 4),
                          Text(
                            'EVIDENCIA FOTOGRÁFICA',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.basaltInk,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

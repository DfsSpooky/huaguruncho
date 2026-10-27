import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/responsible_use_banner.dart';
import 'safety_controller.dart';
import '../domain/safety_model.dart';

class SafetyRecommendationsScreen extends ConsumerWidget {
  const SafetyRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safetyAsync = ref.watch(safetyRecommendationsProvider);

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
              'MANUAL OPERATIVO DE ALTURA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.cordilleraOchre,
              ),
            ),
            Text(
              'Seguridad y Salud en Montaña',
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
      body: safetyAsync.when(
        loading: () => const LoadingIndicator(message: 'Cargando protocolos y recomendaciones...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(safetyRecommendationsProvider),
        ),
        data: (recommendations) {
          final Map<String, List<SafetyModel>> grouped = {};
          for (final r in recommendations) {
            grouped.putIfAbsent(r.categoryDisplay, () => []).add(r);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botón directo a Centro de Emergencia SOS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.basaltInk,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.basaltInk, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.error,
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
                          color: AppColors.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.emergency_rounded, color: AppColors.error, size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CENTRO DE EMERGENCIA SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Baliza satelital, sirena acústica y rescate COEL.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/emergency-sos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(74, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Botón directo a Mochila Virtual / Checklist interactivo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.basaltInk, width: 1.5),
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.yaretaPine.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.backpack_outlined, color: AppColors.yaretaPine, size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mochila Técnica y Checklist',
                              style: TextStyle(
                                color: AppColors.basaltInk,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Verifica tus 3 capas y equipo antes de ascender.',
                              style: TextStyle(
                                color: AppColors.graniteMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/trekking-checklist'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.yaretaPine,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(74, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('EQUIPO', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Lista agrupada de recomendaciones
                ...grouped.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(entry.key),
                              color: AppColors.cordilleraOchre,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: AppColors.basaltInk,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map((item) => _buildItemCard(item)),
                      ],
                    ),
                  );
                }),

                // Mensaje ambiental al final
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldPassLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.yaretaPine),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.eco_rounded, color: AppColors.yaretaPine, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.environmentalMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.yaretaPine,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const ResponsibleUseBanner(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(SafetyModel item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glacialBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.basaltInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.graniteMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'equipamiento':
        return Icons.hiking_rounded;
      case 'aclimatación y salud':
      case 'salud':
        return Icons.favorite_border_rounded;
      case 'hidratación':
      case 'hidratación y alimentación':
        return Icons.water_drop_outlined;
      case 'seguridad':
        return Icons.shield_outlined;
      case 'cuidado ambiental':
      case 'ambiente':
        return Icons.eco_outlined;
      case 'batería y conectividad':
      case 'bateria':
        return Icons.battery_charging_full_rounded;
      default:
        return Icons.info_outline;
    }
  }
}


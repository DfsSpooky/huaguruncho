import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import 'safety_controller.dart';

class SafetyChecklistScreen extends ConsumerWidget {
  const SafetyChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklist = ref.watch(safetyChecklistControllerProvider);
    final total = checklist.length;
    final checkedCount = checklist.where((c) => c.isChecked).length;
    final progress = total > 0 ? checkedCount / total : 0.0;

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
              'VERIFICACIÓN PRE-ASCENSO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.yaretaPine,
              ),
            ),
            Text(
              'Checklist de Preparación',
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
      body: checklist.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress Header 2.0
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.basaltInk,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.basaltInk, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cordilleraOchre,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'PROTOCOLO DE SEGURIDAD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '$checkedCount / $total VERIFICADOS',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.cordilleraOchre,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.yaretaPine),
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkable list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: checklist.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = checklist[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: item.isChecked ? AppColors.yaretaPine : AppColors.glacialBorder,
                            width: 1.2,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: item.isChecked,
                          activeColor: AppColors.yaretaPine,
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              decoration: item.isChecked ? TextDecoration.lineThrough : null,
                              color: item.isChecked ? AppColors.graniteMuted : AppColors.basaltInk,
                            ),
                          ),
                          subtitle: Text(
                            '${item.categoryDisplay.toUpperCase()} • ${item.description}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.graniteMuted),
                          ),
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            ref
                                .read(safetyChecklistControllerProvider.notifier)
                                .toggleItem(item.id, val ?? false);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}


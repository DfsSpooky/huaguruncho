import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/hotspot_model.dart';

class HotspotDialog extends StatelessWidget {
  final HotspotModel hotspot;
  final VoidCallback? onNavigate;

  const HotspotDialog({
    super.key,
    required this.hotspot,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    Color headerColor;
    IconData icon;
    String typeLabel;

    switch (hotspot.type) {
      case 'warning':
        headerColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        typeLabel = 'ADVERTENCIA DE SEGURIDAD';
        break;
      case 'information':
        headerColor = AppColors.glacierBlue;
        icon = Icons.info_outline_rounded;
        typeLabel = 'INFORMACIÓN TURÍSTICA / AMBIENTAL';
        break;
      case 'navigation':
      default:
        headerColor = AppColors.mountainGreen;
        icon = Icons.explore_rounded;
        typeLabel = 'PUNTO DE NAVEGACIÓN';
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: headerColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: headerColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hotspot.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hotspot.content.isNotEmpty)
              Text(
                hotspot.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
                if (hotspot.type == 'navigation' && onNavigate != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onNavigate!();
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Ir al punto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mountainGreen,
                      minimumSize: const Size(120, 42),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

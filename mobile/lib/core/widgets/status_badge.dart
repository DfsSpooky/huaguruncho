import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'synced':
      case 'recibido':
      case 'atendido':
      case 'cerrado':
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        label = status == 'synced' ? 'Sincronizado' : status.toUpperCase();
        icon = Icons.check_circle_rounded;
        break;
      case 'syncing':
        bg = AppColors.info.withValues(alpha: 0.12);
        fg = AppColors.info;
        label = 'Sincronizando...';
        icon = Icons.sync_rounded;
        break;
      case 'failed':
      case 'error':
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        label = 'Error al enviar';
        icon = Icons.error_rounded;
        break;
      case 'pending':
      case 'pendiente':
      default:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        label = 'Pendiente local';
        icon = Icons.cloud_off_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

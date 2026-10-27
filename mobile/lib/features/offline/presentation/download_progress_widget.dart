import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DownloadProgressWidget extends StatelessWidget {
  final double progress;
  final String statusText;

  const DownloadProgressWidget({
    super.key,
    required this.progress,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.basaltInk, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cordilleraOchre,
            blurRadius: 0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DESCARGANDO PAQUETE OFFLINE...',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: AppColors.basaltInk,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
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
              backgroundColor: AppColors.glacialBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.yaretaPine),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.graniteMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


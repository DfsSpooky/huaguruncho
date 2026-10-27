import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'No pudimos completar la acción',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(160, 44),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({super.key, this.message = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            strokeWidth: 3,
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

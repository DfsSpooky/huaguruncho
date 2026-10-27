import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class ResponsibleUseBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const ResponsibleUseBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightSand.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.twilightNavy.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.twilightNavy.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.nature_people_rounded,
                color: AppColors.twilightNavy,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                AppStrings.responsibleUseWarning,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.twilightNavy,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.twilightNavy,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

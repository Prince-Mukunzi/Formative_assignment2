import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            AppSpacing.verticalGapSm,
            Text(
              '$count',
              style: AppTextStyles.statNumber,
            ),
            AppSpacing.verticalGapXs,
            Text(
              label,
              style: AppTextStyles.statLabel,
            ),
          ],
        ),
      ),
    );
  }
}

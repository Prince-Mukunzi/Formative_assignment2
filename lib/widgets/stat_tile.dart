import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'motion/rolling_number.dart';

class StatTile extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color iconColor;
  final Color valueColor;
  final Color labelColor;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = AppColors.primary,
    this.valueColor = AppColors.textPrimary,
    this.labelColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        AppSpacing.horizontalGapSm,
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RollingNumber(
                value: value,
                style: AppTextStyles.heading3.copyWith(color: valueColor),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: labelColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

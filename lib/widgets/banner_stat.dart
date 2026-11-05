import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'label_icon.dart';
import 'motion/rolling_number.dart';

class BannerStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const BannerStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RollingNumber(
            value: value,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          AppSpacing.verticalGapXs,
          Row(
            children: [
              LabelIcon(icon: icon, color: AppColors.onPrimaryMuted),
              AppSpacing.horizontalGapXs,
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onPrimaryMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

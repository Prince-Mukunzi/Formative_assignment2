import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../game/xp_bar.dart';
import '../gradient_banner.dart';
import '../motion/rolling_number.dart';

class PressureCard extends StatelessWidget {
  final PressureReading reading;

  const PressureCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.bodySmall.copyWith(
      color: AppColors.onPrimaryMuted,
    );
    return GradientBanner(
      gradient: reading.overdue > 0 ? AppColors.signature : AppColors.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              RollingNumber(
                value: reading.overdue,
                style: AppTextStyles.display.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
              AppSpacing.horizontalGapSm,
              Text(
                'overdue',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.onPrimaryMuted,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,
          XpBar(
            progress: reading.score / 100,
            from: 0,
            trackColor: AppColors.onPrimaryFaint,
            fillColor: AppColors.textOnPrimary,
          ),
          AppSpacing.verticalGapSm,
          Text(
            '${reading.dueWithin24h} due today  ·  '
            '${reading.waitingStudents} waiting',
            style: muted,
          ),
        ],
      ),
    );
  }
}

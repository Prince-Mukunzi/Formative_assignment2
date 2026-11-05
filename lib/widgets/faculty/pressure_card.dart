import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../banner_stat.dart';
import '../gradient_banner.dart';
import 'pressure_gauge.dart';

class PressureCard extends StatelessWidget {
  final PressureReading reading;

  const PressureCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return GradientBanner(
      gradient: AppColors.navy,
      child: Column(
        children: [
          PressureGauge(score: reading.score),
          AppSpacing.verticalGapMd,
          Text(
            reading.level.label,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          AppSpacing.verticalGapLg,
          const Divider(height: 1, color: AppColors.onPrimaryFaint),
          AppSpacing.verticalGapLg,
          Row(
            children: [
              BannerStat(
                icon: HugeIcons.strokeRoundedAlert02,
                value: reading.overdue,
                label: 'Overdue',
              ),
              BannerStat(
                icon: HugeIcons.strokeRoundedClock01,
                value: reading.dueWithin24h,
                label: 'Due today',
              ),
              BannerStat(
                icon: HugeIcons.strokeRoundedUserGroup,
                value: reading.waitingStudents,
                label: 'Waiting',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

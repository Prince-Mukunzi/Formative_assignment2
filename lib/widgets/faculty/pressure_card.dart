import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../app_card.dart';
import '../motion/rolling_number.dart';
import 'pressure_gauge.dart';

class PressureCard extends StatelessWidget {
  final PressureReading reading;

  const PressureCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final level = reading.level;
    final alarming =
        level == PressureLevel.high || level == PressureLevel.critical;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          PressureGauge(score: reading.score),
          AppSpacing.verticalGapMd,
          Text(
            level.label,
            style: AppTextStyles.labelLarge.copyWith(
              color: alarming ? AppColors.brand : AppColors.primary,
            ),
          ),
          AppSpacing.verticalGapLg,
          const Divider(height: 1, color: AppColors.divider),
          AppSpacing.verticalGapLg,
          Row(
            children: [
              _Stat(
                icon: HugeIcons.strokeRoundedAlert02,
                value: reading.overdue,
                label: 'Overdue',
                alarming: reading.overdue > 0,
              ),
              _Stat(
                icon: HugeIcons.strokeRoundedClock01,
                value: reading.dueWithin24h,
                label: 'Due today',
              ),
              _Stat(
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

class _Stat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final bool alarming;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.alarming = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = alarming ? AppColors.brand : AppColors.textPrimary;
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: alarming ? AppColors.brand : AppColors.primary,
          ),
          AppSpacing.verticalGapXs,
          RollingNumber(
            value: value,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

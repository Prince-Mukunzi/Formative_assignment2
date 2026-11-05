import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../app_card.dart';
import '../stat_tile.dart';
import 'pressure_gauge.dart';

class PressureCard extends StatelessWidget {
  final PressureReading reading;

  const PressureCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final level = reading.level;
    final alarming =
        level == PressureLevel.high || level == PressureLevel.critical;
    final overdue = reading.overdue > 0;
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
              Expanded(
                child: StatTile(
                  icon: HugeIcons.strokeRoundedAlert02,
                  value: reading.overdue,
                  label: 'Overdue',
                  iconColor: overdue ? AppColors.brand : AppColors.primary,
                  valueColor: overdue ? AppColors.brand : AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: StatTile(
                  icon: HugeIcons.strokeRoundedClock01,
                  value: reading.dueWithin24h,
                  label: 'Due today',
                ),
              ),
              Expanded(
                child: StatTile(
                  icon: HugeIcons.strokeRoundedUserGroup,
                  value: reading.waitingStudents,
                  label: 'Waiting',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

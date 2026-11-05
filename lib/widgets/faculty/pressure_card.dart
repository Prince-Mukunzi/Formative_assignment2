import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../motion/rolling_number.dart';
import '../motion/spring_value.dart';
import 'pressure_gauge.dart';

class PressureCard extends StatelessWidget {
  final PressureReading reading;

  const PressureCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return SpringValue(
      value: reading.score / 100,
      from: 0,
      spring: AppSprings.soft,
      builder: (_, heat, child) {
        final t = heat.clamp(0.0, 1.0);
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: AppShadows.floating,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(AppColors.primaryDark, AppColors.overdueDark, t)!,
                Color.lerp(AppColors.primaryLight, AppColors.overdue, t)!,
              ],
            ),
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          PressureGauge(score: reading.score),
          AppSpacing.verticalGapSm,
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: Text(
              reading.level.label,
              key: ValueKey(reading.level),
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
          AppSpacing.verticalGapLg,
          Row(
            children: [
              _Stat(value: reading.overdue, label: 'Overdue'),
              _Stat(value: reading.dueWithin24h, label: 'Due in 24h'),
              _Stat(value: reading.waitingStudents, label: 'Students waiting'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          RollingNumber(
            value: value,
            style: AppTextStyles.statNumber.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.statLabel.copyWith(
              color: AppColors.onPrimaryMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

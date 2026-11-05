import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/report.dart';
import '../banner_stat.dart';
import '../faculty/pressure_gauge.dart';
import '../gradient_banner.dart';

/// The faculty pressure gauge, read across every team on campus.
class CampusPulseCard extends StatelessWidget {
  final List<Report> reports;
  final DateTime now;
  final int unowned;

  const CampusPulseCard({
    super.key,
    required this.reports,
    required this.now,
    required this.unowned,
  });

  @override
  Widget build(BuildContext context) {
    final reading = PressureReading.of(reports, now);
    final open = reports.where((r) => r.isOpen).length;
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
          Text(
            'Campus pressure',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onPrimaryMuted,
            ),
          ),
          AppSpacing.verticalGapLg,
          const Divider(height: 1, color: AppColors.onPrimaryFaint),
          AppSpacing.verticalGapLg,
          Row(
            children: [
              BannerStat(
                icon: HugeIcons.strokeRoundedTask01,
                value: open,
                label: 'Open',
              ),
              BannerStat(
                icon: HugeIcons.strokeRoundedAlert02,
                value: reading.overdue,
                label: 'Late',
              ),
              BannerStat(
                icon: HugeIcons.strokeRoundedUserQuestion01,
                value: unowned,
                label: 'No team',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../models/sla.dart';
import '../gradient_banner.dart';
import '../motion/rolling_number.dart';
import '../ring_gauge.dart';

class CampusPulseCard extends StatelessWidget {
  final List<Report> reports;
  final DateTime now;

  const CampusPulseCard({super.key, required this.reports, required this.now});

  @override
  Widget build(BuildContext context) {
    final counted = reports.where((r) => r.status != ReportStatus.declined);
    final total = counted.length;
    final open = counted.where((r) => r.isOpen).length;
    final fixed = total - open;
    final late = reports
        .where((r) => r.slaStateAt(now) == SlaState.overdue)
        .length;
    return GradientBanner(
      gradient: AppColors.navy,
      child: Row(
        children: [
          RingGauge(progress: total == 0 ? 0 : fixed / total),
          AppSpacing.horizontalGapXl,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Stat(
                  label: 'Fixed',
                  value: fixed,
                  suffix: '/$total',
                  lead: true,
                ),
                AppSpacing.verticalGapMd,
                _Stat(label: 'Open', value: open),
                AppSpacing.verticalGapMd,
                _Stat(label: 'Late', value: late),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final bool lead;

  const _Stat({
    required this.label,
    required this.value,
    this.suffix = '',
    this.lead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        RollingNumber(
          value: value,
          suffix: suffix,
          style: AppTextStyles.heading2.copyWith(
            color: lead ? AppColors.textOnPrimary : AppColors.onPrimaryMuted,
          ),
        ),
      ],
    );
  }
}

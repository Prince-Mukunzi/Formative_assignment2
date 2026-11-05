import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../models/sla.dart';
import '../game/xp_bar.dart';
import '../gradient_banner.dart';
import '../motion/rolling_number.dart';
import '../status_mark.dart';

class CampusPulseCard extends StatelessWidget {
  final List<Report> reports;
  final DateTime now;

  const CampusPulseCard({super.key, required this.reports, required this.now});

  int _count(ReportStatus status) =>
      reports.where((r) => r.status == status).length;

  @override
  Widget build(BuildContext context) {
    final pending = _count(ReportStatus.awaitingApproval);
    final active = _count(ReportStatus.inProgress);
    final resolved = _count(ReportStatus.resolved);
    final total = pending + active + resolved;
    final late = reports
        .where((r) => r.slaStateAt(now) == SlaState.overdue)
        .length;
    final muted = AppTextStyles.bodySmall.copyWith(
      color: AppColors.onPrimaryMuted,
    );
    return GradientBanner(
      gradient: AppColors.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RollingNumber(
                  value: pending + active,
                  suffix: ' open',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              if (late > 0) _LatePill(count: late),
            ],
          ),
          Text(
            pending + active == 0 ? 'Nothing waiting' : 'Reports to finish',
            style: muted,
          ),
          AppSpacing.verticalGapLg,
          XpBar(
            progress: total == 0 ? 0 : resolved / total,
            from: 0,
            trackColor: AppColors.onPrimaryFaint,
            fillColor: AppColors.textOnPrimary,
          ),
          AppSpacing.verticalGapSm,
          Text('$resolved of $total fixed', style: muted),
          AppSpacing.verticalGapXl,
          Row(
            children: [
              _StatusCount(
                status: ReportStatus.awaitingApproval,
                value: pending,
              ),
              _StatusCount(status: ReportStatus.inProgress, value: active),
              _StatusCount(status: ReportStatus.resolved, value: resolved),
            ],
          ),
        ],
      ),
    );
  }
}

class _LatePill extends StatelessWidget {
  final int count;

  const _LatePill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            HugeIcons.strokeRoundedAlert02,
            size: 14,
            color: AppColors.brand,
          ),
          AppSpacing.horizontalGapXs,
          Text(
            '$count late',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.brand),
          ),
        ],
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  final ReportStatus status;
  final int value;

  const _StatusCount({required this.status, required this.value});

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
              StatusMark(status: status, color: AppColors.onPrimaryMuted),
              AppSpacing.horizontalGapXs,
              Text(
                status.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onPrimaryMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';

/// Which payouts a report has hit, and what the next one is worth.
class BountyTrack extends StatelessWidget {
  final Report report;

  const BountyTrack({super.key, required this.report});

  static const _steps = [
    (label: 'Filed', reason: XpReason.reportFiled),
    (label: 'Approved', reason: XpReason.reportApproved),
    (label: 'Fixed', reason: XpReason.reportResolved),
    (label: 'Checked', reason: XpReason.fixChecked),
  ];

  int get _completed => switch (report.status) {
    ReportStatus.awaitingApproval || ReportStatus.declined => 1,
    ReportStatus.inProgress => 2,
    ReportStatus.resolved => report.verifiedAt == null ? 3 : 4,
  };

  @override
  Widget build(BuildContext context) {
    final completed = _completed;
    final declined = report.status == ReportStatus.declined;
    final reopened = report.reopenCount > 0 && report.isOpen;
    final label = declined
        ? 'Declined'
        : reopened
        ? 'Reopened'
        : completed == _steps.length
        ? 'Complete'
        : _steps[completed - 1].label;
    final showNext = !declined && !reopened && completed < _steps.length;
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              if (i > 0) AppSpacing.horizontalGapXs,
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  decoration: BoxDecoration(
                    color: i < completed && !declined
                        ? AppColors.brand
                        : AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
            ],
          ],
        ),
        AppSpacing.verticalGapSm,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            if (showNext)
              Text(
                '+${_steps[completed].reason.xp} next',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

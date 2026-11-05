import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../../models/report.dart';
import '../../models/sla.dart';
import '../../providers/clock_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/faculty/department_board.dart';
import '../../widgets/motion/pressable.dart';

class BoardScreen extends ConsumerWidget {
  final Department department;
  final ValueChanged<Report> onReportTap;

  const BoardScreen({
    super.key,
    required this.department,
    required this.onReportTap,
  });

  static const _wallSize = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);
    final now = ref.watch(minuteProvider);
    final board = departmentBoard(reports, now);
    final late =
        reports.where((r) => r.slaStateAt(now) == SlaState.overdue).toList()
          ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalGapLg,
            Text('Campus scoreboard', style: AppTextStyles.heading2),
            AppSpacing.verticalGapXs,
            Row(
              children: [
                const Icon(
                  HugeIcons.strokeRoundedEye,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.horizontalGapXs,
                Text(
                  'Students can see this board',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
            AppSpacing.verticalGapLg,
            _StandingBanner(board: board, department: department),
            AppSpacing.verticalGapLg,
            DepartmentBoard(highlight: department),
            AppSpacing.verticalGapMd,
            Text(
              '+10 per resolved report, -15 per overdue, -10 per reopen',
              style: AppTextStyles.bodySmall,
            ),
            if (late.isNotEmpty) ...[
              AppSpacing.verticalGapXxl,
              Text('Longest overdue', style: AppTextStyles.heading3),
              AppSpacing.verticalGapMd,
              for (final report in late.take(_wallSize))
                _OverdueRow(
                  report: report,
                  now: now,
                  onTap: () => onReportTap(report),
                ),
            ],
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }
}

class _StandingBanner extends StatelessWidget {
  final List<DepartmentScore> board;
  final Department department;

  const _StandingBanner({required this.board, required this.department});

  @override
  Widget build(BuildContext context) {
    final place = board.indexWhere((s) => s.department == department);
    final mine = board[place];
    final leads = place == 0;
    final rival = leads ? null : board[place - 1];
    final gap = rival == null ? 0 : rival.points - mine.points;
    final message = leads
        ? 'You lead the campus. Keep the clock clean to hold it.'
        : 'You are $gap pts behind ${rival!.department.label}. Clearing one '
              'overdue report is worth 25.';
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: leads ? AppColors.resolvedLight : AppColors.overdueLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Text(
        message,
        style: AppTextStyles.labelMedium.copyWith(
          color: leads ? AppColors.textPrimary : AppColors.overdueDark,
        ),
      ),
    );
  }
}

class _OverdueRow extends StatelessWidget {
  final Report report;
  final DateTime now;
  final VoidCallback onTap;

  const _OverdueRow({
    required this.report,
    required this.now,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final late = report.timeLeftAt(now) ?? Duration.zero;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: AppTextStyles.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${report.department.label}, ${report.affectedLabel}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              AppSpacing.horizontalGapMd,
              Text(
                formatSlaDuration(late),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.overdue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

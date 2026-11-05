import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../../models/report_status.dart';
import '../../models/sla.dart';
import '../../providers/clock_provider.dart';
import '../../providers/directory_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/rolling_number.dart';
import 'locations_sheet.dart';
import 'team_sheet.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);
    final now = ref.watch(minuteProvider);
    final departments = ref.watch(departmentsProvider);
    final locations = ref.watch(locationsProvider);
    final unowned = reports
        .where((r) => r.isOpen && departments.ownerOf(r) == null)
        .length;
    final overdue = reports
        .where((r) => r.slaStateAt(now) == SlaState.overdue)
        .length;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalGapLg,
            Row(
              children: [
                Expanded(child: Text('Admin', style: AppTextStyles.heading1)),
                Pressable(
                  onTap: () => ref.read(sessionProvider.notifier).signOut(),
                  child: const Icon(
                    HugeIcons.strokeRoundedLogout01,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Row(
              children: [
                _Stat(
                  value: reports.where((r) => r.isOpen).length,
                  label: 'Open',
                ),
                _Stat(value: overdue, label: 'Overdue', alarming: overdue > 0),
                _Stat(
                  value: reports
                      .where((r) => r.status == ReportStatus.resolved)
                      .length,
                  label: 'Resolved',
                ),
              ],
            ),
            if (unowned > 0) ...[
              AppSpacing.verticalGapLg,
              Text(
                '$unowned with no team',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.brand),
              ),
            ],
            const SizedBox(height: AppSpacing.xxxl),
            Text('Teams', style: AppTextStyles.labelLarge),
            AppSpacing.verticalGapSm,
            for (final score in ref.watch(departmentBoardProvider))
              _TeamRow(
                score: score,
                onTap: () => TeamSheet.show(context, score.department),
              ),
            AppSpacing.verticalGapLg,
            Pressable(
              onTap: () => LocationsSheet.show(context),
              scale: 0.98,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Locations', style: AppTextStyles.labelLarge),
                    ),
                    Text(
                      '${locations.length}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.horizontalGapSm,
                    const Icon(
                      HugeIcons.strokeRoundedArrowRight01,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  final bool alarming;

  const _Stat({
    required this.value,
    required this.label,
    this.alarming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RollingNumber(
            value: value,
            style: AppTextStyles.heading1.copyWith(
              color: alarming ? AppColors.brand : AppColors.textPrimary,
            ),
          ),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final DepartmentScore score;
  final VoidCallback onTap;

  const _TeamRow({required this.score, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                score.department.label,
                style: AppTextStyles.labelMedium,
              ),
            ),
            if (score.overdue > 0) ...[
              Text(
                '${score.overdue} late',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.brand),
              ),
              AppSpacing.horizontalGapMd,
            ],
            Text('${score.open} open', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

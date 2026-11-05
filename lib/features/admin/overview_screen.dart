import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../providers/clock_provider.dart';
import '../../providers/directory_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/banner_stat.dart';
import '../../widgets/gradient_banner.dart';
import '../../widgets/menu_row.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/section_title.dart';
import '../../widgets/tinted_icon.dart';
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
            AppSpacing.verticalGapLg,
            _HealthBanner(reports: reports, now: now),
            if (unowned > 0) ...[
              AppSpacing.verticalGapMd,
              AppCard(
                child: Text(
                  '$unowned with no team',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.brand,
                  ),
                ),
              ),
            ],
            const SectionTitle('Teams'),
            CardList(
              children: [
                for (final score in ref.watch(departmentBoardProvider))
                  _TeamRow(
                    score: score,
                    onTap: () => TeamSheet.show(context, score.department),
                  ),
              ],
            ),
            const SectionTitle('Campus'),
            CardList(
              children: [
                MenuRow(
                  icon: HugeIcons.strokeRoundedLocation01,
                  label: 'Locations',
                  value: '${locations.length}',
                  onTap: () => LocationsSheet.show(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }
}

class _HealthBanner extends StatelessWidget {
  final List<Report> reports;
  final DateTime now;

  const _HealthBanner({required this.reports, required this.now});

  @override
  Widget build(BuildContext context) {
    final reading = PressureReading.of(reports, now);
    final counted = reports.where((r) => r.status != ReportStatus.declined);
    final resolved = counted
        .where((r) => r.status == ReportStatus.resolved)
        .length;
    final total = counted.length;
    return GradientBanner(
      gradient: reading.overdue > 0 ? AppColors.signature : AppColors.navy,
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(progress: total == 0 ? 0 : resolved / total),
              AppSpacing.horizontalGapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resolved',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      '$resolved of $total reports',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onPrimaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapLg,
          const Divider(height: 1, color: AppColors.onPrimaryFaint),
          AppSpacing.verticalGapLg,
          Row(
            children: [
              BannerStat(
                icon: HugeIcons.strokeRoundedTask01,
                value: reports.where((r) => r.isOpen).length,
                label: 'Open',
              ),
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

class _TeamRow extends StatelessWidget {
  final DepartmentScore score;
  final VoidCallback onTap;

  const _TeamRow({required this.score, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            TintedIcon(icon: score.department.icon, size: 36),
            AppSpacing.horizontalGapMd,
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

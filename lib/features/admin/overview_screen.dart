import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../../providers/clock_provider.dart';
import '../../providers/directory_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/admin/campus_pulse_card.dart';
import '../../widgets/menu_row.dart';
import '../../widgets/motion/pressable.dart';
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
    final teams = ref.watch(departmentBoardProvider);
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
            const AppLogo(),
            AppSpacing.verticalGapLg,
            Text('Admin', style: AppTextStyles.heading1),
            AppSpacing.verticalGapLg,
            CampusPulseCard(reports: reports, now: now, unowned: unowned),
            const SectionTitle('Teams'),
            CardList(
              children: [
                for (final score in teams)
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

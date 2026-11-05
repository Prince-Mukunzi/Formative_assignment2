import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/mock_data.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/department.dart';
import '../../models/game.dart';
import '../../models/report_status.dart';
import '../../models/sla.dart';
import '../../providers/clock_provider.dart';
import '../../providers/directory_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/rolling_number.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final department = ref.watch(currentDepartmentProvider);
    final xp = ref.watch(gameProvider.select((game) => game.xp));
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalGapLg,
            Text(
              department?.label ?? '${MockData.userName} Mukunzi',
              style: AppTextStyles.heading1,
            ),
            AppSpacing.verticalGapXs,
            Text(
              department == null ? Rank.forXp(xp).label : 'Faculty',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Row(children: _stats(ref, department)),
            const SizedBox(height: AppSpacing.xxxl),
            if (department == null)
              _MenuItem(
                label: 'Progress',
                onTap: () => context.push(AppRoutes.progress),
              ),
            const _MenuItem(label: 'Notifications'),
            const _MenuItem(label: 'Settings'),
            const _MenuItem(label: 'About'),
            const _MenuItem(label: 'Help'),
            AppSpacing.verticalGapXl,
            Pressable(
              onTap: () => ref.read(sessionProvider.notifier).signOut(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'Sign out',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.brand,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }

  List<_StatTile> _stats(WidgetRef ref, Department? department) {
    final reports = ref.watch(reportsProvider);
    if (department == null) {
      final mine = reports.where(
        (r) => r.reportedBy == MockData.currentStudentId,
      );
      return [
        _StatTile(count: mine.length, label: 'Reports'),
        _StatTile(
          count: mine.where((r) => r.status == ReportStatus.resolved).length,
          label: 'Resolved',
        ),
        _StatTile(
          count: mine.fold(0, (sum, r) => sum + r.upvotes),
          label: 'Upvotes',
        ),
      ];
    }
    final now = ref.watch(minuteProvider);
    final owned = ref.watch(departmentReportsProvider(department.id));
    return [
      _StatTile(
        count: owned.where((r) => r.status == ReportStatus.resolved).length,
        label: 'Resolved',
      ),
      _StatTile(count: owned.where((r) => r.isOpen).length, label: 'Open'),
      _StatTile(
        count: owned.where((r) => r.slaStateAt(now) == SlaState.overdue).length,
        label: 'Overdue',
      ),
    ];
  }
}

class _StatTile extends StatelessWidget {
  final int count;
  final String label;

  const _StatTile({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RollingNumber(value: count, style: AppTextStyles.heading1),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap ?? () {},
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.labelMedium)),
            const Icon(
              HugeIcons.strokeRoundedArrowRight01,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

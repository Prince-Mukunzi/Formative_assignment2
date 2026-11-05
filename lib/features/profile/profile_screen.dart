import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/mock_data.dart';
import '../../models/department.dart';
import '../../models/game.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../models/session.dart';
import '../../models/sla.dart';
import '../../providers/clock_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/rolling_number.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _headerHeight = 230.0;
  static const _statsOverlap = 44.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final department = session is FacultySession ? session.department : null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildHeader(context, ref, department),
            Transform.translate(
              offset: const Offset(0, -_statsOverlap),
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    _buildStatsCard(_stats(ref, department)),
                    AppSpacing.verticalGapXxl,
                    _buildMenuCard(context, isFaculty: department != null),
                    AppSpacing.verticalGapXxl,
                    _buildLogoutButton(ref),
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

  List<_StatTile> _stats(WidgetRef ref, Department? department) {
    final reports = ref.watch(reportsProvider);
    if (department == null) {
      final mine = reports.where(
        (r) => r.reportedBy == MockData.currentStudentId,
      );
      return [
        _StatTile(
          count: mine.length,
          label: 'Reports',
          icon: HugeIcons.strokeRoundedTask01,
          color: AppColors.accent,
          background: AppColors.accentLight,
        ),
        _StatTile(
          count: mine.where((r) => r.status == ReportStatus.resolved).length,
          label: 'Resolved',
          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
          color: AppColors.resolved,
          background: AppColors.resolvedLight,
        ),
        _StatTile(
          count: mine.fold(0, (sum, r) => sum + r.upvotes),
          label: 'Upvotes',
          icon: HugeIcons.strokeRoundedThumbsUp,
          color: AppColors.inProgress,
          background: AppColors.inProgressLight,
        ),
      ];
    }
    final now = ref.watch(minuteProvider);
    final List<Report> owned =
        reports.where((r) => r.department == department).toList();
    return [
      _StatTile(
        count: owned.where((r) => r.status == ReportStatus.resolved).length,
        label: 'Resolved',
        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
        color: AppColors.resolved,
        background: AppColors.resolvedLight,
      ),
      _StatTile(
        count: owned.where((r) => r.isOpen).length,
        label: 'Open',
        icon: HugeIcons.strokeRoundedTask01,
        color: AppColors.accent,
        background: AppColors.accentLight,
      ),
      _StatTile(
        count: owned.where((r) => r.slaStateAt(now) == SlaState.overdue).length,
        label: 'Overdue',
        icon: HugeIcons.strokeRoundedAlarmClock,
        color: AppColors.overdue,
        background: AppColors.overdueLight,
      ),
    ];
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    Department? department,
  ) {
    final xp = ref.watch(gameProvider.select((game) => game.xp));
    final subtitle = department == null
        ? '${Rank.forXp(xp).label}, $xp XP'
        : 'Faculty';
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: _headerHeight + top,
      padding: EdgeInsets.only(top: top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatar(department),
          AppSpacing.verticalGapMd,
          Text(
            department == null
                ? '${MockData.userName} Mukunzi'
                : '${department.label} team',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          AppSpacing.verticalGapXs,
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: _statsOverlap / 2),
        ],
      ),
    );
  }

  Widget _buildAvatar(Department? department) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 3),
        boxShadow: AppShadows.floating,
      ),
      child: Center(
        child: department == null
            ? Text(
                'PM',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primary,
                  fontSize: 30,
                ),
              )
            : Icon(department.icon, size: 34, color: AppColors.primary),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 400.ms);
  }

  Widget _buildStatsCard(List<_StatTile> tiles) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0)
                const VerticalDivider(width: 1, color: AppColors.divider),
              tiles[i],
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.08, end: 0, duration: 400.ms);
  }

  Widget _buildMenuCard(BuildContext context, {required bool isFaculty}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          if (!isFaculty) ...[
            _MenuItem(
              icon: HugeIcons.strokeRoundedAward01,
              label: 'Progress and badges',
              onTap: () => context.push(AppRoutes.progress),
            ),
            const _MenuDivider(),
          ],
          const _MenuItem(
            icon: HugeIcons.strokeRoundedNotification02,
            label: 'Notifications',
            badge: 3,
          ),
          const _MenuDivider(),
          const _MenuItem(
            icon: HugeIcons.strokeRoundedSettings01,
            label: 'Settings',
          ),
          const _MenuDivider(),
          const _MenuItem(
            icon: HugeIcons.strokeRoundedInformationCircle,
            label: 'About',
          ),
          const _MenuDivider(),
          const _MenuItem(
            icon: HugeIcons.strokeRoundedCustomerService01,
            label: 'Help & Support',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms);
  }

  Widget _buildLogoutButton(WidgetRef ref) {
    return Pressable(
      onTap: () => ref.read(sessionProvider.notifier).signOut(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              HugeIcons.strokeRoundedLogout01,
              size: 20,
              color: AppColors.error,
            ),
            AppSpacing.horizontalGapSm,
            Text(
              'Sign out and switch role',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

class _StatTile extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatTile({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          AppSpacing.verticalGapSm,
          RollingNumber(value: count, style: AppTextStyles.statNumber),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap ?? () {},
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            AppSpacing.horizontalGapMd,
            Expanded(child: Text(label, style: AppTextStyles.labelMedium)),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '$badge',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.horizontalGapSm,
            ],
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

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 68),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/app_info.dart';
import '../../core/mock_data.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/department.dart';
import '../../models/game.dart';
import '../../models/report_status.dart';
import '../../models/session.dart';
import '../../models/sla.dart';
import '../../providers/clock_provider.dart';
import '../../providers/directory_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/banner_stat.dart';
import '../../widgets/game/next_prize_card.dart';
import '../../widgets/gradient_banner.dart';
import '../../widgets/menu_row.dart';
import '../../widgets/section_title.dart';
import '../../widgets/settings/notifications_row.dart';
import '../../widgets/settings/toggle_row.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final department = ref.watch(currentDepartmentProvider);
    final isAdmin = session is AdminSession;
    final isStudent = department == null && !isAdmin;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final xp = ref.watch(gameProvider.select((game) => game.xp));
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalGapLg,
            GradientBanner(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAdmin
                        ? 'Admin'
                        : department?.label ?? '${MockData.userName} Mukunzi',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  Text(
                    isAdmin
                        ? 'Campus'
                        : isStudent
                        ? Rank.forXp(xp).label
                        : 'Faculty',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.onPrimaryMuted,
                    ),
                  ),
                  AppSpacing.verticalGapXl,
                  Row(
                    children: isAdmin
                        ? _adminStats(ref)
                        : _stats(ref, department),
                  ),
                ],
              ),
            ),
            if (isStudent) ...[
              const SectionTitle('Next prize'),
              NextPrizeCard(
                xp: xp,
                onTap: () => context.push(AppRoutes.progress),
              ),
            ],
            AppSpacing.verticalGapLg,
            CardList(
              children: [
                const NotificationsRow(),
                ToggleRow(
                  icon: HugeIcons.strokeRoundedSmartPhone01,
                  label: 'Haptics',
                  value: settings.haptics,
                  onChanged: notifier.setHaptics,
                ),
                ToggleRow(
                  icon: HugeIcons.strokeRoundedDashboardSpeed01,
                  label: 'Reduce motion',
                  value: settings.reduceMotion,
                  onChanged: notifier.setReduceMotion,
                ),
                if (isStudent)
                  ToggleRow(
                    icon: HugeIcons.strokeRoundedParty,
                    label: 'Celebrations',
                    value: settings.celebrations,
                    onChanged: notifier.setCelebrations,
                  ),
                const MenuRow(
                  icon: HugeIcons.strokeRoundedHelpCircle,
                  label: 'Help',
                ),
              ],
            ),
            AppSpacing.verticalGapLg,
            CardList(
              children: [
                MenuRow(
                  icon: HugeIcons.strokeRoundedLogout01,
                  label: 'Sign out',
                  accent: true,
                  onTap: () => ref.read(sessionProvider.notifier).signOut(),
                ),
              ],
            ),
            AppSpacing.verticalGapXl,
            const _Signature(),
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }

  List<BannerStat> _adminStats(WidgetRef ref) => [
    BannerStat(
      icon: HugeIcons.strokeRoundedTask01,
      value: ref.watch(reportsProvider).length,
      label: 'Reports',
    ),
    BannerStat(
      icon: HugeIcons.strokeRoundedUserGroup,
      value: ref.watch(departmentsProvider).length,
      label: 'Teams',
    ),
    BannerStat(
      icon: HugeIcons.strokeRoundedLocation01,
      value: ref.watch(locationsProvider).length,
      label: 'Locations',
    ),
  ];

  List<BannerStat> _stats(WidgetRef ref, Department? department) {
    final reports = ref.watch(reportsProvider);
    if (department == null) {
      final mine = reports.where(
        (r) => r.reportedBy == MockData.currentStudentId,
      );
      return [
        BannerStat(
          icon: HugeIcons.strokeRoundedTask01,
          value: mine.length,
          label: 'Reports',
        ),
        BannerStat(
          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
          value: mine.where((r) => r.status == ReportStatus.resolved).length,
          label: 'Resolved',
        ),
        BannerStat(
          icon: HugeIcons.strokeRoundedThumbsUp,
          value: mine.fold(0, (sum, r) => sum + r.upvotes),
          label: 'Upvotes',
        ),
      ];
    }
    final now = ref.watch(minuteProvider);
    final owned = ref.watch(departmentReportsProvider(department.id));
    return [
      BannerStat(
        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
        value: owned.where((r) => r.status == ReportStatus.resolved).length,
        label: 'Resolved',
      ),
      BannerStat(
        icon: HugeIcons.strokeRoundedTask01,
        value: owned.where((r) => r.isOpen).length,
        label: 'Open',
      ),
      BannerStat(
        icon: HugeIcons.strokeRoundedAlert02,
        value: owned.where((r) => r.slaStateAt(now) == SlaState.overdue).length,
        label: 'Overdue',
      ),
    ];
  }
}

class _Signature extends StatelessWidget {
  const _Signature();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              style: AppTextStyles.bodySmall,
              children: [
                const TextSpan(text: 'Made with '),
                TextSpan(
                  text: '❤️',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const TextSpan(text: ' by Mukunzi'),
              ],
            ),
          ),
          AppSpacing.verticalGapXs,
          Text(
            'Version $appVersion',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

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
import '../../widgets/app_card.dart';
import '../../widgets/banner_stat.dart';
import '../../widgets/game/next_prize_card.dart';
import '../../widgets/gradient_banner.dart';
import '../../widgets/menu_row.dart';
import '../../widgets/section_title.dart';

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
            GradientBanner(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    department?.label ?? '${MockData.userName} Mukunzi',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  Text(
                    department == null ? Rank.forXp(xp).label : 'Faculty',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.onPrimaryMuted,
                    ),
                  ),
                  AppSpacing.verticalGapXl,
                  Row(children: _stats(ref, department)),
                ],
              ),
            ),
            if (department == null) ...[
              const SectionTitle('Next prize'),
              NextPrizeCard(
                xp: xp,
                onTap: () => context.push(AppRoutes.progress),
              ),
            ],
            AppSpacing.verticalGapLg,
            CardList(
              children: [
                if (department == null)
                  MenuRow(
                    icon: HugeIcons.strokeRoundedAward01,
                    label: 'Progress',
                    onTap: () => context.push(AppRoutes.progress),
                  ),
                const MenuRow(
                  icon: HugeIcons.strokeRoundedNotification01,
                  label: 'Notifications',
                ),
                const MenuRow(
                  icon: HugeIcons.strokeRoundedSettings01,
                  label: 'Settings',
                ),
                const MenuRow(
                  icon: HugeIcons.strokeRoundedInformationCircle,
                  label: 'About',
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
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }

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

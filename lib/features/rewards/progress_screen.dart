import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../providers/game_provider.dart';
import '../../widgets/faculty/department_board.dart';
import '../../widgets/game/badge_tile.dart';
import '../../widgets/game/rank_emblem.dart';
import '../../widgets/game/streak_chip.dart';
import '../../widgets/game/xp_bar.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/rolling_number.dart';
import '../../widgets/motion/spring_in.dart';
import '../../widgets/spring_rank_list.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(gameProvider.select((game) => game.xp));
    final stats = ref.watch(gameStatsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: Pressable(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text('Your progress', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalGapMd,
            SpringIn(child: _RankHero(xp: xp, streak: stats.streak)),
            AppSpacing.verticalGapXxl,
            Text('Badges', style: AppTextStyles.heading3),
            AppSpacing.verticalGapLg,
            _BadgeGrid(stats: stats),
            AppSpacing.verticalGapXxl,
            Text('Top hunters', style: AppTextStyles.heading3),
            AppSpacing.verticalGapMd,
            _Leaderboard(xp: xp),
            AppSpacing.verticalGapXxl,
            Text('Who is fixing things', style: AppTextStyles.heading3),
            AppSpacing.verticalGapXs,
            Text(
              'Departments lose points for every overdue report.',
              style: AppTextStyles.subtitle,
            ),
            AppSpacing.verticalGapMd,
            const DepartmentBoard(),
            AppSpacing.verticalGapXl,
            Text('How to earn', style: AppTextStyles.heading3),
            AppSpacing.verticalGapMd,
            const _EarnList(),
            const SizedBox(height: AppSpacing.xxxl * 2),
          ],
        ),
      ),
    );
  }
}

class _RankHero extends StatelessWidget {
  final int xp;
  final int streak;

  const _RankHero({required this.xp, required this.streak});

  @override
  Widget build(BuildContext context) {
    final rank = Rank.forXp(xp);
    final next = rank.next;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppShadows.floating,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
      ),
      child: Column(
        children: [
          RankEmblem(rank: rank, size: 84),
          AppSpacing.verticalGapMd,
          Text(
            rank.label,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          AppSpacing.verticalGapXs,
          RollingNumber(
            value: xp,
            suffix: ' XP',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.rewardBright,
            ),
          ),
          AppSpacing.verticalGapLg,
          XpBar(progress: rank.progressAt(xp), from: 0, height: 10),
          AppSpacing.verticalGapSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreakChip(days: streak),
              Text(
                next == null
                    ? 'Top rank reached'
                    : '${next.threshold - xp} XP to ${next.label}',
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

class _BadgeGrid extends StatelessWidget {
  final GameStats stats;

  const _BadgeGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = (constraints.maxWidth - AppSpacing.md * 2) / 3;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xl,
          children: [
            for (var i = 0; i < BadgeKind.values.length; i++)
              SizedBox(
                width: width,
                child: SpringIn(
                  delay: Duration(milliseconds: 50 * i),
                  fromScale: 0.7,
                  offsetY: 0,
                  child: BadgeTile(
                    badge: BadgeKind.values[i],
                    earned: BadgeKind.values[i].isEarned(stats),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Leaderboard extends StatelessWidget {
  final int xp;

  const _Leaderboard({required this.xp});

  static const _rowHeight = 60.0;
  static const _you = 'You';

  @override
  Widget build(BuildContext context) {
    final entries = [
      ...MockData.leaderboardPeers,
      (name: _you, xp: xp),
    ]..sort((a, b) => b.xp.compareTo(a.xp));
    return SpringRankList(
      rowHeight: _rowHeight,
      rows: [
        for (var i = 0; i < entries.length; i++)
          (
            id: entries[i].name,
            child: _LeaderRow(
              place: i + 1,
              name: entries[i].name,
              xp: entries[i].xp,
              isYou: entries[i].name == _you,
            ),
          ),
      ],
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int place;
  final String name;
  final int xp;
  final bool isYou;

  const _LeaderRow({
    required this.place,
    required this.name,
    required this.xp,
    required this.isYou,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: isYou ? AppColors.rewardLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text('$place', style: AppTextStyles.labelLarge),
            ),
            RankEmblem(rank: Rank.forXp(xp), size: 30),
            AppSpacing.horizontalGapMd,
            Expanded(child: Text(name, style: AppTextStyles.labelMedium)),
            Text('$xp XP', style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _EarnList extends StatelessWidget {
  const _EarnList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final reason in XpReason.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(reason.label, style: AppTextStyles.bodyMedium),
                ),
                Text(
                  '+${reason.xp}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.rewardDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

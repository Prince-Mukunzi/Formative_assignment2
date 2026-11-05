import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../providers/game_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/game_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/faculty/department_board.dart';
import '../../widgets/game/badge_tile.dart';
import '../../widgets/game/prize_ladder.dart';
import '../../widgets/game/rank_emblem.dart';
import '../../widgets/game/xp_bar.dart';
import '../../widgets/gradient_banner.dart';
import '../../widgets/menu_row.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/rolling_number.dart';
import '../../widgets/section_title.dart';
import '../../widgets/spring_rank_list.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(gameProvider.select((game) => game.xp));
    final stats = ref.watch(gameStatsProvider);
    final peers = ref.watch(leaderboardProvider).value ?? const [];
    final uid = ref.watch(sessionUidProvider) ?? '';
    return Scaffold(
      appBar: AppBar(
        leading: Pressable(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Hero(xp: xp),
            const SectionTitle('Prizes'),
            PrizeLadder(xp: xp),
            const SectionTitle('Badges'),
            _Badges(stats: stats),
            const SectionTitle('Top hunters'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _Leaderboard(xp: xp, peers: peers, uid: uid),
            ),
            AppSpacing.verticalGapLg,
            CardList(
              children: [
                MenuRow(
                  icon: HugeIcons.strokeRoundedRanking,
                  label: 'Campus board',
                  onTap: () => _showSheet(context, const DepartmentBoard()),
                ),
                MenuRow(
                  icon: HugeIcons.strokeRoundedAward01,
                  label: 'How to earn',
                  onTap: () => _showSheet(context, const _EarnList()),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, Widget child) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: AppSpacing.screenAll,
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final int xp;

  const _Hero({required this.xp});

  @override
  Widget build(BuildContext context) {
    final rank = Rank.forXp(xp);
    final next = rank.next;
    return GradientBanner(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RankEmblem(rank: rank, size: 44),
              AppSpacing.horizontalGapMd,
              Text(
                rank.label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapLg,
          RollingNumber(
            value: xp,
            suffix: ' XP',
            style: AppTextStyles.display.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          AppSpacing.verticalGapMd,
          XpBar(
            progress: rank.progressAt(xp),
            from: 0,
            trackColor: AppColors.onPrimaryFaint,
            fillColor: AppColors.textOnPrimary,
          ),
          AppSpacing.verticalGapSm,
          Text(
            next == null
                ? 'Top rank'
                : '${next.threshold - xp} to ${next.label}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onPrimaryMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badges extends StatelessWidget {
  final GameStats stats;

  const _Badges({required this.stats});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.lg,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.05,
        children: [
          for (final badge in BadgeKind.values)
            BadgeTile(badge: badge, earned: badge.isEarned(stats)),
        ],
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  final int xp;
  final List<LeaderEntry> peers;
  final String uid;

  const _Leaderboard({required this.xp, required this.peers, required this.uid});

  static const _rowHeight = 52.0;
  static const _shown = 3;
  static const _you = 'You';

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final peer in peers)
        if (peer.uid != uid) peer,
      (uid: uid, name: _you, xp: xp),
    ]..sort((a, b) => b.xp.compareTo(a.xp));
    final youAt = entries.indexWhere((e) => e.uid == uid);
    final visible = [
      for (var i = 0; i < entries.length; i++)
        if (i < _shown || i == youAt) i,
    ];
    return SpringRankList(
      rowHeight: _rowHeight,
      rows: [
        for (final i in visible)
          (
            id: entries[i].uid,
            child: _LeaderRow(
              place: i + 1,
              name: entries[i].name,
              xp: entries[i].xp,
              isYou: i == youAt,
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
    final style = AppTextStyles.labelMedium.copyWith(
      color: isYou ? AppColors.brand : AppColors.textPrimary,
      fontWeight: isYou ? FontWeight.w600 : FontWeight.w500,
    );
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '$place',
            style: style.copyWith(
              color: isYou ? AppColors.brand : AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(child: Text(name, style: style)),
        Text('$xp', style: style),
      ],
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
                Text('+${reason.xp}', style: AppTextStyles.labelMedium),
              ],
            ),
          ),
      ],
    );
  }
}

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
import '../../widgets/app_sheet.dart';
import '../../widgets/faculty/department_board.dart';
import '../../widgets/faculty/team_podium.dart';
import '../../widgets/game/prize_ladder.dart';
import '../../widgets/game/rank_ladder.dart';
import '../../widgets/game/rank_emblem.dart';
import '../../widgets/game/xp_bar.dart';
import '../../widgets/gradient_banner.dart';
import '../../widgets/menu_row.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/rolling_number.dart';
import '../../widgets/section_title.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(gameProvider.select((game) => game.xp));
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
            const SectionTitle('Top hunters'),
            _TopHunters(xp: xp, peers: peers, uid: uid),
            const SectionTitle('Prizes'),
            PrizeLadder(xp: xp),
            const SectionTitle('Ranks'),
            RankLadder(xp: xp),
            AppSpacing.verticalGapXxl,
            CardList(
              children: [
                MenuRow(
                  icon: HugeIcons.strokeRoundedRanking,
                  label: 'Campus board',
                  onTap: () => AppSheet.show<void>(
                    context,
                    title: 'Campus board',
                    icon: HugeIcons.strokeRoundedRanking,
                    child: const DepartmentBoard(),
                  ),
                ),
                MenuRow(
                  icon: HugeIcons.strokeRoundedAward01,
                  label: 'How to earn',
                  onTap: () => AppSheet.show<void>(
                    context,
                    title: 'How to earn',
                    icon: HugeIcons.strokeRoundedAward01,
                    child: const _EarnList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
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

class _TopHunters extends StatelessWidget {
  final int xp;
  final List<LeaderEntry> peers;
  final String uid;

  const _TopHunters({required this.xp, required this.peers, required this.uid});

  static const _you = 'You';

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final peer in peers)
        if (peer.uid != uid) peer,
      (uid: uid, name: _you, xp: xp),
    ]..sort((a, b) => b.xp.compareTo(a.xp));
    final place = entries.indexWhere((e) => e.uid == uid) + 1;
    return Column(
      children: [
        Podium(
          compact: true,
          entries: [
            for (final entry in entries.take(3))
              PodiumEntry(
                id: entry.uid,
                label: entry.name.split(' ').first,
                caption: '${entry.xp} XP',
                highlighted: entry.uid == uid,
              ),
          ],
        ),
        if (place > 3) ...[
          AppSpacing.verticalGapMd,
          Text('You are #$place with $xp XP', style: AppTextStyles.bodySmall),
        ],
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

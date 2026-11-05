import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../providers/game_provider.dart';
import '../../widgets/faculty/department_board.dart';
import '../../widgets/game/badge_tile.dart';
import '../../widgets/game/xp_bar.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/rolling_number.dart';
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
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Hero(xp: xp, streak: stats.streak),
            const SizedBox(height: AppSpacing.xxxl),
            _Badges(stats: stats),
            const SizedBox(height: AppSpacing.xxxl),
            _Leaderboard(xp: xp),
            const SizedBox(height: AppSpacing.xxl),
            _LinkRow(
              label: 'Campus board',
              onTap: () => _showSheet(context, const DepartmentBoard()),
            ),
            _LinkRow(
              label: 'How to earn',
              onTap: () => _showSheet(context, const _EarnList()),
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
  final int streak;

  const _Hero({required this.xp, required this.streak});

  @override
  Widget build(BuildContext context) {
    final rank = Rank.forXp(xp);
    final next = rank.next;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rank.label, style: AppTextStyles.subtitle),
        RollingNumber(value: xp, style: AppTextStyles.display),
        AppSpacing.verticalGapLg,
        XpBar(progress: rank.progressAt(xp), from: 0),
        AppSpacing.verticalGapSm,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              next == null
                  ? 'Top rank'
                  : '${next.threshold - xp} to ${next.label}',
              style: AppTextStyles.bodySmall,
            ),
            if (streak > 0)
              Text('$streak day streak', style: AppTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _Badges extends StatefulWidget {
  final GameStats stats;

  const _Badges({required this.stats});

  @override
  State<_Badges> createState() => _BadgesState();
}

class _BadgesState extends State<_Badges> {
  BadgeKind? _selected;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badges', style: AppTextStyles.labelLarge),
        AppSpacing.verticalGapLg,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final badge in BadgeKind.values)
              Pressable(
                onTap: () => setState(
                  () => _selected = _selected == badge ? null : badge,
                ),
                scale: 0.9,
                child: BadgeTile(
                  badge: badge,
                  earned: badge.isEarned(widget.stats),
                  selected: badge == selected,
                ),
              ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuart,
          alignment: Alignment.topLeft,
          child: selected == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '${selected.label}. ${selected.hint}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _Leaderboard extends StatelessWidget {
  final int xp;

  const _Leaderboard({required this.xp});

  static const _rowHeight = 52.0;
  static const _shown = 3;
  static const _you = 'You';

  @override
  Widget build(BuildContext context) {
    final entries = [...MockData.leaderboardPeers, (name: _you, xp: xp)]
      ..sort((a, b) => b.xp.compareTo(a.xp));
    final youAt = entries.indexWhere((e) => e.name == _you);
    final visible = [
      for (var i = 0; i < entries.length; i++)
        if (i < _shown || i == youAt) i,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top hunters', style: AppTextStyles.labelLarge),
        AppSpacing.verticalGapSm,
        SpringRankList(
          rowHeight: _rowHeight,
          rows: [
            for (final i in visible)
              (
                id: entries[i].name,
                child: _LeaderRow(
                  place: i + 1,
                  name: entries[i].name,
                  xp: entries[i].xp,
                  isYou: i == youAt,
                ),
              ),
          ],
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
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
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LinkRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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

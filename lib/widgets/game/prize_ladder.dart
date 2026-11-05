import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_format.dart';
import '../../models/game.dart';
import '../app_card.dart';
import '../motion/spring_expand.dart';
import '../show_more_button.dart';
import '../tinted_icon.dart';
import 'xp_bar.dart';

class PrizeLadder extends StatefulWidget {
  final int xp;

  const PrizeLadder({super.key, required this.xp});

  @override
  State<PrizeLadder> createState() => _PrizeLadderState();
}

class _PrizeLadderState extends State<PrizeLadder> {
  static const _shown = 3;

  bool _open = false;

  Widget _rows(List<Prize> prizes, Prize? upcoming) {
    return Column(
      children: [
        for (final prize in prizes) ...[
          _PrizeRow(prize: prize, xp: widget.xp, isNext: prize == upcoming),
          const Divider(height: 1, color: AppColors.divider),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = Prize.nextFor(widget.xp);
    const prizes = Prize.values;
    final last = prizes.length - _shown;
    final start = upcoming == null ? last : math.min(upcoming.index, last);
    final end = start + _shown;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          SpringExpand(
            open: _open,
            child: _rows(prizes.sublist(0, start), upcoming),
          ),
          _rows(prizes.sublist(start, end), upcoming),
          SpringExpand(
            open: _open,
            child: _rows(prizes.sublist(end), upcoming),
          ),
          ShowMoreButton(
            open: _open,
            onTap: () => setState(() => _open = !_open),
          ),
        ],
      ),
    );
  }
}

class _PrizeRow extends StatelessWidget {
  final Prize prize;
  final int xp;
  final bool isNext;

  const _PrizeRow({
    required this.prize,
    required this.xp,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = prize.unlockedAt(xp);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              TintedIcon(
                icon: prize.icon,
                accent: unlocked || isNext,
                muted: !unlocked && !isNext,
              ),
              AppSpacing.horizontalGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prize.label, style: AppTextStyles.labelMedium),
                    Text(
                      '${formatXp(prize.xp)} XP',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              unlocked
                  ? Text(
                      'Unlocked',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.brand,
                      ),
                    )
                  : const Icon(
                      HugeIcons.strokeRoundedLockKey,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
            ],
          ),
          if (isNext) ...[
            AppSpacing.verticalGapMd,
            XpBar(progress: prize.progressAt(xp), from: 0),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_format.dart';
import '../../models/game.dart';
import '../app_card.dart';
import '../tinted_icon.dart';
import 'xp_bar.dart';

class PrizeLadder extends StatelessWidget {
  final int xp;

  const PrizeLadder({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    final upcoming = Prize.nextFor(xp);
    return CardList(
      children: [
        for (final prize in Prize.values)
          _PrizeRow(prize: prize, xp: xp, isNext: prize == upcoming),
      ],
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

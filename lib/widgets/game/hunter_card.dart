import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_format.dart';
import '../../models/game.dart';
import '../../providers/game_provider.dart';
import '../gradient_banner.dart';
import '../motion/rolling_number.dart';
import 'rank_emblem.dart';
import 'xp_bar.dart';

class HunterCard extends ConsumerWidget {
  final VoidCallback onTap;

  const HunterCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(gameProvider.select((game) => game.xp));
    final rank = Rank.forXp(xp);
    final prize = Prize.nextFor(xp);
    return GradientBanner(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              RankEmblem(rank: rank, size: 44),
              AppSpacing.horizontalGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rank.label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    if (prize != null)
                      Text(
                        '${formatXp(prize.xp - xp)} to ${prize.label}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onPrimaryMuted,
                        ),
                      ),
                  ],
                ),
              ),
              RollingNumber(
                value: xp,
                suffix: ' XP',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapLg,
          XpBar(
            progress: prize?.progressAt(xp) ?? 1,
            trackColor: AppColors.onPrimaryFaint,
            fillColor: AppColors.textOnPrimary,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../providers/game_provider.dart';
import '../motion/pressable.dart';
import '../motion/rolling_number.dart';
import 'xp_bar.dart';

class HunterCard extends ConsumerWidget {
  final VoidCallback onTap;

  const HunterCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(gameProvider.select((game) => game.xp));
    final rank = Rank.forXp(xp);
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rank.label, style: AppTextStyles.labelMedium),
              RollingNumber(
                value: xp,
                suffix: ' XP',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapSm,
          XpBar(progress: rank.progressAt(xp)),
        ],
      ),
    );
  }
}

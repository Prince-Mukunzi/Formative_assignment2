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

class NextPrizeCard extends StatelessWidget {
  final int xp;
  final VoidCallback onTap;

  const NextPrizeCard({super.key, required this.xp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prize = Prize.nextFor(xp);
    if (prize == null) return const SizedBox.shrink();
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              TintedIcon(icon: prize.icon, accent: true),
              AppSpacing.horizontalGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prize.label, style: AppTextStyles.labelMedium),
                    Text(
                      '${formatXp(prize.xp - xp)} XP to unlock',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          AppSpacing.verticalGapMd,
          XpBar(progress: prize.progressAt(xp), from: 0),
        ],
      ),
    );
  }
}

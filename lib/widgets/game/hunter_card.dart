import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../providers/game_provider.dart';
import '../motion/pressable.dart';
import '../motion/rolling_number.dart';
import 'rank_emblem.dart';
import 'streak_chip.dart';
import 'xp_bar.dart';

class HunterCard extends ConsumerWidget {
  final VoidCallback onTap;

  const HunterCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(gameProvider.select((game) => game.xp));
    final streak = ref.watch(gameStatsProvider.select((s) => s.streak));
    final rank = Rank.forXp(xp);
    final next = rank.next;
    final muted = AppTextStyles.bodySmall.copyWith(
      color: AppColors.onPrimaryMuted,
    );
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: AppShadows.floating,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primaryLight],
          ),
        ),
        child: Row(
          children: [
            RankEmblem(rank: rank),
            AppSpacing.horizontalGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rank.label,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                      StreakChip(days: streak),
                    ],
                  ),
                  AppSpacing.verticalGapSm,
                  XpBar(progress: rank.progressAt(xp)),
                  AppSpacing.verticalGapXs,
                  Row(
                    children: [
                      RollingNumber(
                        value: xp,
                        suffix: ' XP',
                        style: muted.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        next == null
                            ? 'Top rank'
                            : '${next.threshold - xp} to ${next.label}',
                        style: muted,
                      ),
                      const Icon(
                        HugeIcons.strokeRoundedArrowRight01,
                        size: 14,
                        color: AppColors.onPrimaryMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

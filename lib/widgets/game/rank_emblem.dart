import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/game.dart';

class RankEmblem extends StatelessWidget {
  final Rank rank;
  final double size;
  final bool locked;

  const RankEmblem({
    super.key,
    required this.rank,
    this.size = 52,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: locked
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.rewardBright, AppColors.reward],
              ),
        color: locked ? AppColors.chipBackground : null,
        boxShadow: locked
            ? null
            : [
                BoxShadow(
                  color: AppColors.reward.withValues(alpha: 0.45),
                  blurRadius: size * 0.35,
                  offset: Offset(0, size * 0.08),
                ),
              ],
      ),
      child: Icon(
        rank.icon,
        size: size * 0.5,
        color: locked ? AppColors.textTertiary : AppColors.primaryDark,
      ),
    );
  }
}

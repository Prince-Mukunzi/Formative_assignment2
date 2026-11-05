import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../motion/rolling_number.dart';

class StreakChip extends StatelessWidget {
  final int days;

  const StreakChip({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final active = days > 0;
    final flame = Icon(
      HugeIcons.strokeRoundedFire,
      size: 16,
      color: active ? AppColors.streak : AppColors.onPrimaryMuted,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: active ? AppColors.streakLight : AppColors.onPrimaryFaint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active && !MediaQuery.disableAnimationsOf(context))
            flame
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.92, end: 1.12, duration: 700.ms,
                    curve: Curves.easeInOut)
          else
            flame,
          AppSpacing.horizontalGapXs,
          RollingNumber(
            value: days,
            style: AppTextStyles.labelSmall.copyWith(
              color: active ? AppColors.streak : AppColors.onPrimaryMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

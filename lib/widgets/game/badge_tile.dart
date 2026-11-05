import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';

class BadgeTile extends StatelessWidget {
  final BadgeKind badge;
  final bool earned;

  const BadgeTile({super.key, required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: earned ? AppColors.rewardLight : AppColors.chipBackground,
            border: Border.all(
              color: earned ? AppColors.reward : AppColors.cardBorder,
              width: earned ? 2 : 1,
            ),
          ),
          child: Icon(
            badge.icon,
            size: 24,
            color: earned ? AppColors.rewardDeep : AppColors.textTertiary,
          ),
        ),
        AppSpacing.verticalGapSm,
        Text(
          badge.label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: earned ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.verticalGapXs,
        Text(
          badge.hint,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

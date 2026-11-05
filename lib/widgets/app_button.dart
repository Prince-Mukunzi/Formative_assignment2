import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'motion/pressable.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isFilled;
  final bool isInverse;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isFilled = true,
    this.isInverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isFilled && !isInverse
        ? AppColors.textOnPrimary
        : AppColors.textPrimary;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: isInverse
              ? AppColors.surface
              : isFilled
              ? null
              : AppColors.chipBackground,
          gradient: isFilled && !isInverse ? AppColors.navy : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: foreground),
              AppSpacing.horizontalGapSm,
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

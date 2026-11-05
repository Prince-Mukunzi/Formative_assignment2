import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'motion/pressable.dart';
import 'tinted_icon.dart';

class MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool accent;
  final VoidCallback? onTap;

  const MenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.accent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return Pressable(
      onTap: onTap ?? () {},
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            TintedIcon(icon: icon, accent: accent),
            AppSpacing.horizontalGapMd,
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: accent ? AppColors.brand : AppColors.textPrimary,
                ),
              ),
            ),
            if (value != null) ...[
              Text(value, style: AppTextStyles.bodySmall),
              AppSpacing.horizontalGapSm,
            ],
            if (!accent)
              const Icon(
                HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

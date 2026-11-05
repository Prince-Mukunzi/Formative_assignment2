import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'motion/pressable.dart';

class ShowMoreButton extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;

  const ShowMoreButton({super.key, required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              open ? 'Show less' : 'Show more',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            AppSpacing.horizontalGapXs,
            AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: const Icon(
                HugeIcons.strokeRoundedArrowDown01,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

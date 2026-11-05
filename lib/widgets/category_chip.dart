import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.chipActiveBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected
                ? AppColors.chipActiveText
                : AppColors.chipInactiveText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

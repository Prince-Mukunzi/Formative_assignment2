import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';

class FilterTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const FilterTag({
    super.key,
    required this.label,
    this.isSelected = true,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.chipBackground : AppColors.cardBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#$label',
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
            if (onRemove != null) ...[
              AppSpacing.horizontalGapXs,
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  HugeIcons.strokeRoundedCancel01,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCreateReport;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCreateReport,
  });

  static const _items = [
    (icon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    (icon: HugeIcons.strokeRoundedTask01, label: 'Reports'),
    (icon: HugeIcons.strokeRoundedUser, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding + 10,
        top: 8,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  _NavItem(
                    icon: _items[i].icon,
                    label: _items[i].label,
                    isSelected: currentIndex == i,
                    onTap: () => onTap(i),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          _CreateButton(onTap: onCreateReport),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textTertiary,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          HugeIcons.strokeRoundedAdd01,
          size: 24,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

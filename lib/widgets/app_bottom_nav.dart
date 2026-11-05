import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'motion/pressable.dart';
import 'motion/spring_value.dart';

class AppNavItem {
  final IconData icon;
  final String label;

  const AppNavItem(this.icon, this.label);
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;
  final Widget action;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.action,
  });

  static const studentItems = [
    AppNavItem(HugeIcons.strokeRoundedHome01, 'Home'),
    AppNavItem(HugeIcons.strokeRoundedFolder01, 'My reports'),
    AppNavItem(HugeIcons.strokeRoundedUserCircle, 'Profile'),
  ];

  static const facultyItems = [
    AppNavItem(HugeIcons.strokeRoundedTask01, 'Queue'),
    AppNavItem(HugeIcons.strokeRoundedRanking, 'Board'),
    AppNavItem(HugeIcons.strokeRoundedUserCircle, 'Profile'),
  ];

  static const adminItems = [
    AppNavItem(HugeIcons.strokeRoundedDashboardSquare01, 'Overview'),
    AppNavItem(HugeIcons.strokeRoundedTask01, 'Reports'),
    AppNavItem(HugeIcons.strokeRoundedUserGroup, 'People'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding + 16,
        top: 12,
        left: 24,
        right: 24,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: AppShadows.floating,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  _NavItem(
                    icon: items[i].icon,
                    label: items[i].label,
                    isSelected: currentIndex == i,
                    onTap: () => onTap(i),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          action,
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
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: SpringValue(
        value: isSelected ? 1 : 0,
        spring: AppSprings.bouncy,
        builder: (_, t, _) {
          final clamped = t.clamp(0.0, 1.0);
          final iconColor = Color.lerp(
            AppColors.textTertiary,
            AppColors.textOnPrimary,
            clamped,
          );
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 + 2 * clamped,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              color: Color.lerp(AppColors.surface, AppColors.primary, clamped),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1 + (t - clamped) * 2,
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: t < 0 ? 0 : t,
                    heightFactor: 1,
                    child: Opacity(
                      opacity: clamped,
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: Text(
                          label,
                          maxLines: 1,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NavActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  const NavActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.88,
      child: Badge(
        isLabelVisible: badge > 0,
        label: Text('$badge'),
        backgroundColor: AppColors.brand,
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: AppShadows.floating,
          ),
          child: Icon(icon, size: 24, color: AppColors.primary),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/game.dart';

class BadgeTile extends StatelessWidget {
  final BadgeKind badge;
  final bool earned;
  final bool selected;

  const BadgeTile({
    super.key,
    required this.badge,
    required this.earned,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: earned ? AppColors.brandTint : AppColors.chipBackground,
        border: Border.all(
          color: selected
              ? (earned ? AppColors.brand : AppColors.textTertiary)
              : AppColors.heroOverlayClear,
          width: 1.5,
        ),
      ),
      child: Icon(
        badge.icon,
        size: 22,
        color: earned ? AppColors.brand : AppColors.textTertiary,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class TintedIcon extends StatelessWidget {
  final IconData icon;
  final bool accent;
  final bool muted;
  final double size;

  const TintedIcon({
    super.key,
    required this.icon,
    this.accent = false,
    this.muted = false,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final color = muted
        ? AppColors.textTertiary
        : accent
        ? AppColors.brand
        : AppColors.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent ? AppColors.brandTint : AppColors.chipBackground,
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

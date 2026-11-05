import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../motion/spring_value.dart';

class XpBar extends StatelessWidget {
  final double progress;
  final double? from;
  final double height;
  final Color trackColor;
  final Color? fillColor;

  const XpBar({
    super.key,
    required this.progress,
    this.from,
    this.height = 4,
    this.trackColor = AppColors.chipBackground,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        height: height,
        color: trackColor,
        alignment: Alignment.centerLeft,
        child: SpringValue(
          value: progress,
          from: from,
          spring: AppSprings.soft,
          builder: (_, value, child) => FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: child,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              gradient: fillColor == null ? AppColors.progress : null,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

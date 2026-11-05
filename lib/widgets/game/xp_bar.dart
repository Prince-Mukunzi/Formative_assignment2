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

  const XpBar({
    super.key,
    required this.progress,
    this.from,
    this.height = 8,
    this.trackColor = AppColors.onPrimaryFaint,
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              gradient: const LinearGradient(
                colors: [AppColors.reward, AppColors.rewardBright],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

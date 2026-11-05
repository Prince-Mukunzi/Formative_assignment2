import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_text_styles.dart';
import 'motion/spring_value.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;

  const ProgressRing({super.key, required this.progress, this.size = 76});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: SpringValue(
        value: progress,
        from: 0,
        spring: AppSprings.soft,
        builder: (_, value, child) =>
            CustomPaint(painter: _RingPainter(value), child: child),
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;

  const _RingPainter(this.value);

  static const _stroke = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      arc,
      0,
      math.pi * 2,
      false,
      paint..color = AppColors.onPrimaryFaint,
    );
    canvas.drawArc(
      arc,
      -math.pi / 2,
      math.pi * 2 * value.clamp(0.0, 1.0),
      false,
      paint..color = AppColors.textOnPrimary,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.value != value;
}

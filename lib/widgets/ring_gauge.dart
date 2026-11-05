import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import 'motion/spring_value.dart';

class RingGauge extends StatelessWidget {
  final double progress;
  final double size;

  const RingGauge({super.key, required this.progress, this.size = 136});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: SpringValue(
        value: progress,
        from: 0,
        delay: const Duration(milliseconds: 200),
        spring: AppSprings.bouncy,
        builder: (_, value, _) => CustomPaint(
          size: Size.infinite,
          painter: _RingPainter(value: value),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;

  const _RingPainter({required this.value});

  static const _start = math.pi * 0.75;
  static const _sweep = math.pi * 1.5;
  static const _strokeRatio = 0.14;
  static const _hubRatio = 0.055;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * _strokeRatio;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final arc = Rect.fromCircle(center: center, radius: radius);
    final fraction = value.clamp(0.0, 1.0);
    Paint band(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(arc, _start, _sweep, false, band(AppColors.onPrimaryFaint));
    if (fraction > 0) {
      canvas.drawArc(
        arc,
        _start,
        _sweep * fraction,
        false,
        band(AppColors.brand),
      );
    }

    final angle = _start + _sweep * fraction;
    final tip =
        center +
        Offset(math.cos(angle), math.sin(angle)) * (radius - stroke * 1.2);
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = AppColors.textOnPrimary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    final hub = size.width * _hubRatio;
    canvas.drawCircle(center, hub, Paint()..color = AppColors.textOnPrimary);
    canvas.drawCircle(
      center,
      hub * 0.4,
      Paint()..color = AppColors.primaryDark,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.value != value;
}

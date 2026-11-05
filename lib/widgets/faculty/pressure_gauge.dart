import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../motion/spring_value.dart';

class PressureGauge extends StatelessWidget {
  final int score;
  final double size;

  const PressureGauge({super.key, required this.score, this.size = 148});

  static const _trembleFrom = 75;

  @override
  Widget build(BuildContext context) {
    final trembling =
        score >= _trembleFrom && !MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: size,
      height: size * 0.58,
      child: SpringValue(
        value: score.toDouble(),
        from: 0,
        delay: const Duration(milliseconds: 200),
        spring: AppSprings.bouncy,
        builder: (_, value, _) {
          if (!trembling) return _paint(value);
          return Animate(
            onPlay: (c) => c.repeat(),
            child: const SizedBox.expand(),
          ).custom(
            duration: 900.ms,
            builder: (_, t, _) =>
                _paint(value + math.sin(t * math.pi * 2 * 5) * 1.2),
          );
        },
      ),
    );
  }

  Widget _paint(double value) => CustomPaint(
        size: Size.infinite,
        painter: _GaugePainter(value: value),
      );
}

class _GaugePainter extends CustomPainter {
  final double value;

  const _GaugePainter({required this.value});

  static const _stroke = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - _stroke / 2;
    final center = Offset(size.width / 2, size.height - _stroke / 2);
    final arc = Rect.fromCircle(center: center, radius: radius);
    final fraction = (value / 100).clamp(-0.02, 1.02);

    canvas.drawArc(
      arc,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.onPrimaryFaint,
    );
    canvas.drawArc(
      arc,
      math.pi,
      math.pi * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: math.pi,
          endAngle: math.pi * 2,
          colors: [AppColors.resolved, AppColors.reward, AppColors.overdue],
        ).createShader(arc),
    );

    final angle = math.pi + math.pi * fraction;
    final tip = center +
        Offset(math.cos(angle), math.sin(angle)) * (radius - _stroke * 1.1);
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = AppColors.textOnPrimary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 6, Paint()..color = AppColors.textOnPrimary);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.value != value;
}

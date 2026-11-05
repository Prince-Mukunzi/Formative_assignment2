import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import 'spring_value.dart';

class RollingNumber extends StatelessWidget {
  final int value;
  final int? from;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Duration delay;

  const RollingNumber({
    super.key,
    required this.value,
    required this.style,
    this.from,
    this.prefix = '',
    this.suffix = '',
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final tabular = style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return SpringValue(
      value: value.toDouble(),
      from: from?.toDouble(),
      delay: delay,
      spring: AppSprings.soft,
      builder: (context, animated, _) {
        final current = math.max(animated, 0.0);
        final digits = math.max(value, current.ceil()).toString().length;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefix.isNotEmpty) Text(prefix, style: tabular),
            for (var place = digits - 1; place >= 0; place--)
              _Digit(value: current, place: place, style: tabular),
            if (suffix.isNotEmpty) Text(suffix, style: tabular),
          ],
        );
      },
    );
  }
}

class _Digit extends StatelessWidget {
  final double value;
  final int place;
  final TextStyle style;

  const _Digit({required this.value, required this.place, required this.style});

  @override
  Widget build(BuildContext context) {
    final unit = math.pow(10, place).toDouble();
    final whole = (value / unit).floor();
    // Higher columns only move during the final unit of the column below,
    // the way mechanical odometer wheels carry.
    final carry = ((value % unit) - (unit - 1)).clamp(0.0, 1.0);
    final shift = place == 0 ? value - value.floorToDouble() : carry;
    return ClipRect(
      child: Stack(
        children: [
          Opacity(opacity: 0, child: Text('0', style: style)),
          FractionalTranslation(
            translation: Offset(0, -shift),
            child: Text('${whole % 10}', style: style),
          ),
          FractionalTranslation(
            translation: Offset(0, 1 - shift),
            child: Text('${(whole + 1) % 10}', style: style),
          ),
        ],
      ),
    );
  }
}

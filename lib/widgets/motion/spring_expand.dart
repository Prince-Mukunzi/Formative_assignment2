import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import 'spring_value.dart';

class SpringExpand extends StatelessWidget {
  final bool open;
  final Widget child;

  const SpringExpand({super.key, required this.open, required this.child});

  @override
  Widget build(BuildContext context) {
    return SpringValue(
      value: open ? 1 : 0,
      spring: AppSprings.snappy,
      builder: (_, t, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: math.max(t, 0),
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
        ),
      ),
      child: child,
    );
  }
}

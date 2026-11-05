import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import 'spring_value.dart';

class SpringIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;
  final double fromScale;
  final SpringDescription spring;

  const SpringIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 24,
    this.fromScale = 1,
    this.spring = AppSprings.snappy,
  });

  @override
  Widget build(BuildContext context) {
    return SpringValue(
      value: 1,
      from: 0,
      delay: delay,
      spring: spring,
      child: child,
      builder: (_, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * offsetY),
          child: Transform.scale(
            scale: fromScale + (1 - fromScale) * t,
            child: child,
          ),
        ),
      ),
    );
  }
}

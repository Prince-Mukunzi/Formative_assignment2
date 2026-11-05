import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/app_motion.dart';
import '../../core/utils/app_motion_prefs.dart';

/// A spring at rest that can be struck: [kick] adds velocity and the value
/// overshoots and settles back on its own, like tapping a real object.
class KickController extends AnimationController {
  final double rest;
  final SpringDescription spring;

  KickController({
    required super.vsync,
    this.rest = 0,
    this.spring = AppSprings.bouncy,
  }) : super.unbounded(value: rest);

  void kick(double velocity) {
    if (AppMotionPrefs.reduced) return;
    animateWith(
      SpringSimulation(
        spring,
        value,
        rest,
        this.velocity + velocity,
        tolerance: AppSprings.tolerance,
      ),
    );
  }
}

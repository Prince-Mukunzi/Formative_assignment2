import 'package:flutter/physics.dart';

abstract final class AppSprings {
  static const press = SpringDescription(mass: 1, stiffness: 700, damping: 32);
  static const snappy = SpringDescription(mass: 1, stiffness: 420, damping: 26);
  static const bouncy = SpringDescription(mass: 1, stiffness: 320, damping: 15);
  static const soft = SpringDescription(mass: 1, stiffness: 120, damping: 17);
  static const slam = SpringDescription(mass: 1, stiffness: 520, damping: 13);

  static const tolerance = Tolerance(distance: 0.001, velocity: 0.01);
  static const pixelTolerance = Tolerance(distance: 0.5, velocity: 5);
}

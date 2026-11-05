import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // Base spacing values
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Screen padding
  static const screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const screenPaddingVertical = EdgeInsets.symmetric(vertical: 16);
  static const screenAll = EdgeInsets.all(20);

  // Card padding
  static const cardPadding = EdgeInsets.all(16);
  static const cardPaddingSmall = EdgeInsets.all(12);

  // Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 100;

  // Gaps (for use in Row/Column)
  static const verticalGapXs = SizedBox(height: xs);
  static const verticalGapSm = SizedBox(height: sm);
  static const verticalGapMd = SizedBox(height: md);
  static const verticalGapLg = SizedBox(height: lg);
  static const verticalGapXl = SizedBox(height: xl);
  static const verticalGapXxl = SizedBox(height: xxl);

  static const horizontalGapXs = SizedBox(width: xs);
  static const horizontalGapSm = SizedBox(width: sm);
  static const horizontalGapMd = SizedBox(width: md);
  static const horizontalGapLg = SizedBox(width: lg);
  static const horizontalGapXl = SizedBox(width: xl);
}

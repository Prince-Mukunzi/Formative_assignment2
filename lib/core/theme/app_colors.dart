import 'package:flutter/material.dart';

/// Four colours only: navy, crimson, black, white. Every other tone is one of
/// those at an opacity, or a gradient between them.
abstract final class AppColors {
  static const primary = Color(0xFF002E6D);
  static const primaryDark = Color(0xFF001D45);

  // 5.5:1 on white but only 2.3:1 on navy, so text in this colour stays on
  // white surfaces.
  static const brand = Color(0xFFD00E2C);
  static const brandTint = Color(0x14D00E2C);

  static const background = Color(0xFFF6F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const cardBorder = Color(0x14000000);
  static const divider = Color(0x0D000000);

  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0x8C000000);
  static const textTertiary = Color(0x59000000);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const chipBackground = Color(0x0D002E6D);
  static const chipActiveBackground = primary;
  static const chipActiveText = textOnPrimary;
  static const chipInactiveText = textSecondary;

  static const onPrimaryMuted = Color(0xB3FFFFFF);
  static const onPrimaryFaint = Color(0x33FFFFFF);
  static const onPrimaryWash = Color(0x14FFFFFF);
  static const heroOverlay = Color(0x66000000);
  static const heroOverlayClear = Color(0x00000000);

  static const confetti = [surface, onPrimaryMuted];
  static const confettiOnLight = [brand, primary];

  static const shadow = Color(0x0A000000);
  static const shadowMedium = Color(0x14000000);

  static const signature = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, primaryDark],
  );
  static const navy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  static const progress = LinearGradient(colors: [primary, brand]);
}

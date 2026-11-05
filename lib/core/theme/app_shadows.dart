import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x0F101828),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A101828),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const floating = [
    BoxShadow(
      color: Color(0x1A101828),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}

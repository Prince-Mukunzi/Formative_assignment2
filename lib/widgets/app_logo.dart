import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final bool onDark;
  final double height;

  const AppLogo({super.key, this.onDark = false, this.height = 30});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      onDark
          ? 'assets/images/alu_logo_white.png'
          : 'assets/images/alu_logo_color.png',
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      semanticLabel: 'African Leadership University',
    );
  }
}

import 'package:flutter/material.dart';

/// An icon that sits inline with label text. Icon fonts thin out at this size,
/// so the glyph gets a hairline outline to match the weight of the letters.
class LabelIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const LabelIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 14,
  });

  static const _outline = 0.35;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(icon, size: size, color: color),
        ExcludeSemantics(
          child: Text(
            String.fromCharCode(icon.codePoint),
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              inherit: false,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              fontSize: size,
              height: 1,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = _outline
                ..color = color,
            ),
          ),
        ),
      ],
    );
  }
}

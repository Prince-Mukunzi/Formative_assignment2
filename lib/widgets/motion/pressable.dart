import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_motion.dart';
import 'spring_value.dart';

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.96,
    this.haptic = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  // Quick taps deliver down and up in the same frame; holding the pressed
  // state briefly keeps the squish visible.
  static const _minimumPress = Duration(milliseconds: 70);

  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (mounted && _pressed != pressed) setState(() => _pressed = pressed);
  }

  void _handleTap() {
    if (widget.haptic) HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled
          ? (_) => Future.delayed(_minimumPress, () => _setPressed(false))
          : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: enabled ? _handleTap : null,
      child: SpringValue(
        value: _pressed ? widget.scale : 1,
        spring: _pressed ? AppSprings.press : AppSprings.bouncy,
        builder: (_, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: widget.child,
      ),
    );
  }
}

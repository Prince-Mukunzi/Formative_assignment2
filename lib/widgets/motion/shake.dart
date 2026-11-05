import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'kick_controller.dart';

/// Horizontal rejection shake. Each change of [trigger] strikes the spring.
class Shake extends StatefulWidget {
  final int trigger;
  final Widget child;

  const Shake({super.key, required this.trigger, required this.child});

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final _kick = KickController(vsync: this);

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      _kick.kick(math.Random().nextBool() ? 520 : -520);
    }
  }

  @override
  void dispose() {
    _kick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _kick,
      child: widget.child,
      builder: (_, child) =>
          Transform.translate(offset: Offset(_kick.value, 0), child: child),
    );
  }
}

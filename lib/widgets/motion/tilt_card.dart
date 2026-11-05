import 'package:flutter/material.dart';
import '../../core/theme/app_motion.dart';
import 'spring_value.dart';

/// Leans toward the finger in 3D while pressed, then springs back flat.
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;

  const TiltCard({super.key, required this.child, this.maxTilt = 0.14});

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  static const _perspective = 0.0012;

  Offset _tilt = Offset.zero;
  bool _down = false;

  void _track(PointerEvent event) {
    final size = context.size;
    if (size == null || size.isEmpty) return;
    final nx = (event.localPosition.dx / size.width * 2 - 1).clamp(-1.0, 1.0);
    final ny = (event.localPosition.dy / size.height * 2 - 1).clamp(-1.0, 1.0);
    setState(() {
      _down = true;
      _tilt = Offset(nx, ny);
    });
  }

  void _release(PointerEvent _) {
    setState(() {
      _down = false;
      _tilt = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spring = _down ? AppSprings.snappy : AppSprings.bouncy;
    return Listener(
      onPointerDown: _track,
      onPointerMove: _track,
      onPointerUp: _release,
      onPointerCancel: _release,
      child: SpringValue(
        value: _tilt.dx,
        spring: spring,
        builder: (_, x, child) => SpringValue(
          value: _tilt.dy,
          spring: spring,
          builder: (_, y, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, _perspective)
              ..rotateY(x * widget.maxTilt)
              ..rotateX(-y * widget.maxTilt),
            child: child,
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

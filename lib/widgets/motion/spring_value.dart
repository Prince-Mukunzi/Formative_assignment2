import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../core/theme/app_motion.dart';

/// Implicit spring animation. Retargeting keeps the current velocity, so
/// interrupted motion stays continuous instead of restarting from rest.
class SpringValue extends StatefulWidget {
  final double value;
  final double? from;
  final SpringDescription spring;
  final Duration delay;
  final Widget Function(BuildContext context, double value, Widget? child)
      builder;
  final Widget? child;

  const SpringValue({
    super.key,
    required this.value,
    required this.builder,
    this.from,
    this.spring = AppSprings.snappy,
    this.delay = Duration.zero,
    this.child,
  });

  @override
  State<SpringValue> createState() => _SpringValueState();
}

class _SpringValueState extends State<SpringValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.from ?? widget.value,
  );

  bool _entered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entered) return;
    _entered = true;
    if (widget.from != null) Future.delayed(widget.delay, _animate);
  }

  @override
  void didUpdateWidget(SpringValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _animate();
  }

  void _animate() {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.value;
      return;
    }
    _controller.animateWith(SpringSimulation(
      widget.spring,
      _controller.value,
      widget.value,
      _controller.velocity,
      tolerance: AppSprings.tolerance,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) =>
          widget.builder(context, _controller.value, child),
    );
  }
}

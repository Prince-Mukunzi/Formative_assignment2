import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/app_colors.dart';

enum ConfettiStyle {
  /// Wide, gravity-driven celebration that drifts off screen.
  party(
    count: 90,
    speed: 950,
    gravity: 1100,
    drag: 1.5,
    lifetime: 2.8,
    size: 9,
  ),

  /// Tight radial spark for small actions.
  spark(count: 14, speed: 300, gravity: 240, drag: 5, lifetime: 0.6, size: 4);

  const ConfettiStyle({
    required this.count,
    required this.speed,
    required this.gravity,
    required this.drag,
    required this.lifetime,
    required this.size,
  });

  final int count;
  final double speed;
  final double gravity;
  final double drag;
  final double lifetime;
  final double size;
}

abstract final class Confetti {
  static void burst(
    BuildContext context, {
    required Offset origin,
    ConfettiStyle style = ConfettiStyle.party,
    List<Color> colors = AppColors.confetti,
  }) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ConfettiLayer(
        origin: origin,
        style: style,
        colors: colors,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  static Offset centerOf(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Offset.zero;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}

class _Particle {
  Offset position;
  Offset velocity;
  double rotation;
  final double spin;
  final double size;
  final Color color;
  final bool isDot;
  final double wobblePhase;

  _Particle({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.spin,
    required this.size,
    required this.color,
    required this.isDot,
    required this.wobblePhase,
  });
}

class _ConfettiLayer extends StatefulWidget {
  final Offset origin;
  final ConfettiStyle style;
  final List<Color> colors;
  final VoidCallback onDone;

  const _ConfettiLayer({
    required this.origin,
    required this.style,
    required this.colors,
    required this.onDone,
  });

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer>
    with SingleTickerProviderStateMixin {
  final _frame = ValueNotifier<double>(0);
  late final Ticker _ticker;
  late final List<_Particle> _particles;
  Duration _last = Duration.zero;
  double _age = 0;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    final style = widget.style;
    _particles = List.generate(style.count, (_) {
      final isParty = style == ConfettiStyle.party;
      final angle = isParty
          ? -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 0.95
          : random.nextDouble() * math.pi * 2;
      final speed = style.speed * (0.45 + random.nextDouble() * 0.75);
      return _Particle(
        position: widget.origin,
        velocity: Offset(math.cos(angle), math.sin(angle)) * speed,
        rotation: random.nextDouble() * math.pi,
        spin: (random.nextDouble() - 0.5) * 14,
        size: style.size * (0.6 + random.nextDouble() * 0.8),
        color: widget.colors[random.nextInt(widget.colors.length)],
        isDot: random.nextDouble() < 0.3,
        wobblePhase: random.nextDouble() * math.pi * 2,
      );
    });
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    // Clamping dt keeps a dropped frame from teleporting the particles.
    final dt = math.min((elapsed - _last).inMicroseconds / 1e6, 1 / 30);
    _last = elapsed;
    _age += dt;
    final style = widget.style;
    for (final p in _particles) {
      final decay = math.exp(-style.drag * dt);
      final sway = math.sin(_age * 7 + p.wobblePhase) * 40;
      p.velocity = Offset(
        p.velocity.dx * decay + sway * dt,
        p.velocity.dy * decay + style.gravity * dt,
      );
      p.position += p.velocity * dt;
      p.rotation += p.spin * dt;
    }
    if (_age >= style.lifetime) {
      _ticker.stop();
      widget.onDone();
      return;
    }
    _frame.value = _age;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            particles: _particles,
            age: _frame,
            lifetime: widget.style.lifetime,
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final ValueNotifier<double> age;
  final double lifetime;

  _ConfettiPainter({
    required this.particles,
    required this.age,
    required this.lifetime,
  }) : super(repaint: age);

  @override
  void paint(Canvas canvas, Size size) {
    final remaining = 1 - age.value / lifetime;
    final opacity = (remaining * 3).clamp(0.0, 1.0);
    final paint = Paint();
    for (final p in particles) {
      paint.color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.rotation);
      if (p.isDot) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        // Scaling by the spin angle fakes a paper strip tumbling in 3D.
        final flip = math.cos(p.rotation * 2).abs() * 0.8 + 0.2;
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.55 * flip,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}

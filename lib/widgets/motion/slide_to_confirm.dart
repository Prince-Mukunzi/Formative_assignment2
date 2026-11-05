import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class SlideToConfirm extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onConfirmed;

  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.color = AppColors.primary,
  });

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm>
    with SingleTickerProviderStateMixin {
  static const _height = 64.0;
  static const _inset = 6.0;
  static const _thumb = _height - _inset * 2;
  static const _commitFraction = 0.78;
  static const _flingVelocity = 900.0;
  static const _detents = 4;

  late final AnimationController _x = AnimationController.unbounded(
    vsync: this,
  );
  double _travel = 1;
  int _lastDetent = 0;
  bool _confirmed = false;

  double get _progress => (_x.value / _travel).clamp(0.0, 1.0);

  void _onDragUpdate(DragUpdateDetails details) {
    if (_confirmed) return;
    _x.stop();
    final next = _x.value + details.delta.dx;
    // Past either end the thumb resists like a rubber band.
    _x.value = next < 0
        ? next * 0.3
        : next > _travel
        ? _travel + (next - _travel) * 0.3
        : next;
    final detent = (_progress * _detents).floor();
    if (detent != _lastDetent) {
      _lastDetent = detent;
      HapticFeedback.selectionClick();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_confirmed) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final commits = _progress >= _commitFraction || velocity > _flingVelocity;
    if (commits) {
      _confirm(velocity);
    } else {
      _lastDetent = 0;
      _springTo(0, velocity, AppSprings.bouncy);
    }
  }

  void _confirm(double velocity) {
    setState(() => _confirmed = true);
    HapticFeedback.heavyImpact();
    _springTo(_travel, velocity, AppSprings.snappy).whenComplete(() {
      if (mounted) widget.onConfirmed();
    });
  }

  TickerFuture _springTo(
    double target,
    double velocity,
    SpringDescription spring,
  ) {
    return _x.animateWith(
      SpringSimulation(
        spring,
        _x.value,
        target,
        velocity,
        tolerance: AppSprings.pixelTolerance,
      ),
    );
  }

  @override
  void dispose() {
    _x.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _travel = constraints.maxWidth - _thumb - _inset * 2;
        return GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: AnimatedBuilder(
            animation: _x,
            builder: (context, _) => _buildTrack(),
          ),
        );
      },
    );
  }

  Widget _buildTrack() {
    final progress = _progress;
    final fillWidth = _x.value.clamp(0.0, _travel + 1) + _thumb + _inset * 2;
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: Color.lerp(
          AppColors.chipBackground,
          widget.color.withValues(alpha: 0.18),
          progress,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: fillWidth,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.28 + progress * 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          Center(
            child: Opacity(
              opacity: (1 - progress * 1.6).clamp(0.0, 1.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.horizontalGapSm,
                  const Icon(
                    HugeIcons.strokeRoundedArrowRightDouble,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(_inset + _x.value, 0),
            child: _buildThumb(progress),
          ),
        ],
      ),
    );
  }

  Widget _buildThumb(double progress) {
    return Transform.scale(
      scale: 1 + progress * 0.04,
      child: Container(
        width: _thumb,
        height: _thumb,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.45),
              blurRadius: 12 + progress * 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Icon(
            _confirmed
                ? HugeIcons.strokeRoundedTick02
                : HugeIcons.strokeRoundedArrowRight01,
            key: ValueKey(_confirmed),
            size: 24,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}

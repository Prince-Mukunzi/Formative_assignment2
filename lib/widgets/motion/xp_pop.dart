import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'spring_value.dart';

/// Small "+2 XP" token that springs up from the point of the action.
abstract final class XpPop {
  static void show(
    BuildContext context, {
    required Offset origin,
    required int xp,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _XpPopToken(
        origin: origin,
        xp: xp,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _XpPopToken extends StatefulWidget {
  final Offset origin;
  final int xp;
  final VoidCallback onDone;

  const _XpPopToken({
    required this.origin,
    required this.xp,
    required this.onDone,
  });

  @override
  State<_XpPopToken> createState() => _XpPopTokenState();
}

class _XpPopTokenState extends State<_XpPopToken> {
  static const _hold = Duration(milliseconds: 620);
  static const _rise = 56.0;

  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_hold, () {
      if (mounted) setState(() => _leaving = true);
    });
    Future.delayed(_hold * 1.4, widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.origin.dx,
      top: widget.origin.dy,
      child: IgnorePointer(
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: SpringValue(
            value: _leaving ? 2 : 1,
            from: 0,
            spring: _leaving ? AppSprings.soft : AppSprings.bouncy,
            builder: (_, t, child) => Transform.translate(
              offset: Offset(0, -_rise * t),
              child: Opacity(
                opacity: t <= 1 ? t.clamp(0.0, 1.0) : (2 - t).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: t <= 1 ? t.clamp(0.0, 1.3) : 1,
                  child: child,
                ),
              ),
            ),
            child: Material(
              color: AppColors.heroOverlayClear,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs + 1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.reward,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      HugeIcons.strokeRoundedStar,
                      size: 12,
                      color: AppColors.primaryDark,
                    ),
                    AppSpacing.horizontalGapXs,
                    Text(
                      '+${widget.xp} XP',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

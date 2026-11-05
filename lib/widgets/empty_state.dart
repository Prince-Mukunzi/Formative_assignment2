import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/app_motion_prefs.dart';
import '../providers/sync_provider.dart';
import 'app_button.dart';
import 'motion/spring_in.dart';

typedef EmptyAction = ({String label, IconData icon, VoidCallback onTap});

/// A friendly stand-in for an empty list that points at the next move.
/// Stays blank until the first sync lands so it never flashes on launch.
class EmptyState extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String message;
  final EmptyAction? action;
  final bool accent;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(dataReadyProvider)) return const SizedBox.shrink();
    final action = this.action;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpringIn(
            spring: AppSprings.bouncy,
            fromScale: 0.6,
            offsetY: 0,
            child: _Beacon(icon: icon, accent: accent),
          ),
          AppSpacing.verticalGapXl,
          SpringIn(
            delay: const Duration(milliseconds: 80),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2,
            ),
          ),
          AppSpacing.verticalGapSm,
          SpringIn(
            delay: const Duration(milliseconds: 140),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (action != null) ...[
            AppSpacing.verticalGapXl,
            SpringIn(
              delay: const Duration(milliseconds: 200),
              child: AppButton(
                label: action.label,
                icon: action.icon,
                onTap: action.onTap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Beacon extends StatefulWidget {
  final IconData icon;
  final bool accent;

  const _Beacon({required this.icon, required this.accent});

  @override
  State<_Beacon> createState() => _BeaconState();
}

class _BeaconState extends State<_Beacon> with SingleTickerProviderStateMixin {
  static const _size = 96.0;

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (!AppMotionPrefs.reduced) _loop.repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = widget.accent ? AppColors.brand : AppColors.primary;
    final wash = widget.accent ? AppColors.brandTint : AppColors.chipBackground;
    return SizedBox.square(
      dimension: _size * 1.6,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (_, _) {
          final t = _loop.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              for (final phase in const [0.0, 0.5])
                _ripple((t + phase) % 1, ink),
              Transform.translate(
                offset: Offset(0, math.sin(t * 2 * math.pi) * 5),
                child: Transform.rotate(
                  angle: math.sin(t * 4 * math.pi) * 0.06,
                  child: Container(
                    width: _size,
                    height: _size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: wash,
                    ),
                    child: Icon(widget.icon, size: 40, color: ink),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ripple(double t, Color ink) {
    if (AppMotionPrefs.reduced) return const SizedBox.shrink();
    return Container(
      width: _size * (1 + t * 0.6),
      height: _size * (1 + t * 0.6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ink.withValues(alpha: (1 - t) * 0.18),
          width: 2,
        ),
      ),
    );
  }
}

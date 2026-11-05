import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'motion/pressable.dart';

class GradientBanner extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final VoidCallback? onTap;

  const GradientBanner({
    super.key,
    required this.child,
    this.gradient = AppColors.signature,
    this.onTap,
  });

  static const _orbSize = 160.0;

  @override
  Widget build(BuildContext context) {
    final banner = ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            const Positioned(
              top: -_orbSize / 2,
              right: -_orbSize / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.onPrimaryWash,
                ),
                child: SizedBox.square(dimension: _orbSize),
              ),
            ),
            Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: child),
          ],
        ),
      ),
    );
    final onTap = this.onTap;
    if (onTap == null) return banner;
    return Pressable(onTap: onTap, scale: 0.98, child: banner);
  }
}

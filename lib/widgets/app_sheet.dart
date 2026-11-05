import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/app_motion_prefs.dart';
import 'tinted_icon.dart';

/// Every bottom sheet rises and settles with the same motion.
abstract final class AppSheet {
  static const _rise = AnimationStyle(
    duration: Duration(milliseconds: 420),
    reverseDuration: Duration(milliseconds: 240),
    curve: Curves.easeOutQuart,
  );

  static AnimationStyle get animation =>
      AppMotionPrefs.reduced ? AnimationStyle.noAnimation : _rise;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      sheetAnimationStyle: animation,
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      TintedIcon(icon: icon),
                      AppSpacing.horizontalGapMd,
                    ],
                    Expanded(
                      child: Text(title, style: AppTextStyles.heading2),
                    ),
                  ],
                ),
                AppSpacing.verticalGapLg,
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

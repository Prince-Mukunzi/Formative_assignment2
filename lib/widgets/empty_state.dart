import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/sync_provider.dart';
import 'app_button.dart';
import 'motion/spring_in.dart';
import 'tinted_icon.dart';

typedef EmptyAction = ({String label, IconData icon, VoidCallback onTap});

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
    return SpringIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TintedIcon(icon: icon, accent: accent, size: 64),
            AppSpacing.verticalGapLg,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2,
            ),
            AppSpacing.verticalGapSm,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (action != null) ...[
              AppSpacing.verticalGapXl,
              AppButton(
                label: action.label,
                icon: action.icon,
                onTap: action.onTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

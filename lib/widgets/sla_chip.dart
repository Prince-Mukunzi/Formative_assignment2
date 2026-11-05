import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/report.dart';
import '../models/sla.dart';
import '../providers/clock_provider.dart';

class SlaChip extends ConsumerWidget {
  final Report report;

  const SlaChip({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider);
    final state = report.slaStateAt(now);
    final left = report.timeLeftAt(now);
    if (state == null || left == null) return const SizedBox.shrink();

    final (Color background, Color foreground) = switch (state) {
      SlaState.calm => (AppColors.surface, AppColors.textSecondary),
      SlaState.warning => (AppColors.inProgressLight, AppColors.rewardDeep),
      SlaState.critical => (AppColors.overdueLight, AppColors.overdue),
      SlaState.overdue => (AppColors.overdue, AppColors.textOnPrimary),
    };
    final text = state == SlaState.overdue
        ? '${formatSlaDuration(left)} overdue'
        : '${formatSlaDuration(left)} left';

    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(HugeIcons.strokeRoundedTimer02, size: 12, color: foreground),
          const SizedBox(width: 3),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: foreground,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    final urgent = state == SlaState.critical || state == SlaState.overdue;
    if (!urgent || MediaQuery.disableAnimationsOf(context)) return chip;
    return chip.animate(onPlay: (c) => c.repeat()).custom(
          duration: 1100.ms,
          builder: (_, t, child) {
            // Two quick beats then rest, a heartbeat rather than a sine pulse.
            final beat = t < 0.14
                ? t / 0.14
                : t < 0.28
                    ? 1 - (t - 0.14) / 0.14
                    : t < 0.42
                        ? (t - 0.28) / 0.14 * 0.6
                        : t < 0.56
                            ? 0.6 - (t - 0.42) / 0.14 * 0.6
                            : 0.0;
            return Transform.scale(scale: 1 + beat * 0.08, child: child);
          },
        );
  }
}

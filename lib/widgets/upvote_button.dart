import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/report.dart';
import '../models/session.dart';
import '../providers/reports_provider.dart';
import '../providers/session_provider.dart';
import 'motion/confetti.dart';
import 'motion/kick_controller.dart';
import 'motion/pressable.dart';
import 'motion/rolling_number.dart';
import 'motion/xp_pop.dart';

class UpvoteButton extends ConsumerStatefulWidget {
  final Report report;
  final bool expanded;

  const UpvoteButton({super.key, required this.report, this.expanded = false});

  @override
  ConsumerState<UpvoteButton> createState() => _UpvoteButtonState();
}

class _UpvoteButtonState extends ConsumerState<UpvoteButton>
    with SingleTickerProviderStateMixin {
  late final _scale = KickController(vsync: this, rest: 1);

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  void _toggle(BuildContext buttonContext) {
    final report = widget.report;
    final xp = ref.read(reportsProvider.notifier).toggleUpvote(report.id);
    if (report.hasUpvoted) {
      _scale.kick(-3);
      return;
    }
    _scale.kick(11);
    HapticFeedback.mediumImpact();
    final origin = Confetti.centerOf(buttonContext);
    Confetti.burst(
      buttonContext,
      origin: origin,
      style: ConfettiStyle.spark,
      colors: AppColors.confettiOnLight,
    );
    if (xp > 0) XpPop.show(buttonContext, origin: origin, xp: xp);
  }

  Widget _buildIcon(Color color, double size) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.rotate(
        angle: (_scale.value - 1) * -0.5,
        child: Transform.scale(scale: _scale.value, child: child),
      ),
      child: Icon(HugeIcons.strokeRoundedThumbsUp, size: size, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFaculty = ref.watch(sessionProvider) is FacultySession;
    final report = widget.report;
    return Builder(
      builder: (buttonContext) {
        final onTap = isFaculty ? null : () => _toggle(buttonContext);
        return widget.expanded
            ? _buildExpanded(onTap)
            : _buildCompact(onTap, report);
      },
    );
  }

  Widget _buildCompact(VoidCallback? onTap, Report report) {
    final active = report.hasUpvoted;
    return Pressable(
      onTap: onTap,
      haptic: false,
      scale: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(active ? AppColors.brand : AppColors.textSecondary, 18),
            AppSpacing.horizontalGapXs,
            RollingNumber(
              value: report.upvotes,
              style: AppTextStyles.labelMedium.copyWith(
                color: active ? AppColors.brand : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(VoidCallback? onTap) {
    final report = widget.report;
    final active = report.hasUpvoted;
    final foreground = active ? AppColors.textOnPrimary : AppColors.textPrimary;
    return Pressable(
      onTap: onTap,
      haptic: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: active ? AppColors.brand : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(foreground, 20),
            AppSpacing.horizontalGapSm,
            Text(
              'Upvote  ',
              style: AppTextStyles.labelMedium.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            RollingNumber(
              value: report.upvotes,
              style: AppTextStyles.labelMedium.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../motion/spring_value.dart';

/// The student's reason to come back: which payouts a report has hit, and
/// which one it is waiting on.
class BountyTrack extends StatelessWidget {
  final Report report;

  const BountyTrack({super.key, required this.report});

  static const _steps = [
    (label: 'Filed', reason: XpReason.reportFiled),
    (label: 'Approved', reason: XpReason.reportApproved),
    (label: 'Fixed', reason: XpReason.reportResolved),
    (label: 'Checked', reason: XpReason.fixChecked),
  ];

  int get _completed => switch (report.status) {
        ReportStatus.awaitingApproval => 1,
        ReportStatus.inProgress => 2,
        ReportStatus.resolved => report.verifiedAt == null ? 3 : 4,
        ReportStatus.declined => 1,
      };

  @override
  Widget build(BuildContext context) {
    if (report.status == ReportStatus.declined) {
      return Text(
        'Faculty declined this report.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      );
    }
    final completed = _completed;
    return Column(
      children: [
        SizedBox(
          height: 26,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: SpringValue(
                  value: (completed - 1) / (_steps.length - 1),
                  from: 0,
                  spring: AppSprings.soft,
                  builder: (_, value, _) => LinearProgressIndicator(
                    value: value.clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor: AppColors.cardBorder,
                    color: AppColors.reward,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    SizedBox(
                      width: 52,
                      child: Center(
                        child: _Node(
                          done: i < completed,
                          isNext: i == completed,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.verticalGapXs,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _steps.length; i++)
              SizedBox(
                width: 52,
                child: Column(
                  children: [
                    Text(
                      _steps[i].label,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: i < completed
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      '+${_steps[i].reason.xp}',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: i < completed
                            ? AppColors.rewardDeep
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  final bool done;
  final bool isNext;

  const _Node({required this.done, required this.isNext});

  @override
  Widget build(BuildContext context) {
    final node = SpringValue(
      value: done ? 1 : 0,
      spring: AppSprings.slam,
      builder: (_, t, _) => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            AppColors.surface,
            AppColors.reward,
            t.clamp(0.0, 1.0),
          ),
          border: Border.all(
            color: isNext ? AppColors.reward : AppColors.cardBorder,
            width: done ? 0 : 2,
          ),
        ),
        child: Transform.scale(
          scale: t.clamp(0.0, 1.4),
          child: const Icon(
            HugeIcons.strokeRoundedTick02,
            size: 13,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
    if (!isNext || MediaQuery.disableAnimationsOf(context)) return node;
    return node
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1, end: 1.18, duration: 800.ms, curve: Curves.easeInOut);
  }
}

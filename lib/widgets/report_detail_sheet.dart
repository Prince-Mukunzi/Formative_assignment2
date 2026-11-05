import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/mock_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/game.dart';
import '../models/report.dart';
import '../models/report_status.dart';
import '../models/session.dart';
import '../models/sla.dart';
import '../providers/clock_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/session_provider.dart';
import 'app_button.dart';
import 'game/bounty_track.dart';
import 'motion/confetti.dart';
import 'motion/pressable.dart';
import 'motion/slide_to_confirm.dart';
import 'motion/xp_pop.dart';
import 'report_image.dart';
import 'sla_chip.dart';
import 'status_badge.dart';
import 'upvote_button.dart';

class ReportDetailSheet extends ConsumerWidget {
  final String reportId;

  const ReportDetailSheet({super.key, required this.reportId});

  static void show(BuildContext context, Report report) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.heroOverlayClear,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 420),
        reverseDuration: Duration(milliseconds: 240),
        curve: Curves.easeOutQuart,
      ),
      builder: (_) => ReportDetailSheet(reportId: report.id),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(reportByIdProvider(reportId));
    final session = ref.watch(sessionProvider);
    final isFaculty = session is FacultySession;
    final isMine = report.reportedBy == MockData.currentStudentId;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXxl),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Hero(report: report),
                  _Body(report: report, isFaculty: isFaculty, isMine: isMine),
                ],
              ),
            ),
          ),
          _ActionBar(
            child: isFaculty
                ? _FacultyActions(report: report)
                : _StudentActions(report: report, isMine: isMine),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final Report report;

  const _Hero({required this.report});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ReportImage(report: report),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [AppColors.heroOverlay, AppColors.heroOverlayClear],
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.xl,
            child: Row(
              children: [
                StatusBadge(status: report.status),
                AppSpacing.horizontalGapSm,
                SlaChip(report: report),
              ],
            ),
          ),
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.lg,
            child: Pressable(
              onTap: () => Navigator.of(context).pop(),
              scale: 0.85,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedCancel01,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _Body extends StatelessWidget {
  final Report report;
  final bool isFaculty;
  final bool isMine;

  const _Body({
    required this.report,
    required this.isFaculty,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(report.category.icon, size: 16, color: AppColors.accent),
                  AppSpacing.horizontalGapXs,
                  Text(
                    report.category.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.horizontalGapSm,
                  Text(
                    timeago.format(report.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalGapSm,
              Text(report.title, style: AppTextStyles.heading2),
              AppSpacing.verticalGapMd,
              Text(
                report.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              if (isFaculty) ...[
                AppSpacing.verticalGapXl,
                _ImpactPanel(report: report),
              ] else if (isMine) ...[
                AppSpacing.verticalGapXl,
                Text('BOUNTY TRACK', style: AppTextStyles.overline),
                AppSpacing.verticalGapMd,
                BountyTrack(report: report),
              ],
              if (report.isOpen) ...[
                AppSpacing.verticalGapXl,
                _ClockPanel(report: report, isFaculty: isFaculty),
              ],
              AppSpacing.verticalGapXl,
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: HugeIcons.strokeRoundedLocation01,
                      label: 'Location',
                      value: report.location,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1, color: AppColors.divider),
                    ),
                    _InfoRow(
                      icon: HugeIcons.strokeRoundedUserCircle,
                      label: 'Reported by',
                      value: report.reportedByName,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.03, end: 0, duration: 300.ms);
  }
}

class _ClockPanel extends ConsumerWidget {
  final Report report;
  final bool isFaculty;

  const _ClockPanel({required this.report, required this.isFaculty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider);
    final overdue = report.slaStateAt(now) == SlaState.overdue;
    final left = report.timeLeftAt(now) ?? Duration.zero;
    final headline = overdue
        ? '${formatSlaDuration(left)} past deadline'
        : '${formatSlaDuration(left)} until deadline';
    final copy = isFaculty
        ? overdue
              ? 'Students can see this report is late on the campus scoreboard.'
              : 'Every upvote takes ${SlaPolicy.upvoteCut.inMinutes} minutes off '
                    'this clock and every nudge takes '
                    '${SlaPolicy.nudgeCut.inHours} hour.'
        : 'Your upvote takes ${SlaPolicy.upvoteCut.inMinutes} minutes off this '
              'deadline. The more students back it, the faster it has to move.';
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: overdue ? AppColors.overdueLight : AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: AppTextStyles.labelLarge.copyWith(
              color: overdue ? AppColors.overdue : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          AppSpacing.verticalGapXs,
          Text(
            copy,
            style: AppTextStyles.bodySmall.copyWith(
              color: overdue ? AppColors.overdueDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactPanel extends StatelessWidget {
  final Report report;

  const _ImpactPanel({required this.report});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ImpactTile(value: report.affectedStudents, label: 'Students affected'),
        AppSpacing.horizontalGapSm,
        _ImpactTile(value: report.nudges, label: 'Follow-ups'),
        AppSpacing.horizontalGapSm,
        _ImpactTile(
          value: report.reopenCount,
          label: 'Reopened',
          alarming: report.reopenCount > 0,
        ),
      ],
    );
  }
}

class _ImpactTile extends StatelessWidget {
  final int value;
  final String label;
  final bool alarming;

  const _ImpactTile({
    required this.value,
    required this.label,
    this.alarming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: alarming ? AppColors.overdueLight : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppTextStyles.statNumber.copyWith(
                color: alarming ? AppColors.overdue : AppColors.textPrimary,
              ),
            ),
            Text(label, style: AppTextStyles.statLabel.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Widget child;

  const _ActionBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.floating,
      ),
      child: child,
    );
  }
}

class _StudentActions extends ConsumerWidget {
  final Report report;
  final bool isMine;

  const _StudentActions({required this.report, required this.isMine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMine && report.awaitsVerification) {
      return _VerifyActions(report: report);
    }
    if (isMine && report.isOpen) return _NudgeAction(report: report);
    return Row(
      children: [
        Expanded(child: UpvoteButton(report: report, expanded: true)),
        AppSpacing.horizontalGapMd,
        Pressable(
          onTap: () {},
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: const BoxDecoration(
              color: AppColors.chipBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              HugeIcons.strokeRoundedShare01,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifyActions extends ConsumerWidget {
  final Report report;

  const _VerifyActions({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.read(reportsProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Faculty marked this fixed. Go look, then tell us. '
          '+${XpReason.fixChecked.xp} XP either way.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        AppSpacing.verticalGapMd,
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Still broken',
                isFilled: false,
                onTap: () {
                  Navigator.of(context).pop();
                  reports.reportStillBroken(report.id);
                },
              ),
            ),
            AppSpacing.horizontalGapMd,
            Expanded(
              child: AppButton(
                label: 'It is fixed',
                onTap: () {
                  Navigator.of(context).pop();
                  reports.confirmFix(report.id);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NudgeAction extends ConsumerWidget {
  final Report report;

  const _NudgeAction({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(minuteProvider);
    final canNudge = report.canNudgeAt(now);
    final last = report.lastNudgedAt;
    final wait = last == null
        ? Duration.zero
        : Report.nudgeCooldown - now.difference(last);
    return SizedBox(
      width: double.infinity,
      child: Builder(
        builder: (buttonContext) => AppButton(
          icon: HugeIcons.strokeRoundedNotification01,
          isFilled: canNudge,
          label: canNudge
              ? 'Nudge faculty  +${XpReason.nudgeSent.xp} XP'
              : 'Nudged. Next in ${(wait.inMinutes + 59) ~/ 60}h',
          onTap: canNudge
              ? () {
                  HapticFeedback.mediumImpact();
                  final origin = Confetti.centerOf(buttonContext);
                  final xp = ref
                      .read(reportsProvider.notifier)
                      .nudge(report.id);
                  Confetti.burst(
                    buttonContext,
                    origin: origin,
                    style: ConfettiStyle.spark,
                  );
                  if (xp > 0) {
                    XpPop.show(buttonContext, origin: origin, xp: xp);
                  }
                }
              : null,
        ),
      ),
    );
  }
}

class _FacultyActions extends ConsumerWidget {
  final Report report;

  const _FacultyActions({required this.report});

  void _finish(BuildContext context, VoidCallback action) {
    final size = MediaQuery.sizeOf(context);
    Confetti.burst(
      context,
      origin: Offset(size.width / 2, size.height * 0.75),
      colors: AppColors.confettiOnLight,
    );
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.read(reportsProvider.notifier);
    return switch (report.status) {
      ReportStatus.awaitingApproval => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SlideToConfirm(
            label: 'Slide to approve',
            color: AppColors.accent,
            onConfirmed: () {
              Navigator.of(context).pop();
              reports.approve(report.id);
            },
          ),
          AppSpacing.verticalGapSm,
          Pressable(
            onTap: () {
              Navigator.of(context).pop();
              reports.decline(report.id);
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                'Decline report',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
      ReportStatus.inProgress => SlideToConfirm(
        label: 'Slide to mark resolved',
        onConfirmed: () => _finish(context, () => reports.resolve(report.id)),
      ),
      ReportStatus.resolved || ReportStatus.declined => SizedBox(
        width: double.infinity,
        child: AppButton(
          label: 'Close',
          isFilled: false,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
    };
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.accentLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        AppSpacing.horizontalGapMd,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(value, style: AppTextStyles.labelMedium),
          ],
        ),
      ],
    );
  }
}

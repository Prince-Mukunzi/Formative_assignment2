import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/mock_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/time_format.dart';
import '../models/department.dart';
import '../models/game.dart';
import '../models/report.dart';
import '../models/report_status.dart';
import '../models/session.dart';
import '../providers/clock_provider.dart';
import '../providers/directory_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/session_provider.dart';
import 'app_button.dart';
import 'category_chip.dart';
import 'game/bounty_track.dart';
import 'motion/confetti.dart';
import 'motion/pressable.dart';
import 'motion/slide_to_confirm.dart';
import 'motion/xp_pop.dart';
import 'report_image.dart';
import 'sla_label.dart';
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
    if (report == null) return const SizedBox.shrink();
    final session = ref.watch(sessionProvider);
    final isStaff = session is! StudentSession;
    final team = ref.watch(departmentsProvider).ownerOf(report)?.label;
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
                  _Body(
                    report: report,
                    isStaff: isStaff,
                    isMine: isMine,
                    team: team ?? 'No team',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
            ),
            child: switch (session) {
              AdminSession() => _AdminActions(report: report),
              FacultySession() => _FacultyActions(report: report),
              _ => _StudentActions(report: report, isMine: isMine),
            },
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
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ReportImage(report: report),
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.xl,
            child: StatusBadge(status: report.status),
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
    );
  }
}

class _Body extends StatelessWidget {
  final Report report;
  final bool isStaff;
  final bool isMine;
  final String team;

  const _Body({
    required this.report,
    required this.isStaff,
    required this.isMine,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(report.title, style: AppTextStyles.heading2),
          AppSpacing.verticalGapXs,
          Text(
            '${report.category.label}  ·  '
            '${shortTimeAgo(report.createdAt)}',
            style: AppTextStyles.bodySmall,
          ),
          AppSpacing.verticalGapLg,
          Text(
            report.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (isMine && !isStaff) ...[
            AppSpacing.verticalGapXl,
            BountyTrack(report: report),
          ],
          AppSpacing.verticalGapLg,
          _InfoRow(label: 'Location', child: _value(report.location)),
          if (report.isOpen)
            _InfoRow(
              label: 'Deadline',
              child: SlaLabel(report: report, style: AppTextStyles.labelMedium),
            ),
          if (isStaff) ...[
            _InfoRow(label: 'Team', child: _value(team)),
            _InfoRow(label: 'Reporter', child: _value(report.reportedByName)),
            _InfoRow(
              label: 'Affected',
              child: _value('${report.affectedStudents}'),
            ),
            if (report.reopenCount > 0)
              _InfoRow(
                label: 'Reopened',
                child: _value('${report.reopenCount}'),
              ),
          ],
        ],
      ),
    );
  }

  Widget _value(String text) => Text(text, style: AppTextStyles.labelMedium);
}

class _AdminActions extends ConsumerWidget {
  final Report report;

  const _AdminActions({required this.report});

  void _reassign(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: AppSpacing.screenAll,
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final team in ref.read(departmentsProvider))
                SizedBox(
                  height: 40,
                  child: CategoryChip(
                    label: team.label,
                    isSelected:
                        ref.read(departmentsProvider).ownerOf(report)?.id ==
                        team.id,
                    onTap: () {
                      ref
                          .read(reportsProvider.notifier)
                          .reassign(report.id, team.id);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Delete this report?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    Navigator.of(context).pop();
    ref.read(reportsProvider.notifier).delete(report.id);
  }

  Widget _quiet(String label, Color color, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.read(reportsProvider.notifier);
    final primary = switch (report.status) {
      ReportStatus.awaitingApproval => Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Decline',
              isFilled: false,
              onTap: () => reports.decline(report.id),
            ),
          ),
          AppSpacing.horizontalGapMd,
          Expanded(
            child: AppButton(
              label: 'Approve',
              onTap: () => reports.approve(report.id),
            ),
          ),
        ],
      ),
      ReportStatus.inProgress => SizedBox(
        width: double.infinity,
        child: AppButton(
          label: 'Resolve',
          onTap: () => reports.resolve(report.id),
        ),
      ),
      ReportStatus.resolved || ReportStatus.declined => SizedBox(
        width: double.infinity,
        child: AppButton(
          label: 'Reopen',
          isFilled: false,
          onTap: () => reports.reopen(report.id),
        ),
      ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        primary,
        AppSpacing.verticalGapSm,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _quiet(
              'Reassign',
              AppColors.textSecondary,
              () => _reassign(context, ref),
            ),
            _quiet('Delete', AppColors.brand, () => _delete(context, ref)),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _InfoRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          child,
        ],
      ),
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
    return UpvoteButton(report: report, expanded: true);
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
          'Is it fixed?  +${XpReason.fixChecked.xp} XP',
          style: AppTextStyles.labelMedium,
        ),
        AppSpacing.verticalGapMd,
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'No',
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
                label: 'Yes',
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
          isFilled: canNudge,
          label: canNudge
              ? 'Nudge  +${XpReason.nudgeSent.xp} XP'
              : 'Nudge again in ${(wait.inMinutes + 59) ~/ 60}h',
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
                    colors: AppColors.confettiOnLight,
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
                'Decline',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      ReportStatus.inProgress => SlideToConfirm(
        label: 'Slide to resolve',
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

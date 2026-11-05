import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/router/app_router.dart';
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
import 'game/bounty_track.dart';
import 'motion/confetti.dart';
import 'motion/pressable.dart';
import 'motion/slide_to_confirm.dart';
import 'motion/xp_pop.dart';
import 'reassign_sheet.dart';
import 'report_image.dart';
import 'sla_label.dart';
import 'status_badge.dart';
import 'upvote_button.dart';
import '../core/utils/app_haptics.dart';

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
    final isMine = report.reportedBy == session?.uid;
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
          _InfoRow(
            icon: HugeIcons.strokeRoundedLocation01,
            label: 'Location',
            child: _value(report.location),
          ),
          if (report.isOpen)
            _InfoRow(
              icon: HugeIcons.strokeRoundedClock01,
              label: 'Deadline',
              child: SlaLabel(report: report, style: AppTextStyles.labelMedium),
            ),
          if (isStaff) ...[
            _InfoRow(
              icon: HugeIcons.strokeRoundedUserGroup,
              label: 'Team',
              child: _value(team),
            ),
            _InfoRow(
              icon: HugeIcons.strokeRoundedUser,
              label: 'Reporter',
              child: _value(report.reportedByName),
            ),
            _InfoRow(
              icon: HugeIcons.strokeRoundedUserMultiple,
              label: 'Affected',
              child: _value('${report.affectedStudents}'),
            ),
            if (report.reopenCount > 0)
              _InfoRow(
                icon: HugeIcons.strokeRoundedRepeat,
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

Future<bool> _confirmDelete(BuildContext context, {String? message}) async {
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: const Text('Delete this report?'),
      content: message == null ? null : Text(message),
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
  return confirmed ?? false;
}

class _QuietAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  const _QuietAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              AppSpacing.horizontalGapXs,
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActions extends ConsumerWidget {
  final Report report;

  const _AdminActions({required this.report});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    if (!await _confirmDelete(context) || !context.mounted) return;
    Navigator.of(context).pop();
    ref.read(reportsProvider.notifier).delete(report.id);
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
            _QuietAction(
              label: 'Reassign',
              color: AppColors.textSecondary,
              onTap: () => ReassignSheet.show(context, report),
            ),
            _QuietAction(
              label: 'Delete',
              color: AppColors.brand,
              onTap: () => _delete(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          AppSpacing.horizontalGapSm,
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
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
    if (isMine && report.reporterCanChange) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NudgeAction(report: report),
          AppSpacing.verticalGapSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuietAction(
                icon: HugeIcons.strokeRoundedPencilEdit02,
                label: 'Edit',
                color: AppColors.textSecondary,
                onTap: () => _edit(context),
              ),
              _QuietAction(
                icon: HugeIcons.strokeRoundedDelete02,
                label: 'Delete',
                color: AppColors.brand,
                onTap: () => _delete(context, ref),
              ),
            ],
          ),
        ],
      );
    }
    if (isMine && report.isOpen) return _NudgeAction(report: report);
    return UpvoteButton(report: report, expanded: true);
  }

  void _edit(BuildContext context) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(AppRoutes.editReport(report.id));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirmDelete(
      context,
      message: 'You lose the XP this report earned.',
    );
    if (!confirmed || !context.mounted) return;
    Navigator.of(context).pop();
    ref.read(reportsProvider.notifier).withdraw(report.id);
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
                  AppHaptics.mediumImpact();
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
            tone: SlideTone.primary,
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

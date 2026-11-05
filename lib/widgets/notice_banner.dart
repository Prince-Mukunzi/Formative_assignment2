import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/app_haptics.dart';
import '../models/app_settings.dart';
import '../models/notice.dart';
import '../providers/notices_provider.dart';
import '../providers/reports_provider.dart';
import 'motion/pressable.dart';
import 'motion/spring_value.dart';
import 'report_detail_sheet.dart';

/// Drops queued notices in from the top, one at a time, above every route.
class NoticeLayer extends ConsumerStatefulWidget {
  const NoticeLayer({super.key});

  @override
  ConsumerState<NoticeLayer> createState() => _NoticeLayerState();
}

class _NoticeLayerState extends ConsumerState<NoticeLayer> {
  static const _shownFor = Duration(seconds: 4);
  static const _exit = Duration(milliseconds: 320);

  Notice? _showing;
  bool _visible = false;
  Timer? _timer;

  void _present(Notice notice) {
    _timer?.cancel();
    setState(() {
      _showing = notice;
      _visible = true;
    });
    AppHaptics.lightImpact();
    _timer = Timer(_shownFor, _hide);
  }

  void _hide() {
    _timer?.cancel();
    if (!mounted || !_visible) return;
    setState(() => _visible = false);
    _timer = Timer(_exit, () {
      if (!mounted) return;
      _showing = null;
      ref.read(noticesProvider.notifier).dismiss();
    });
  }

  void _open(Notice notice) {
    _hide();
    final id = notice.reportId;
    final navigator = ref
        .read(routerProvider)
        .routerDelegate
        .navigatorKey
        .currentContext;
    if (id == null || navigator == null) return;
    final report = ref.read(reportByIdProvider(id));
    if (report != null) ReportDetailSheet.show(navigator, report);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(noticesProvider, (_, queue) {
      if (_showing == null && queue.isNotEmpty) _present(queue.first);
    });
    final notice = _showing;
    if (notice == null) return const SizedBox.shrink();
    final top = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: top + AppSpacing.sm,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: SpringValue(
        value: _visible ? 1 : 0,
        from: 0,
        spring: AppSprings.bouncy,
        builder: (_, t, child) => Transform.translate(
          offset: Offset(0, (1 - t) * -(top + 120)),
          child: child,
        ),
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) < 0) _hide();
          },
          child: Pressable(
            onTap: () => _open(notice),
            scale: 0.97,
            child: _Banner(notice: notice),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final Notice notice;

  const _Banner({required this.notice});

  static IconData iconFor(NotificationTopic topic) => switch (topic) {
    NotificationTopic.reportUpdates => HugeIcons.strokeRoundedNotification01,
    NotificationTopic.upvotes => HugeIcons.strokeRoundedThumbsUp,
    NotificationTopic.prizes => HugeIcons.strokeRoundedGift,
    NotificationTopic.newReports => HugeIcons.strokeRoundedInbox,
    NotificationTopic.deadlines => HugeIcons.strokeRoundedClock01,
    NotificationTopic.boardChanges => HugeIcons.strokeRoundedRanking,
    NotificationTopic.overdueReports => HugeIcons.strokeRoundedAlert02,
    NotificationTopic.unownedReports => HugeIcons.strokeRoundedUserQuestion01,
    NotificationTopic.dailySummary => HugeIcons.strokeRoundedSun03,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppColors.navy,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.onPrimaryWash,
              ),
              child: Icon(
                iconFor(notice.topic),
                size: 20,
                color: AppColors.textOnPrimary,
              ),
            ),
            AppSpacing.horizontalGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notice.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  Text(
                    notice.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onPrimaryMuted,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.horizontalGapSm,
          ],
        ),
      ),
    );
  }
}

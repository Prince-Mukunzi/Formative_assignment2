import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../providers/reports_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/game/bounty_track.dart';
import '../../widgets/motion/spring_in.dart';
import '../../widgets/report_card.dart';
import '../../widgets/status_filter_bar.dart';

class ReportsListScreen extends ConsumerStatefulWidget {
  final ValueChanged<Report>? onReportTap;

  const ReportsListScreen({super.key, this.onReportTap});

  @override
  ConsumerState<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends ConsumerState<ReportsListScreen> {
  ReportStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final mine = ref
        .watch(reportsProvider)
        .where((r) => r.reportedBy == ref.watch(sessionUidProvider))
        .toList();
    final visible = _statusFilter == null
        ? mine
        : mine.where((r) => r.status == _statusFilter).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalGapLg,
                  Text('My reports', style: AppTextStyles.heading1),
                  AppSpacing.verticalGapLg,
                  StatusFilterBar(
                    selected: _statusFilter,
                    onChanged: (status) =>
                        setState(() => _statusFilter = status),
                  ),
                  AppSpacing.verticalGapLg,
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverToBoxAdapter(
              child: mine.isEmpty
                  ? EmptyState(
                      icon: HugeIcons.strokeRoundedTarget02,
                      title: 'Your hunt starts here',
                      message:
                          'Spot a broken tap, a dead light or a wobbly chair. '
                          'Report it and watch it get fixed.',
                      accent: true,
                      action: (
                        label: 'Make your first report',
                        icon: HugeIcons.strokeRoundedAdd01,
                        onTap: () => context.push(AppRoutes.newReport),
                      ),
                    )
                  : EmptyState(
                      icon: HugeIcons.strokeRoundedFilterRemove,
                      title:
                          'None ${_statusFilter?.label.toLowerCase() ?? 'here'}',
                      message:
                          'You have ${mine.length} other '
                          '${mine.length == 1 ? 'report' : 'reports'}.',
                      action: (
                        label: 'Show all',
                        icon: HugeIcons.strokeRoundedView,
                        onTap: () => setState(() => _statusFilter = null),
                      ),
                    ),
            ),
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final report = visible[index];
                return SpringIn(
                  key: ValueKey(report.id),
                  delay: Duration(milliseconds: 60 * index.clamp(0, 5)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: ReportCard(
                      report: report,
                      onTap: () => widget.onReportTap?.call(report),
                      footer: BountyTrack(report: report),
                    ),
                  ),
                );
              }, childCount: visible.length),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.navClearance),
          ),
        ],
      ),
    );
  }
}

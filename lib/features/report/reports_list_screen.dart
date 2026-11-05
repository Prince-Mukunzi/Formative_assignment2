import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/game/bounty_track.dart';
import '../../widgets/motion/rolling_number.dart';
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
        .where((r) => r.reportedBy == MockData.currentStudentId)
        .toList();
    final pendingXp = mine.fold(0, (sum, r) => sum + pendingXpFor(r));
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
                  if (pendingXp > 0) ...[
                    AppSpacing.verticalGapXs,
                    RollingNumber(
                      value: pendingXp,
                      suffix: ' XP waiting',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.brand,
                      ),
                    ),
                  ],
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
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Text(
                  'Nothing here',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
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

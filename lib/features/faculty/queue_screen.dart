import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../models/sla.dart';
import '../../providers/clock_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/faculty/pressure_card.dart';
import '../../widgets/motion/spring_in.dart';
import '../../widgets/report_card.dart';

enum _QueueFilter {
  urgent('Most urgent', HugeIcons.strokeRoundedAlarmClock),
  fresh('New', HugeIcons.strokeRoundedClock01),
  active('In progress', HugeIcons.strokeRoundedWrench01),
  done('Resolved', HugeIcons.strokeRoundedCheckmarkCircle02);

  const _QueueFilter(this.label, this.icon);
  final String label;
  final IconData icon;

  bool matches(Report report) => switch (this) {
    urgent => report.isOpen,
    fresh => report.status == ReportStatus.awaitingApproval,
    active => report.status == ReportStatus.inProgress,
    done => report.status == ReportStatus.resolved,
  };
}

class QueueScreen extends ConsumerStatefulWidget {
  final Department department;
  final ValueChanged<Report> onReportTap;

  const QueueScreen({
    super.key,
    required this.department,
    required this.onReportTap,
  });

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  _QueueFilter _filter = _QueueFilter.urgent;

  List<Report> _visible(List<Report> owned) {
    final visible = owned.where(_filter.matches).toList();
    visible.sort((a, b) {
      final aDeadline = a.deadline;
      final bDeadline = b.deadline;
      if (aDeadline == null || bDeadline == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return aDeadline.compareTo(bDeadline);
    });
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(minuteProvider);
    final owned = ref
        .watch(reportsProvider)
        .where((r) => r.department == widget.department)
        .toList();
    final reports = _visible(owned);
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
                  Text('Your queue', style: AppTextStyles.subtitle),
                  Text(
                    '${widget.department.label} team',
                    style: AppTextStyles.heading1,
                  ),
                  AppSpacing.verticalGapLg,
                  SpringIn(
                    delay: const Duration(milliseconds: 100),
                    child: PressureCard(
                      reading: PressureReading.of(owned, now),
                    ),
                  ),
                  AppSpacing.verticalGapLg,
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildFilters()),
          const SliverToBoxAdapter(child: AppSpacing.verticalGapLg),
          if (reports.isEmpty)
            SliverToBoxAdapter(child: _buildEmpty())
          else
            SliverPadding(
              padding: AppSpacing.screenPadding,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final report = reports[index];
                  return SpringIn(
                    key: ValueKey(report.id),
                    delay: Duration(milliseconds: 60 * index.clamp(0, 5)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: ReportCard(
                        report: report,
                        onTap: () => widget.onReportTap(report),
                      ),
                    ),
                  );
                }, childCount: reports.length),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.navClearance),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemCount: _QueueFilter.values.length,
        itemBuilder: (_, index) {
          final filter = _QueueFilter.values[index];
          return CategoryChip(
            icon: filter.icon,
            label: filter.label,
            isSelected: filter == _filter,
            onTap: () => setState(() => _filter = filter),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: AppSpacing.screenAll,
      child: Column(
        children: [
          const Icon(
            HugeIcons.strokeRoundedCheckmarkBadge01,
            size: 40,
            color: AppColors.resolved,
          ),
          AppSpacing.verticalGapMd,
          Text('Nothing here right now', style: AppTextStyles.labelLarge),
          AppSpacing.verticalGapXs,
          Text('No reports match this view.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

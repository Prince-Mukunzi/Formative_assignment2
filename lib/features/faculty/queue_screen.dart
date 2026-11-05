import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../models/sla.dart';
import '../../providers/clock_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/faculty/pressure_card.dart';
import '../../widgets/motion/spring_in.dart';
import '../../widgets/report_card.dart';

enum _QueueFilter {
  urgent('Urgent'),
  fresh('New'),
  active('Active'),
  done('Resolved');

  const _QueueFilter(this.label);
  final String label;

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
    final owned = ref.watch(departmentReportsProvider(widget.department.id));
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
                  const AppLogo(),
                  AppSpacing.verticalGapLg,
                  Text(widget.department.label, style: AppTextStyles.heading1),
                  const SizedBox(height: AppSpacing.xxl),
                  PressureCard(reading: PressureReading.of(owned, now)),
                  AppSpacing.verticalGapXl,
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
                        showDeadline: true,
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
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemCount: _QueueFilter.values.length,
        itemBuilder: (_, index) {
          final filter = _QueueFilter.values[index];
          return CategoryChip(
            label: filter.label,
            isSelected: filter == _filter,
            onTap: () => setState(() => _filter = filter),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    final (icon, title, message, label, next) = switch (_filter) {
      _QueueFilter.urgent => (
        HugeIcons.strokeRoundedCoffee02,
        'Queue is clear',
        'No open reports for your team. Enjoy the calm.',
        'See what you fixed',
        _QueueFilter.done,
      ),
      _QueueFilter.fresh => (
        HugeIcons.strokeRoundedInbox,
        'Inbox zero',
        'Nothing is waiting for approval right now.',
        'See open reports',
        _QueueFilter.urgent,
      ),
      _QueueFilter.active => (
        HugeIcons.strokeRoundedWrench01,
        'Nothing on the bench',
        'Approve a new report to start fixing it.',
        'See new reports',
        _QueueFilter.fresh,
      ),
      _QueueFilter.done => (
        HugeIcons.strokeRoundedRocket01,
        'No fixes yet',
        'Every fix earns your team 10 points on the board.',
        'Find one to fix',
        _QueueFilter.urgent,
      ),
    };
    return EmptyState(
      icon: icon,
      title: title,
      message: message,
      action: (
        label: label,
        icon: HugeIcons.strokeRoundedArrowRight01,
        onTap: () => setState(() => _filter = next),
      ),
    );
  }
}

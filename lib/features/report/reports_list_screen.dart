import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/mock_data.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../widgets/report_card.dart';
import '../../widgets/status_filter_bar.dart';

class ReportsListScreen extends StatefulWidget {
  final ValueChanged<Report>? onReportTap;

  const ReportsListScreen({super.key, this.onReportTap});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  ReportStatus? _statusFilter;

  List<Report> get _filteredReports {
    if (_statusFilter == null) return MockData.reports;
    return MockData.reports
        .where((r) => r.status == _statusFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('My Reports', style: AppTextStyles.heading2),
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
          _buildList(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildList() {
    final reports = _filteredReports;
    return SliverPadding(
      padding: AppSpacing.screenPadding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              key: ValueKey(reports[index].id),
              padding: const EdgeInsets.only(bottom: 16),
              child: ReportCard(
                report: reports[index],
                onTap: () => widget.onReportTap?.call(reports[index]),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: (80 * index).ms);
          },
          childCount: reports.length,
        ),
      ),
    );
  }
}

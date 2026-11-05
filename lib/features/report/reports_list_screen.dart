import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/mock_data.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../widgets/report_card.dart';

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
                  Text('All Reports', style: AppTextStyles.heading2),
                  AppSpacing.verticalGapLg,
                  _buildStatusFilters(),
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

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusChip(
            label: 'All',
            isSelected: _statusFilter == null,
            onTap: () => setState(() => _statusFilter = null),
          ),
          const SizedBox(width: 8),
          ...ReportStatus.values.map((status) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _StatusChip(
                label: status.label,
                isSelected: _statusFilter == status,
                onTap: () => setState(() => _statusFilter = status),
              ),
            );
          }),
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

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected
                ? AppColors.textOnPrimary
                : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

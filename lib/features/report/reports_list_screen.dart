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
          AppSpacing.horizontalGapSm,
          ...ReportStatus.values.map((status) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _StatusChip(
                label: status.label,
                color: status.color,
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
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ReportCard(
              report: reports[index],
              onTap: () => widget.onReportTap?.call(reports[index]),
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
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.cardBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected
                ? AppColors.textOnPrimary
                : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

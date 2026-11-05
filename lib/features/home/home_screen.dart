import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/mock_data.dart';
import '../../models/report.dart';
import '../../models/report_category.dart';
import '../../models/report_status.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/report_card.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<Report>? onReportTap;

  const HomeScreen({super.key, this.onReportTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReportCategory _selectedCategory = ReportCategory.all;
  ReportStatus? _statusFilter;

  List<Report> get _filteredReports {
    var reports = MockData.reports;
    if (_selectedCategory != ReportCategory.all) {
      reports = reports
          .where((r) => r.category == _selectedCategory)
          .toList();
    }
    if (_statusFilter != null) {
      reports = reports
          .where((r) => r.status == _statusFilter)
          .toList();
    }
    return reports;
  }

  String get _greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
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
                  _buildGreeting(),
                  AppSpacing.verticalGapXl,
                  _buildSearchBar(),
                  AppSpacing.verticalGapLg,
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildStatusFilters()),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalGapXl,
                  _buildRecentHeader(),
                  AppSpacing.verticalGapMd,
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(
            child: AppSpacing.verticalGapLg,
          ),
          _buildReportsList(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greetingText,
          style: AppTextStyles.subtitle,
        ),
        Text(
          MockData.userName,
          style: AppTextStyles.heading1,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms);
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(
            HugeIcons.strokeRoundedSearch01,
            size: 20,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Text(
            'Search reports...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildStatusFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
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
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildRecentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recent Reports', style: AppTextStyles.heading3),
        GestureDetector(
          onTap: () {},
          child: Text(
            'See all',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemCount: ReportCategory.values.length,
        itemBuilder: (context, index) {
          final category = ReportCategory.values[index];
          return CategoryChip(
            icon: category.icon,
            label: category.label,
            isSelected: _selectedCategory == category,
            onTap: () => setState(() => _selectedCategory = category),
          );
        },
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildReportsList() {
    final reports = _filteredReports;
    return SliverPadding(
      padding: AppSpacing.screenPadding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final report = reports[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ReportCard(
                report: report,
                onTap: () => widget.onReportTap?.call(report),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: (80 * index).ms)
                .slideY(
                  begin: 0.05,
                  end: 0,
                  duration: 300.ms,
                  delay: (80 * index).ms,
                );
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
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

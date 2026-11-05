import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/mock_data.dart';
import '../../models/report.dart';
import '../../models/report_category.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/filter_tag.dart';
import '../../widgets/report_card.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<Report>? onReportTap;

  const HomeScreen({super.key, this.onReportTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReportCategory _selectedCategory = ReportCategory.all;
  final Set<String> _activeFilters = {'Most Impacted', 'This Week', 'Resolved'};

  List<Report> get _filteredReports {
    var reports = MockData.reports;
    if (_selectedCategory != ReportCategory.all) {
      reports = reports
          .where((r) => r.category == _selectedCategory)
          .toList();
    }
    return reports;
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
                  _buildTitle(),
                  AppSpacing.verticalGapLg,
                  _buildStats(),
                  AppSpacing.verticalGapXl,
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalGapXl,
                  _buildReportsHeader(),
                  AppSpacing.verticalGapMd,
                  _buildFilterTags(),
                  AppSpacing.verticalGapLg,
                ],
              ),
            ),
          ),
          _buildReportsGrid(),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hey ${MockData.userName}\u{1F44B}\u{1F3FE},',
          style: AppTextStyles.greeting,
        ),
        AppSpacing.verticalGapXs,
        Text(
          'Be the first to report an issue',
          style: AppTextStyles.subtitle,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms);
  }

  Widget _buildTitle() {
    return Text(
      'ALU BUG BOUNTY',
      style: AppTextStyles.heading2.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w800,
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildStats() {
    return Row(
      children: [
        StatCard(
          icon: HugeIcons.strokeRoundedTask01,
          iconColor: AppColors.active,
          count: MockData.activeCount,
          label: 'Active',
        ),
        AppSpacing.horizontalGapMd,
        StatCard(
          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
          iconColor: AppColors.resolved,
          count: MockData.resolvedCount,
          label: 'Resolved',
        ),
        AppSpacing.horizontalGapMd,
        StatCard(
          icon: HugeIcons.strokeRoundedLoading03,
          iconColor: AppColors.inProgress,
          count: MockData.inProgressCount,
          label: 'In Progress',
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        separatorBuilder: (_, _) => AppSpacing.horizontalGapSm,
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

  Widget _buildReportsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Reports', style: AppTextStyles.heading3),
        GestureDetector(
          onTap: () {},
          child: const Icon(
            HugeIcons.strokeRoundedFilterHorizontal,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTags() {
    final filters = _activeFilters.toList();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: filters.map((filter) {
        return FilterTag(
          label: filter,
          onRemove: () => setState(() => _activeFilters.remove(filter)),
        );
      }).toList(),
    );
  }

  Widget _buildReportsGrid() {
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
            final report = reports[index];
            return ReportCard(
              report: report,
              onTap: () => widget.onReportTap?.call(report),
            )
                .animate()
                .fadeIn(
                  duration: 300.ms,
                  delay: (100 * (index % 4)).ms,
                )
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                  delay: (100 * (index % 4)).ms,
                );
          },
          childCount: reports.length,
        ),
      ),
    );
  }
}

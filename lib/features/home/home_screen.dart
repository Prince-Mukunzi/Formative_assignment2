import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/mock_data.dart';
import '../../models/report.dart';
import '../../models/report_category.dart';
import '../../models/report_filter.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/filter_tag.dart';
import '../../widgets/report_card.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<Report>? onReportTap;

  const HomeScreen({super.key, this.onReportTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReportFilter _filter = const ReportFilter();

  List<Report> get _filteredReports => _filter.apply(MockData.reports);

  Future<void> _openFilters() async {
    final result = await FilterSheet.show(context, _filter);
    if (result != null) setState(() => _filter = result);
  }

  String _toHashtag(String label) => label
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join();

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
                  _buildRecentHeader(),
                  _buildActiveFilters(),
                  AppSpacing.verticalGapSm,
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

  Widget _buildRecentHeader() {
    final count = _filter.advancedCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recent Reports', style: AppTextStyles.heading3),
        GestureDetector(
          onTap: _openFilters,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              backgroundColor: AppColors.accent,
              child: const Icon(
                HugeIcons.strokeRoundedFilterHorizontal,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    final tags = <(String, ReportFilter)>[
      if (_filter.status != null)
        (_filter.status!.label, _filter.copyWith(status: () => null)),
      if (_filter.sort != ReportSort.recent)
        (_filter.sort.label, _filter.copyWith(sort: ReportSort.recent)),
      if (_filter.dateLabel != null)
        (
          _filter.dateLabel!,
          _filter.copyWith(datePreset: DatePreset.any, customRange: () => null),
        ),
    ];

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topLeft,
      child: tags.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Wrap(
                spacing: AppSpacing.lg,
                children: [
                  for (final (label, next) in tags)
                    FilterTag(
                      label: _toHashtag(label),
                      onRemove: () => setState(() => _filter = next),
                    ),
                ],
              ),
            ),
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
            isSelected: _filter.category == category,
            onTap: () =>
                setState(() => _filter = _filter.copyWith(category: category)),
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
              key: ValueKey(report.id),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../models/report_category.dart';
import '../../models/report_filter.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/filter_tag.dart';
import '../../widgets/game/hunter_card.dart';
import '../../widgets/motion/spring_in.dart';
import '../../widgets/report_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final ValueChanged<Report>? onReportTap;

  const HomeScreen({super.key, this.onReportTap});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ReportFilter _filter = const ReportFilter();

  List<Report> _feed(List<Report> reports) => _filter.apply(
    reports.where((r) => r.status != ReportStatus.declined).toList(),
  );

  Future<void> _openFilters() async {
    final result = await FilterSheet.show(context, _filter);
    if (result != null) setState(() => _filter = result);
  }

  String _toHashtag(String label) => label
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join();

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
                  const AppLogo(),
                  AppSpacing.verticalGapLg,
                  HunterCard(onTap: () => context.push(AppRoutes.progress)),
                  AppSpacing.verticalGapXl,
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: _buildActiveFilters(),
            ),
          ),
          SliverToBoxAdapter(child: AppSpacing.verticalGapLg),
          _buildReportsList(),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.navClearance),
          ),
        ],
      ),
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
    final count = _filter.advancedCount;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: AppSpacing.screenPadding.left),
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemCount: ReportCategory.values.length,
              itemBuilder: (context, index) {
                final category = ReportCategory.values[index];
                return CategoryChip(
                  icon: category.icon,
                  label: category.label,
                  isSelected: _filter.category == category,
                  onTap: () => setState(
                    () => _filter = _filter.copyWith(category: category),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: _openFilters,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                backgroundColor: AppColors.brand,
                child: const Icon(
                  HugeIcons.strokeRoundedFilterHorizontal,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    final reports = _feed(ref.watch(reportsProvider));
    return SliverPadding(
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
                onTap: () => widget.onReportTap?.call(report),
              ),
            ),
          );
        }, childCount: reports.length),
      ),
    );
  }
}

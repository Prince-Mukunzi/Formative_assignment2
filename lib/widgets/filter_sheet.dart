import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/report_category.dart';
import '../models/report_filter.dart';
import '../models/report_status.dart';
import 'app_button.dart';
import 'filter_pill.dart';

class FilterSheet extends StatefulWidget {
  final ReportFilter initial;

  const FilterSheet({super.key, required this.initial});

  static Future<ReportFilter?> show(
    BuildContext context,
    ReportFilter initial,
  ) {
    return showModalBottomSheet<ReportFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(initial: initial),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late ReportFilter _filter = widget.initial;

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: _filter.customRange,
    );
    if (picked == null) return;
    setState(() {
      _filter = _filter.copyWith(
        datePreset: DatePreset.custom,
        customRange: () => picked,
      );
    });
  }

  void _selectDate(DatePreset preset) {
    if (preset == DatePreset.custom) {
      _pickCustomRange();
      return;
    }
    setState(() => _filter = _filter.copyWith(datePreset: preset));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          AppSpacing.verticalGapLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: AppTextStyles.heading3),
              GestureDetector(
                onTap: () => setState(() => _filter = const ReportFilter()),
                child: Text(
                  'Reset',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapXl,
          _Section(
            title: 'Sort by',
            children: [
              for (final sort in ReportSort.values)
                FilterPill(
                  label: sort.label,
                  isSelected: _filter.sort == sort,
                  onTap: () =>
                      setState(() => _filter = _filter.copyWith(sort: sort)),
                ),
            ],
          ),
          _Section(
            title: 'Status',
            children: [
              FilterPill(
                label: 'Any',
                isSelected: _filter.status == null,
                onTap: () => setState(
                  () => _filter = _filter.copyWith(status: () => null),
                ),
              ),
              for (final status in ReportStatus.values)
                FilterPill(
                  label: status.label,
                  isSelected: _filter.status == status,
                  onTap: () => setState(
                    () => _filter = _filter.copyWith(status: () => status),
                  ),
                ),
            ],
          ),
          _Section(
            title: 'Category',
            children: [
              for (final category in ReportCategory.values)
                FilterPill(
                  label: category.label,
                  isSelected: _filter.category == category,
                  onTap: () => setState(
                    () => _filter = _filter.copyWith(category: category),
                  ),
                ),
            ],
          ),
          _Section(
            title: 'Date',
            children: [
              for (final preset in DatePreset.values)
                FilterPill(
                  label: preset == DatePreset.custom &&
                          _filter.datePreset == DatePreset.custom
                      ? (_filter.dateLabel ?? preset.label)
                      : preset.label,
                  isSelected: _filter.datePreset == preset,
                  onTap: () => _selectDate(preset),
                ),
            ],
          ),
          AppSpacing.verticalGapSm,
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Apply filters',
              onTap: () => Navigator.of(context).pop(_filter),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium),
          AppSpacing.verticalGapMd,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: children,
          ),
        ],
      ),
    );
  }
}

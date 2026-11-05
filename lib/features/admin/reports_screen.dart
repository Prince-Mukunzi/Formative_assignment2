import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/department.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../providers/directory_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/report_detail_sheet.dart';
import '../../widgets/sla_label.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportStatus? _status;

  @override
  Widget build(BuildContext context) {
    final departments = ref.watch(departmentsProvider);
    final reports =
        ref
            .watch(reportsProvider)
            .where((r) => _status == null || r.status == _status)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
                  Text('Reports', style: AppTextStyles.heading1),
                  AppSpacing.verticalGapXl,
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildFilters()),
          const SliverToBoxAdapter(child: AppSpacing.verticalGapMd),
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverList.builder(
              itemCount: reports.length,
              itemBuilder: (_, index) => _ReportRow(
                report: reports[index],
                team: departments.ownerOf(reports[index])?.label ?? 'No team',
              ),
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
    final options = <ReportStatus?>[null, ...ReportStatus.values];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemCount: options.length,
        itemBuilder: (_, index) => CategoryChip(
          label: options[index]?.label ?? 'All',
          isSelected: options[index] == _status,
          onTap: () => setState(() => _status = options[index]),
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final Report report;
  final String team;

  const _ReportRow({required this.report, required this.team});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => ReportDetailSheet.show(context, report),
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium,
                  ),
                  AppSpacing.verticalGapXs,
                  Text(
                    '$team  ·  ${report.status.label}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            AppSpacing.horizontalGapMd,
            SlaLabel(report: report),
          ],
        ),
      ),
    );
  }
}

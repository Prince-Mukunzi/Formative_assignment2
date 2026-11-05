import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/department.dart';
import '../models/report.dart';
import '../providers/directory_provider.dart';
import '../providers/reports_provider.dart';
import 'app_button.dart';
import 'app_sheet.dart';
import 'team_wheel.dart';

class ReassignSheet extends ConsumerStatefulWidget {
  final Report report;

  const ReassignSheet({super.key, required this.report});

  static void show(BuildContext context, Report report) {
    showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: AppSheet.animation,
      backgroundColor: AppColors.surface,
      builder: (_) => ReassignSheet(report: report),
    );
  }

  @override
  ConsumerState<ReassignSheet> createState() => _ReassignSheetState();
}

class _ReassignSheetState extends ConsumerState<ReassignSheet> {
  late String? _teamId = ref
      .read(departmentsProvider)
      .ownerOf(widget.report)
      ?.id;

  void _save() {
    final teamId = _teamId;
    if (teamId != null) {
      ref.read(reportsProvider.notifier).reassign(widget.report.id, teamId);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Move to team', style: AppTextStyles.heading2),
            AppSpacing.verticalGapLg,
            TeamWheel(
              selectedId: _teamId,
              onChanged: (id) => setState(() => _teamId = id),
            ),
            AppSpacing.verticalGapLg,
            SizedBox(
              width: double.infinity,
              child: AppButton(label: 'Move', onTap: _save),
            ),
          ],
        ),
      ),
    );
  }
}

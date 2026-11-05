import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../../providers/clock_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/faculty/department_board.dart';

class BoardScreen extends ConsumerWidget {
  final Department department;

  const BoardScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = departmentBoard(
      ref.watch(reportsProvider),
      ref.watch(minuteProvider),
    );
    final place = board.indexWhere((s) => s.department == department) + 1;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalGapLg,
            Text('Board', style: AppTextStyles.heading1),
            AppSpacing.verticalGapXs,
            Text('Visible to students', style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.xxxl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$place', style: AppTextStyles.display),
                AppSpacing.horizontalGapSm,
                Text('of ${board.length}', style: AppTextStyles.subtitle),
              ],
            ),
            AppSpacing.verticalGapXl,
            DepartmentBoard(highlight: department),
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }
}

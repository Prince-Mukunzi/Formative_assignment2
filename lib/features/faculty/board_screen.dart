import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/department.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/faculty/department_board.dart';
import '../../widgets/faculty/team_podium.dart';

class BoardScreen extends ConsumerWidget {
  final Department department;

  const BoardScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(departmentBoardProvider);
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalGapLg,
            Text('Board', style: AppTextStyles.heading1),
            AppSpacing.verticalGapLg,
            TeamPodium(top: board.take(3).toList(), highlight: department),
            if (board.length > 3) ...[
              AppSpacing.verticalGapLg,
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: DepartmentBoard(highlight: department, skip: 3),
              ),
            ],
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }
}

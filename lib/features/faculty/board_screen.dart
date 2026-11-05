import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/department.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/faculty/department_board.dart';
import '../../widgets/gradient_banner.dart';

class BoardScreen extends ConsumerWidget {
  final Department department;

  const BoardScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(departmentBoardProvider);
    final place = board.indexWhere((s) => s.department.id == department.id) + 1;
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
            GradientBanner(
              gradient: place == 1 ? AppColors.navy : AppColors.signature,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$place',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      AppSpacing.horizontalGapSm,
                      Text(
                        'of ${board.length}',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.onPrimaryMuted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Visible to students',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onPrimaryMuted,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapLg,
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: DepartmentBoard(highlight: department),
            ),
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }
}

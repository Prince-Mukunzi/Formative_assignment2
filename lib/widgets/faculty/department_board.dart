import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../../providers/clock_provider.dart';
import '../../providers/reports_provider.dart';
import '../motion/rolling_number.dart';
import '../spring_rank_list.dart';

class DepartmentBoard extends ConsumerWidget {
  final Department? highlight;

  const DepartmentBoard({super.key, this.highlight});

  static const _rowHeight = 84.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = departmentBoard(
      ref.watch(reportsProvider),
      ref.watch(minuteProvider),
    );
    return SpringRankList(
      rowHeight: _rowHeight,
      rows: [
        for (var i = 0; i < board.length; i++)
          (
            id: board[i].department.name,
            child: _Row(
              place: i + 1,
              score: board[i],
              highlighted: board[i].department == highlight,
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final int place;
  final DepartmentScore score;
  final bool highlighted;

  const _Row({
    required this.place,
    required this.score,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = score.overdue > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.card,
          border: highlighted
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text('$place', style: AppTextStyles.heading3),
            ),
            Icon(score.department.icon, size: 22, color: AppColors.primary),
            AppSpacing.horizontalGapMd,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(score.department.label, style: AppTextStyles.labelLarge),
                  Text(
                    overdue
                        ? '${score.overdue} overdue, ${score.open} open'
                        : '${score.resolved} resolved, ${score.open} open',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: overdue
                          ? AppColors.overdue
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _Points(points: score.points),
          ],
        ),
      ),
    );
  }
}

class _Points extends StatelessWidget {
  final int points;

  const _Points({required this.points});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.labelLarge.copyWith(
      color: points < 0 ? AppColors.overdue : AppColors.textPrimary,
    );
    return RollingNumber(
      value: points.abs(),
      prefix: points < 0 ? '-' : '',
      suffix: ' pts',
      style: style,
    );
  }
}

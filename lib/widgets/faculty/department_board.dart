import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../../providers/reports_provider.dart';
import '../motion/rolling_number.dart';
import '../spring_rank_list.dart';

class DepartmentBoard extends ConsumerWidget {
  final Department? highlight;

  const DepartmentBoard({super.key, this.highlight});

  static const _rowHeight = 60.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(departmentBoardProvider);
    return SpringRankList(
      rowHeight: _rowHeight,
      rows: [
        for (var i = 0; i < board.length; i++)
          (
            id: board[i].department.id,
            child: _Row(
              place: i + 1,
              score: board[i],
              highlighted: board[i].department.id == highlight?.id,
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
    final weight = highlighted ? FontWeight.w700 : FontWeight.w500;
    final style = AppTextStyles.labelLarge.copyWith(fontWeight: weight);
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$place',
              style: style.copyWith(color: AppColors.textTertiary),
            ),
          ),
          Expanded(child: Text(score.department.label, style: style)),
          if (score.overdue > 0) ...[
            Text(
              '${score.overdue} late',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.brand),
            ),
            AppSpacing.horizontalGapLg,
          ],
          RollingNumber(
            value: score.points.abs(),
            prefix: score.points < 0 ? '-' : '',
            style: style,
          ),
        ],
      ),
    );
  }
}

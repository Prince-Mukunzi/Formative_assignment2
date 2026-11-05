import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/report.dart';
import '../models/sla.dart';
import '../providers/clock_provider.dart';

class SlaLabel extends ConsumerWidget {
  final Report report;
  final TextStyle? style;

  const SlaLabel({super.key, required this.report, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(minuteProvider);
    final state = report.slaStateAt(now);
    final left = report.timeLeftAt(now);
    if (state == null || left == null) return const SizedBox.shrink();
    final urgent = state == SlaState.critical || state == SlaState.overdue;
    final suffix = state == SlaState.overdue ? 'overdue' : 'left';
    return Text(
      '${formatSlaDuration(left)} $suffix',
      style: (style ?? AppTextStyles.bodySmall).copyWith(
        color: urgent ? AppColors.brand : AppColors.textSecondary,
      ),
    );
  }
}

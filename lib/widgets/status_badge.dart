import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/report_status.dart';

class StatusBadge extends StatelessWidget {
  final ReportStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.bodySmall.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

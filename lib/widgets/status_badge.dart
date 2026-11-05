import 'package:flutter/material.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/report_status.dart';

class StatusBadge extends StatelessWidget {
  final ReportStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: compact ? 12 : 14,
            color: status.color,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            status.label,
            style: (compact ? AppTextStyles.bodySmall : AppTextStyles.labelSmall)
                .copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

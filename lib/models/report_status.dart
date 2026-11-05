import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum ReportStatus {
  awaitingApproval('Awaiting Approval'),
  inProgress('In Progress'),
  resolved('Resolved');

  const ReportStatus(this.label);
  final String label;

  Color get color => switch (this) {
        awaitingApproval => AppColors.awaitingApproval,
        inProgress => AppColors.inProgress,
        resolved => AppColors.resolved,
      };

  Color get backgroundColor => switch (this) {
        awaitingApproval => AppColors.awaitingApprovalLight,
        inProgress => AppColors.inProgressLight,
        resolved => AppColors.resolvedLight,
      };

  IconData get icon => switch (this) {
        awaitingApproval => Icons.access_time_rounded,
        inProgress => Icons.autorenew_rounded,
        resolved => Icons.check_circle_outline_rounded,
      };
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
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
        awaitingApproval => HugeIcons.strokeRoundedClock01,
        inProgress => HugeIcons.strokeRoundedLoading03,
        resolved => HugeIcons.strokeRoundedCheckmarkCircle02,
      };
}

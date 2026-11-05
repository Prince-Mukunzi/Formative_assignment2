import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_colors.dart';

enum ReportStatus {
  awaitingApproval('Awaiting Approval'),
  inProgress('In Progress'),
  resolved('Resolved'),
  declined('Declined');

  const ReportStatus(this.label);
  final String label;

  static const feedValues = [awaitingApproval, inProgress, resolved];

  Color get color => switch (this) {
        awaitingApproval => AppColors.awaitingApproval,
        inProgress => AppColors.inProgress,
        resolved => AppColors.resolved,
        declined => AppColors.error,
      };

  Color get backgroundColor => switch (this) {
        awaitingApproval => AppColors.awaitingApprovalLight,
        inProgress => AppColors.inProgressLight,
        resolved => AppColors.resolvedLight,
        declined => AppColors.errorLight,
      };

  IconData get icon => switch (this) {
        awaitingApproval => HugeIcons.strokeRoundedClock01,
        inProgress => HugeIcons.strokeRoundedLoading03,
        resolved => HugeIcons.strokeRoundedCheckmarkCircle02,
        declined => HugeIcons.strokeRoundedCancelCircle,
      };
}

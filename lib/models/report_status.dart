import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/theme/app_colors.dart';

enum ReportStatus {
  awaitingApproval('Pending'),
  inProgress('Active'),
  resolved('Resolved'),
  declined('Declined');

  const ReportStatus(this.label);
  final String label;

  static const feedValues = [awaitingApproval, inProgress, resolved];

  Color get color => switch (this) {
    awaitingApproval => AppColors.textSecondary,
    inProgress => AppColors.primary,
    resolved => AppColors.textOnPrimary,
    declined => AppColors.textTertiary,
  };

  Color get backgroundColor => switch (this) {
    resolved => AppColors.primary,
    _ => AppColors.surface,
  };

  IconData get icon => switch (this) {
    awaitingApproval => HugeIcons.strokeRoundedClock01,
    inProgress => HugeIcons.strokeRoundedLoading03,
    resolved => HugeIcons.strokeRoundedCheckmarkCircle02,
    declined => HugeIcons.strokeRoundedCancelCircle,
  };
}

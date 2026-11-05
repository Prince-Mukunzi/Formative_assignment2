import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/report.dart';
import 'app_card.dart';
import 'label_icon.dart';
import 'posted_label.dart';
import 'report_image.dart';
import 'sla_label.dart';
import 'status_badge.dart';
import 'upvote_button.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;
  final Widget? footer;
  final bool showDeadline;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.footer,
    this.showDeadline = false,
  });

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: AppTextStyles.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSpacing.verticalGapXs,
                          _buildMeta(),
                        ],
                      ),
                    ),
                    AppSpacing.horizontalGapMd,
                    UpvoteButton(report: report),
                  ],
                ),
                if (footer != null) ...[AppSpacing.verticalGapMd, footer],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ReportImage(report: report),
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: StatusBadge(status: report.status),
          ),
        ],
      ),
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        LabelIcon(icon: report.category.icon, color: AppColors.textSecondary),
        AppSpacing.horizontalGapXs,
        Text(report.category.label, style: AppTextStyles.bodySmall),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            '·',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        showDeadline && report.isOpen
            ? SlaLabel(report: report)
            : PostedLabel(posted: report.createdAt),
      ],
    );
  }
}

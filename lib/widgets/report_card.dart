import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/time_format.dart';
import '../models/report.dart';
import 'app_card.dart';
import 'report_image.dart';
import 'sla_label.dart';
import 'status_badge.dart';
import 'upvote_button.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;
  final Widget? footer;

  const ReportCard({super.key, required this.report, this.onTap, this.footer});

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
        report.isOpen
            ? SlaLabel(report: report)
            : Text(
                shortTimeAgo(report.createdAt),
                style: AppTextStyles.bodySmall,
              ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_shadows.dart';
import '../core/utils/time_format.dart';
import '../core/theme/app_spacing.dart';
import '../models/report.dart';
import 'motion/pressable.dart';
import 'report_image.dart';
import 'sla_chip.dart';
import 'status_badge.dart';
import 'upvote_button.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;
  final Widget? footer;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildContent(),
            if (footer != null)
              Padding(
                padding: AppSpacing.cardPaddingSmall,
                child: footer,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ReportImage(report: report),
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: StatusBadge(status: report.status, compact: true),
          ),
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: SlaChip(report: report),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      color: AppColors.cardContentBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        report.title,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '\u2022',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Text(
                      shortTimeAgo(report.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.horizontalGapMd,
              UpvoteButton(report: report),
            ],
          ),
          AppSpacing.verticalGapXs,
          Text(
            report.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

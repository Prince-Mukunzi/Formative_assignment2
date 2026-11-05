import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../models/report.dart';
import 'status_badge.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildImage()),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: report.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              color: AppColors.chipBackground,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            errorWidget: (_, _, _) => Container(
              color: AppColors.chipBackground,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: StatusBadge(status: report.status, compact: true),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              report.title,
              style: AppTextStyles.labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSpacing.horizontalGapSm,
          Icon(
            HugeIcons.strokeRoundedThumbsUp,
            size: 14,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 3),
          Text(
            '${report.upvotes}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

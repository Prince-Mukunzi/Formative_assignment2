import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/report.dart';
import '../../widgets/status_badge.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late bool _hasUpvoted;
  late int _upvoteCount;

  @override
  void initState() {
    super.initState();
    _hasUpvoted = widget.report.hasUpvoted;
    _upvoteCount = widget.report.upvotes;
  }

  void _toggleUpvote() {
    setState(() {
      _hasUpvoted = !_hasUpvoted;
      _upvoteCount += _hasUpvoted ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusAndMeta(),
                _buildDescription(),
                _buildLocationCard(),
                _buildReporterCard(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'report-image-${widget.report.id}',
          child: CachedNetworkImage(
            imageUrl: widget.report.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: AppColors.chipBackground),
            errorWidget: (_, _, _) =>
                Container(color: AppColors.chipBackground),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusAndMeta() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(status: widget.report.status),
              const Spacer(),
              Text(
                timeago.format(widget.report.createdAt),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          AppSpacing.verticalGapLg,
          Text(
            widget.report.title,
            style: AppTextStyles.heading2,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Text(
        widget.report.description,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildLocationCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(
              HugeIcons.strokeRoundedLocation01,
              size: 20,
              color: AppColors.accent,
            ),
          ),
          AppSpacing.horizontalGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location', style: AppTextStyles.labelSmall),
                AppSpacing.verticalGapXs,
                Text(
                  widget.report.location,
                  style: AppTextStyles.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _buildReporterCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Center(
              child: Text(
                widget.report.reportedByName[0],
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
          AppSpacing.horizontalGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reported by', style: AppTextStyles.labelSmall),
                AppSpacing.verticalGapXs,
                Text(
                  widget.report.reportedByName,
                  style: AppTextStyles.labelMedium,
                ),
              ],
            ),
          ),
          Text(
            widget.report.category.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _toggleUpvote,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _hasUpvoted ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _hasUpvoted ? AppColors.accent : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      HugeIcons.strokeRoundedThumbsUp,
                      size: 20,
                      color: _hasUpvoted
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
                    AppSpacing.horizontalGapSm,
                    Text(
                      'Upvote  $_upvoteCount',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _hasUpvoted
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.horizontalGapMd,
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              HugeIcons.strokeRoundedShare01,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

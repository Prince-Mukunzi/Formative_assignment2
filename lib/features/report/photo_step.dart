import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../models/report_category.dart';
import '../../widgets/app_card.dart';
import '../../widgets/menu_row.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/report_image.dart';
import '../../widgets/tinted_icon.dart';

class PhotoStep extends StatelessWidget {
  final String path;
  final ReportCategory category;
  final String title;
  final String location;
  final VoidCallback onCamera;
  final VoidCallback onLibrary;
  final VoidCallback onChange;

  const PhotoStep({
    super.key,
    required this.path,
    required this.category,
    required this.title,
    required this.location,
    required this.onCamera,
    required this.onLibrary,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (path.isEmpty) ...[
          _CameraCard(onTap: onCamera),
          AppSpacing.verticalGapMd,
          CardList(
            children: [
              MenuRow(
                icon: HugeIcons.strokeRoundedImage01,
                label: 'Choose from library',
                onTap: onLibrary,
              ),
            ],
          ),
        ] else
          _Preview(path: path, icon: category.icon, onChange: onChange),
        AppSpacing.verticalGapMd,
        AppCard(
          child: Row(
            children: [
              TintedIcon(icon: category.icon),
              AppSpacing.horizontalGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium,
                    ),
                    AppSpacing.verticalGapXs,
                    Text(
                      '${category.label}  ·  $location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalGapLg,
      ],
    );
  }
}

class _CameraCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CameraCard({required this.onTap});

  static const _aspectRatio = 1.45;
  static const _lensSize = 72.0;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.navy,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: CustomPaint(
            painter: const _ViewfinderPainter(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: _lensSize,
                  height: _lensSize,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedCamera01,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.verticalGapMd,
                Text(
                  'Take a photo',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                AppSpacing.verticalGapXs,
                Text(
                  '+${XpReason.photoAdded.xp} XP',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onPrimaryMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter();

  static const _inset = 22.0;
  static const _arm = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.onPrimaryMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final frame = (Offset.zero & size).deflate(_inset);
    final corners = [
      (frame.topLeft, 1.0, 1.0),
      (frame.topRight, -1.0, 1.0),
      (frame.bottomLeft, 1.0, -1.0),
      (frame.bottomRight, -1.0, -1.0),
    ];
    for (final (corner, x, y) in corners) {
      canvas.drawLine(corner, corner.translate(_arm * x, 0), paint);
      canvas.drawLine(corner, corner.translate(0, _arm * y), paint);
    }
  }

  @override
  bool shouldRepaint(_ViewfinderPainter oldDelegate) => false;
}

class _Preview extends StatelessWidget {
  final String path;
  final IconData icon;
  final VoidCallback onChange;

  const _Preview({
    required this.path,
    required this.icon,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ReportImage.path(path, icon: icon),
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Pressable(
                onTap: onChange,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text('Change', style: AppTextStyles.labelMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

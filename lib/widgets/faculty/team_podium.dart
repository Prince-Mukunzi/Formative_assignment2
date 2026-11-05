import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/department.dart';
import '../motion/spring_in.dart';
import '../motion/spring_value.dart';

class TeamPodium extends StatelessWidget {
  final List<DepartmentScore> top;
  final Department? highlight;

  const TeamPodium({super.key, required this.top, this.highlight});

  @override
  Widget build(BuildContext context) {
    Widget step(int place) {
      final score = top[place - 1];
      return Expanded(
        child: _Step(
          key: ValueKey(score.department.id),
          place: place,
          score: score,
          highlighted: score.department.id == highlight?.id,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: AppSpacing.xs,
      children: [
        if (top.length > 1) step(2),
        if (top.isNotEmpty) step(1),
        if (top.length > 2) step(3),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int place;
  final DepartmentScore score;
  final bool highlighted;

  const _Step({
    super.key,
    required this.place,
    required this.score,
    required this.highlighted,
  });

  static const _heights = [150.0, 112.0, 84.0];
  static const _delays = [320, 160, 0];

  @override
  Widget build(BuildContext context) {
    final first = place == 1;
    final height = _heights[place - 1];
    final delay = Duration(milliseconds: _delays[place - 1]);
    final labelStyle = highlighted
        ? AppTextStyles.labelMedium.copyWith(color: AppColors.brand)
        : AppTextStyles.labelMedium;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first)
          SpringIn(
            delay: delay + const Duration(milliseconds: 260),
            spring: AppSprings.slam,
            fromScale: 0.2,
            offsetY: -24,
            child: const Icon(
              HugeIcons.strokeRoundedCrown,
              size: 30,
              color: AppColors.brand,
            ),
          ),
        AppSpacing.verticalGapXs,
        SpringIn(
          delay: delay + const Duration(milliseconds: 120),
          spring: AppSprings.bouncy,
          fromScale: 0.5,
          offsetY: 24,
          child: _Avatar(
            icon: score.department.icon,
            size: first ? 68 : 54,
            highlighted: highlighted,
          ),
        ),
        AppSpacing.verticalGapSm,
        Text(
          score.department.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: labelStyle,
        ),
        Text('${score.points} pts', style: AppTextStyles.bodySmall),
        AppSpacing.verticalGapSm,
        SpringValue(
          value: 1,
          from: 0,
          delay: delay,
          spring: AppSprings.bouncy,
          builder: (_, t, child) => SizedBox(
            height: height * t.clamp(0.0, 1.1),
            child: ClipRect(
              child: OverflowBox(
                minHeight: height,
                maxHeight: height,
                alignment: Alignment.topCenter,
                child: child,
              ),
            ),
          ),
          child: CustomPaint(
            painter: _BlockPainter(
              gradient: first ? AppColors.podiumFirst : AppColors.podiumRest,
            ),
            child: Center(
              child: Text(
                '$place',
                style: AppTextStyles.display.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool highlighted;

  const _Avatar({
    required this.icon,
    required this.size,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(
          color: highlighted ? AppColors.brand : AppColors.primary,
          width: 2.5,
        ),
      ),
      child: Icon(
        icon,
        size: size * 0.46,
        color: highlighted ? AppColors.brand : AppColors.primary,
      ),
    );
  }
}

class _BlockPainter extends CustomPainter {
  final Gradient gradient;

  const _BlockPainter({required this.gradient});

  static const _capHeight = 14.0;
  static const _capInset = 10.0;
  static const _cornerRadius = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final paint = Paint()..shader = gradient.createShader(bounds);
    final front = Rect.fromLTRB(0, _capHeight, size.width, size.height);
    canvas.drawRect(front, paint);

    final cap = Path()
      ..moveTo(_capInset + _cornerRadius, 0)
      ..lineTo(size.width - _capInset - _cornerRadius, 0)
      ..quadraticBezierTo(
        size.width - _capInset,
        0,
        size.width - _capInset + 2,
        3,
      )
      ..lineTo(size.width, _capHeight)
      ..lineTo(0, _capHeight)
      ..lineTo(_capInset - 2, 3)
      ..quadraticBezierTo(_capInset, 0, _capInset + _cornerRadius, 0)
      ..close();
    canvas.drawPath(cap, paint);
    canvas.drawPath(cap, Paint()..color = AppColors.onPrimaryFaint);
  }

  @override
  bool shouldRepaint(_BlockPainter oldDelegate) =>
      oldDelegate.gradient != gradient;
}

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
    return Podium(
      entries: [
        for (final score in top)
          PodiumEntry(
            id: score.department.id,
            label: score.department.label,
            caption: '${score.points} pts',
            icon: score.department.icon,
            highlighted: score.department.id == highlight?.id,
          ),
      ],
    );
  }
}

class PodiumEntry {
  final String id;
  final String label;
  final String caption;
  final IconData? icon;
  final bool highlighted;

  const PodiumEntry({
    required this.id,
    required this.label,
    required this.caption,
    this.icon,
    this.highlighted = false,
  });
}

/// Top three on stepped blocks. [compact] shrinks it to sit under a card.
class Podium extends StatelessWidget {
  final List<PodiumEntry> entries;
  final bool compact;

  const Podium({super.key, required this.entries, this.compact = false});

  static const _compactScale = 0.5;
  static const _compactWidth = 92.0;

  @override
  Widget build(BuildContext context) {
    Widget step(int place) {
      final block = _Step(
        key: ValueKey(entries[place - 1].id),
        place: place,
        entry: entries[place - 1],
        scale: compact ? _compactScale : 1,
      );
      return compact
          ? SizedBox(width: _compactWidth, child: block)
          : Expanded(child: block);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: AppSpacing.xs,
      children: [
        if (entries.length > 1) step(2),
        if (entries.isNotEmpty) step(1),
        if (entries.length > 2) step(3),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int place;
  final PodiumEntry entry;
  final double scale;

  const _Step({
    super.key,
    required this.place,
    required this.entry,
    required this.scale,
  });

  static const _heights = [150.0, 112.0, 84.0];
  static const _delays = [320, 160, 0];

  @override
  Widget build(BuildContext context) {
    final first = place == 1;
    final height = _heights[place - 1] * scale;
    final delay = Duration(milliseconds: _delays[place - 1]);
    final small = scale < 1;
    final highlighted = entry.highlighted;
    final labelStyle =
        (small ? AppTextStyles.labelSmall : AppTextStyles.labelMedium).copyWith(
          color: highlighted ? AppColors.brand : null,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first)
          SpringIn(
            delay: delay + const Duration(milliseconds: 260),
            spring: AppSprings.slam,
            fromScale: 0.2,
            offsetY: -24,
            child: Icon(
              HugeIcons.strokeRoundedCrown,
              size: 30 * scale,
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
            icon: entry.icon,
            initial: entry.label.isEmpty ? '?' : entry.label[0].toUpperCase(),
            size: (first ? 68 : 54) * (small ? 0.75 : 1),
            highlighted: highlighted,
          ),
        ),
        AppSpacing.verticalGapSm,
        Text(
          entry.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: labelStyle,
        ),
        Text(entry.caption, style: AppTextStyles.bodySmall),
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
                style: (small ? AppTextStyles.heading2 : AppTextStyles.display)
                    .copyWith(color: AppColors.textOnPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final IconData? icon;
  final String initial;
  final double size;
  final bool highlighted;

  const _Avatar({
    required this.icon,
    required this.initial,
    required this.size,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? AppColors.brand : AppColors.primary;
    final icon = this.icon;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: color, width: 2.5),
      ),
      child: icon != null
          ? Icon(icon, size: size * 0.46, color: color)
          : Text(
              initial,
              style: AppTextStyles.heading2.copyWith(
                color: color,
                fontSize: size * 0.42,
              ),
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

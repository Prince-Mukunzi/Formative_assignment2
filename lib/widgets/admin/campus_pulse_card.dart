import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/accountability.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../models/sla.dart';
import '../banner_stat.dart';
import '../gradient_banner.dart';
import '../motion/pressable.dart';
import '../motion/rolling_number.dart';
import '../motion/spring_value.dart';

class CampusPulseCard extends StatelessWidget {
  final List<Report> reports;
  final List<DepartmentScore> teams;
  final DateTime now;
  final ValueChanged<DepartmentScore> onTeamTap;

  const CampusPulseCard({
    super.key,
    required this.reports,
    required this.teams,
    required this.now,
    required this.onTeamTap,
  });

  @override
  Widget build(BuildContext context) {
    final reading = PressureReading.of(reports, now);
    final counted = reports
        .where((r) => r.status != ReportStatus.declined)
        .toList();
    final open = counted.where((r) => r.isOpen).toList();
    final resolved = counted.length - open.length;
    final percent = counted.isEmpty ? 0 : resolved * 100 ~/ counted.length;
    final calm = open.where((r) => r.slaStateAt(now) != SlaState.overdue);
    return GradientBanner(
      gradient: AppColors.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RollingNumber(
                value: percent,
                suffix: '%',
                style: AppTextStyles.display.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
              AppSpacing.horizontalGapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mood(reading.overdue, open.length),
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      '$resolved of ${counted.length} resolved',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onPrimaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapLg,
          _StatusBar(
            resolved: resolved,
            active: calm
                .where((r) => r.status == ReportStatus.inProgress)
                .length,
            pending: calm
                .where((r) => r.status != ReportStatus.inProgress)
                .length,
            overdue: reading.overdue,
          ),
          AppSpacing.verticalGapXl,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final team in teams)
                _TeamOrb(score: team, onTap: () => onTeamTap(team)),
            ],
          ),
          AppSpacing.verticalGapXl,
          Row(
            children: [
              BannerStat(
                icon: HugeIcons.strokeRoundedTask01,
                value: open.length,
                label: 'Open',
              ),
              BannerStat(
                icon: HugeIcons.strokeRoundedAlert02,
                value: reading.overdue,
                label: 'Overdue',
              ),
              BannerStat(
                icon: HugeIcons.strokeRoundedClock01,
                value: reading.dueWithin24h,
                label: 'Due',
              ),
              BannerStat(
                icon: HugeIcons.strokeRoundedUserGroup,
                value: reading.waitingStudents,
                label: 'Waiting',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _mood(int overdue, int open) {
    if (overdue == 1) return '1 fire to put out';
    if (overdue > 1) return '$overdue fires to put out';
    return open == 0 ? 'All clear' : 'Keep them moving';
  }
}

class _StatusBar extends StatelessWidget {
  final int resolved;
  final int active;
  final int pending;
  final int overdue;

  const _StatusBar({
    required this.resolved,
    required this.active,
    required this.pending,
    required this.overdue,
  });

  static const _height = 10.0;

  @override
  Widget build(BuildContext context) {
    final segments = [
      (resolved, AppColors.textOnPrimary),
      (active, AppColors.onPrimaryMuted),
      (pending, AppColors.onPrimaryFaint),
      (overdue, AppColors.brand),
    ].where((segment) => segment.$1 > 0).toList();
    if (segments.isEmpty) return const SizedBox(height: _height);
    return SpringValue(
      value: 1,
      from: 0,
      delay: const Duration(milliseconds: 150),
      spring: AppSprings.soft,
      builder: (_, t, child) => ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: t.clamp(0.0, 1.0),
          child: child,
        ),
      ),
      child: SizedBox(
        height: _height,
        child: Row(
          spacing: AppSpacing.xs,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (count, color) in segments)
              Expanded(
                flex: count,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamOrb extends StatelessWidget {
  final DepartmentScore score;
  final VoidCallback onTap;

  const _TeamOrb({required this.score, required this.onTap});

  static const _size = 42.0;
  static const _badgeSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final late = score.overdue > 0;
    final orb = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: late ? AppColors.brand : AppColors.onPrimaryWash,
        border: late ? null : Border.all(color: AppColors.onPrimaryFaint),
      ),
      child: Icon(
        score.department.icon,
        size: 20,
        color: AppColors.textOnPrimary,
      ),
    );
    final pulsing = late && !MediaQuery.disableAnimationsOf(context);
    return Pressable(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          pulsing
              ? orb
                    .animate(onPlay: (controller) => controller.repeat())
                    .scaleXY(begin: 1, end: 1.1, duration: 500.ms)
                    .then()
                    .scaleXY(begin: 1.1, end: 1, duration: 700.ms)
              : orb,
          if (score.open > 0)
            Positioned(
              top: -AppSpacing.xs,
              right: -AppSpacing.xs,
              child: Container(
                width: _badgeSize,
                height: _badgeSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
                child: Text(
                  '${score.open}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

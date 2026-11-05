import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../widgets/app_button.dart';
import '../../widgets/game/rank_emblem.dart';
import '../../widgets/game/xp_bar.dart';
import '../../widgets/motion/confetti.dart';
import '../../widgets/motion/kick_controller.dart';
import '../../widgets/motion/rolling_number.dart';
import '../../widgets/motion/spring_in.dart';

class RewardOverlay extends StatefulWidget {
  final RewardMoment moment;

  const RewardOverlay({super.key, required this.moment});

  static Future<void> show(BuildContext context, RewardMoment moment) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: AppColors.heroOverlayClear,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) => RewardOverlay(moment: moment),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<RewardOverlay> createState() => _RewardOverlayState();
}

class _RewardOverlayState extends State<RewardOverlay>
    with SingleTickerProviderStateMixin {
  static const _emblemSize = 112.0;
  static const _firstBeat = Duration(milliseconds: 260);
  static const _barFill = Duration(milliseconds: 650);
  static const _rankBeat = Duration(milliseconds: 1250);

  final _timers = <Timer>[];
  late final _emblemKick = KickController(
    vsync: this,
    rest: 1,
    spring: AppSprings.slam,
  );
  late Rank _rank = Rank.forXp(widget.moment.xpBefore);
  late double _progress = _rank.progressAt(widget.moment.xpBefore);
  bool _rankedUp = false;

  @override
  void initState() {
    super.initState();
    _after(_firstBeat, () {
      HapticFeedback.mediumImpact();
      _emblemKick.kick(8);
      _celebrate();
    });
    final moment = widget.moment;
    _after(_barFill, () {
      setState(() {
        _progress = moment.rankUp != null
            ? 1
            : Rank.forXp(moment.xpAfter).progressAt(moment.xpAfter);
      });
    });
    if (moment.rankUp != null) _after(_rankBeat, _applyRankUp);
  }

  void _after(Duration delay, VoidCallback action) {
    _timers.add(
      Timer(delay, () {
        if (mounted) action();
      }),
    );
  }

  void _celebrate() {
    final size = MediaQuery.sizeOf(context);
    Confetti.burst(context, origin: Offset(size.width / 2, size.height * 0.42));
  }

  void _applyRankUp() {
    HapticFeedback.heavyImpact();
    _emblemKick.kick(18);
    _celebrate();
    final after = widget.moment.xpAfter;
    setState(() {
      _rankedUp = true;
      _rank = Rank.forXp(after);
      _progress = _rank.progressAt(after);
    });
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _emblemKick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moment = widget.moment;
    final badgeOnly =
        moment.badges.isNotEmpty &&
        !moment.events.any((event) => event.reason.isMajor);
    final headline = _rankedUp
        ? 'RANK UP'
        : badgeOnly
        ? 'BADGE UNLOCKED'
        : 'BOUNTY EARNED';
    return Material(
      color: AppColors.heroOverlayClear,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: ColoredBox(
            color: AppColors.scrim,
            child: SafeArea(
              child: Padding(
                padding: AppSpacing.screenAll,
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      headline,
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.rewardBright,
                        fontSize: 13,
                        letterSpacing: 3,
                      ),
                    ),
                    AppSpacing.verticalGapXxl,
                    _buildEmblem(),
                    AppSpacing.verticalGapXl,
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        _rank.label,
                        key: ValueKey(_rank),
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                    AppSpacing.verticalGapMd,
                    if (moment.gained > 0)
                      RollingNumber(
                        value: moment.gained,
                        from: 0,
                        delay: _firstBeat,
                        prefix: '+',
                        suffix: ' XP',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.rewardBright,
                        ),
                      ),
                    AppSpacing.verticalGapLg,
                    _buildBar(),
                    AppSpacing.verticalGapXxl,
                    _buildBreakdown(),
                    if (moment.badges.isNotEmpty) ...[
                      AppSpacing.verticalGapLg,
                      _buildBadges(),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Keep hunting',
                        isFilled: false,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmblem() {
    return AnimatedBuilder(
      animation: _emblemKick,
      builder: (_, child) =>
          Transform.scale(scale: _emblemKick.value, child: child),
      child: SpringIn(
        spring: AppSprings.slam,
        fromScale: 0.2,
        offsetY: 0,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: RankEmblem(
            key: ValueKey(_rank),
            rank: _rank,
            size: _emblemSize,
          ),
        ),
      ),
    );
  }

  Widget _buildBar() {
    final next = _rank.next;
    final xp = widget.moment.xpAfter;
    return Column(
      children: [
        // A new key snaps the fill to empty when the rank rolls over.
        XpBar(
          key: ValueKey(_rank),
          progress: _progress,
          from: _rankedUp ? 0 : null,
          height: 10,
        ),
        AppSpacing.verticalGapSm,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$xp XP',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onPrimaryMuted,
              ),
            ),
            if (next != null)
              Text(
                '${next.threshold - xp} to ${next.label}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onPrimaryMuted,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdown() {
    final counts = <XpReason, int>{};
    for (final event in widget.moment.events) {
      counts[event.reason] = (counts[event.reason] ?? 0) + 1;
    }
    final entries = counts.entries.toList();
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          SpringIn(
            delay: Duration(milliseconds: 500 + i * 90),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entries[i].key.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onPrimaryMuted,
                      ),
                    ),
                  ),
                  Text(
                    '+${entries[i].key.xp * entries[i].value}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadges() {
    final badges = widget.moment.badges;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < badges.length; i++)
          SpringIn(
            delay: Duration(milliseconds: 1400 + i * 140),
            spring: AppSprings.slam,
            fromScale: 0.3,
            offsetY: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.rewardLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badges[i].icon, size: 16, color: AppColors.rewardDeep),
                  AppSpacing.horizontalGapSm,
                  Text(
                    'New badge: ${badges[i].label}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

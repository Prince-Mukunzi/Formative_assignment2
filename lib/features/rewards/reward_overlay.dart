import 'dart:async';

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
  static const _emblemSize = 88.0;
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
    final next = _rank.next;
    return Material(
      color: AppColors.heroOverlayClear,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.signature),
          child: SafeArea(
            child: Padding(
              padding: AppSpacing.screenAll,
              child: Column(
                children: [
                  const Spacer(),
                  _buildEmblem(),
                  AppSpacing.verticalGapXl,
                  if (moment.gained > 0)
                    RollingNumber(
                      value: moment.gained,
                      from: 0,
                      delay: _firstBeat,
                      prefix: '+',
                      suffix: ' XP',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  AppSpacing.verticalGapSm,
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      _rankedUp ? 'Rank up: ${_rank.label}' : _rank.label,
                      key: ValueKey(_rankedUp),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  AppSpacing.verticalGapXl,
                  // A new key snaps the fill to empty when the rank rolls over.
                  XpBar(
                    key: ValueKey(_rank),
                    progress: _progress,
                    from: _rankedUp ? 0 : null,
                    trackColor: AppColors.onPrimaryFaint,
                    fillColor: AppColors.textOnPrimary,
                  ),
                  AppSpacing.verticalGapSm,
                  if (next != null)
                    Text(
                      '${next.threshold - moment.xpAfter} to ${next.label}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onPrimaryMuted,
                      ),
                    ),
                  if (moment.badges.isNotEmpty) ...[
                    AppSpacing.verticalGapXl,
                    _buildBadges(),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: 'Keep hunting',
                      isInverse: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
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

  Widget _buildBadges() {
    final badges = widget.moment.badges;
    return Column(
      children: [
        for (var i = 0; i < badges.length; i++)
          SpringIn(
            delay: Duration(milliseconds: 1400 + i * 140),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    badges[i].icon,
                    size: 16,
                    color: AppColors.textOnPrimary,
                  ),
                  AppSpacing.horizontalGapSm,
                  Text(
                    badges[i].label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textOnPrimary,
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

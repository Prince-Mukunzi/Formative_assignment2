import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../motion/spring_in.dart';

/// Every rank on one swipeable track, opened at the student's current rank.
class RankLadder extends StatefulWidget {
  final int xp;

  const RankLadder({super.key, required this.xp});

  @override
  State<RankLadder> createState() => _RankLadderState();
}

class _RankLadderState extends State<RankLadder> {
  static const _tileWidth = 96.0;

  late final _scroll = ScrollController(
    initialScrollOffset:
        _tileWidth *
        (Rank.forXp(widget.xp).index - 1).clamp(0, Rank.values.length),
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = Rank.forXp(widget.xp);
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rank in Rank.values)
            SpringIn(
              delay: Duration(milliseconds: 60 * rank.index),
              spring: AppSprings.bouncy,
              child: SizedBox(
                width: _tileWidth,
                child: _RankStop(
                  rank: rank,
                  state: rank == current
                      ? _StopState.current
                      : rank.index < current.index
                      ? _StopState.passed
                      : _StopState.locked,
                  isFirst: rank.index == 0,
                  isLast: rank.next == null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _StopState { passed, current, locked }

class _RankStop extends StatelessWidget {
  final Rank rank;
  final _StopState state;
  final bool isFirst;
  final bool isLast;

  const _RankStop({
    required this.rank,
    required this.state,
    required this.isFirst,
    required this.isLast,
  });

  static const _size = 52.0;

  @override
  Widget build(BuildContext context) {
    final reached = state != _StopState.locked;
    final rail = SizedBox(
      height: 3,
      child: ColoredBox(
        color: reached ? AppColors.primary : AppColors.chipBackground,
      ),
    );
    return Column(
      children: [
        SizedBox(
          height: _size,
          child: Row(
            children: [
              Expanded(child: isFirst ? const SizedBox() : rail),
              _Emblem(rank: rank, state: state, size: _size),
              Expanded(
                child: isLast
                    ? const SizedBox()
                    : SizedBox(
                        height: 3,
                        child: ColoredBox(
                          color: state == _StopState.passed
                              ? AppColors.primary
                              : AppColors.chipBackground,
                        ),
                      ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalGapSm,
        Text(
          rank.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall.copyWith(
            color: switch (state) {
              _StopState.current => AppColors.brand,
              _StopState.passed => AppColors.textPrimary,
              _StopState.locked => AppColors.textTertiary,
            },
          ),
        ),
        Text('${rank.threshold} XP', style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _Emblem extends StatelessWidget {
  final Rank rank;
  final _StopState state;
  final double size;

  const _Emblem({required this.rank, required this.state, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: state == _StopState.locked ? null : AppColors.navy,
        color: state == _StopState.locked ? AppColors.surface : null,
        border: Border.all(
          color: switch (state) {
            _StopState.current => AppColors.brand,
            _StopState.passed => AppColors.primary,
            _StopState.locked => AppColors.cardBorder,
          },
          width: state == _StopState.current ? 3 : 1.5,
        ),
      ),
      child: Icon(
        rank.icon,
        size: size * 0.44,
        color: state == _StopState.locked
            ? AppColors.textTertiary
            : AppColors.textOnPrimary,
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../models/session.dart';
import '../../providers/reports_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/motion/confetti.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/spring_in.dart';
import '../../widgets/report_image.dart';
import '../../widgets/sla_chip.dart';

class TriageScreen extends ConsumerStatefulWidget {
  const TriageScreen({super.key});

  @override
  ConsumerState<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends ConsumerState<TriageScreen>
    with TickerProviderStateMixin {
  static const _commitFraction = 0.32;
  static const _flingVelocity = 750.0;
  static const _flySpring = SpringDescription(
    mass: 1,
    stiffness: 240,
    damping: 26,
  );

  late final AnimationController _x = AnimationController.unbounded(
    vsync: this,
  );
  late final AnimationController _y = AnimationController.unbounded(
    vsync: this,
  );
  late final Listenable _position = Listenable.merge([_x, _y]);

  // Snapshotted so the deck order stays put while cards are being decided.
  late final List<Report> _deck = _loadDeck();
  int _index = 0;
  bool _flying = false;
  bool _pastThreshold = false;

  List<Report> _loadDeck() {
    final session = ref.read(sessionProvider);
    if (session is! FacultySession) return const [];
    return ref
        .read(reportsProvider)
        .where(
          (r) =>
              r.department == session.department &&
              r.status == ReportStatus.awaitingApproval,
        )
        .toList();
  }

  double get _width => MediaQuery.sizeOf(context).width;

  void _onPanUpdate(DragUpdateDetails details) {
    if (_flying) return;
    _x.stop();
    _y.stop();
    _x.value += details.delta.dx;
    _y.value += details.delta.dy;
    final past = _x.value.abs() > _width * _commitFraction;
    if (past != _pastThreshold) {
      _pastThreshold = past;
      HapticFeedback.selectionClick();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_flying) return;
    final velocity = details.velocity.pixelsPerSecond;
    final thrown = velocity.dx.abs() > _flingVelocity;
    final dragged = _x.value.abs() > _width * _commitFraction;
    if (thrown || dragged) {
      final direction = thrown ? velocity.dx.sign : _x.value.sign;
      _fly(direction, velocity);
      return;
    }
    _pastThreshold = false;
    _spring(_x, 0, velocity.dx, AppSprings.bouncy);
    _spring(_y, 0, velocity.dy, AppSprings.bouncy);
  }

  TickerFuture _spring(
    AnimationController controller,
    double target,
    double velocity,
    SpringDescription spring,
  ) {
    return controller.animateWith(
      SpringSimulation(
        spring,
        controller.value,
        target,
        velocity,
        tolerance: AppSprings.pixelTolerance,
      ),
    );
  }

  void _fly(double direction, Offset velocity) {
    setState(() => _flying = true);
    HapticFeedback.mediumImpact();
    final report = _deck[_index];
    _spring(_y, _y.value + velocity.dy * 0.15, velocity.dy, _flySpring);
    _spring(_x, direction * _width * 1.5, velocity.dx, _flySpring).whenComplete(
      () {
        if (!mounted) return;
        final reports = ref.read(reportsProvider.notifier);
        if (direction > 0) {
          reports.approve(report.id);
        } else {
          reports.decline(report.id);
        }
        _x.value = 0;
        _y.value = 0;
        _pastThreshold = false;
        setState(() {
          _flying = false;
          _index++;
        });
        if (_index == _deck.length) _celebrateClear();
      },
    );
  }

  void _celebrateClear() {
    HapticFeedback.heavyImpact();
    final size = MediaQuery.sizeOf(context);
    Confetti.burst(
      context,
      origin: Offset(size.width / 2, size.height * 0.6),
      colors: AppColors.confettiOnLight,
    );
  }

  @override
  void dispose() {
    _x.dispose();
    _y.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _deck.length - _index;
    return Scaffold(
      appBar: AppBar(
        leading: Pressable(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text('Triage', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: remaining == 0
            ? const _DeckCleared()
            : Column(
                children: [
                  Text(
                    '$remaining waiting for a decision',
                    style: AppTextStyles.subtitle,
                  ),
                  AppSpacing.verticalGapLg,
                  Expanded(child: _buildDeck()),
                  AppSpacing.verticalGapLg,
                  _buildButtons(),
                  AppSpacing.verticalGapLg,
                ],
              ),
      ),
    );
  }

  Widget _buildDeck() {
    final hasNext = _index + 1 < _deck.length;
    return Padding(
      padding: AppSpacing.screenPadding,
      child: AnimatedBuilder(
        animation: _position,
        builder: (context, _) {
          final drag = (_x.value.abs() / (_width * _commitFraction)).clamp(
            0.0,
            1.0,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              if (hasNext)
                Transform.translate(
                  offset: Offset(0, AppSpacing.lg * (1 - drag)),
                  child: Transform.scale(
                    scale: 0.94 + 0.06 * drag,
                    child: _TriageCard(report: _deck[_index + 1]),
                  ),
                ),
              GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Transform.translate(
                  offset: Offset(_x.value, _y.value * 0.5),
                  child: Transform.rotate(
                    angle: _x.value / _width * math.pi / 9,
                    alignment: const Alignment(0, 1.4),
                    child: _TriageCard(
                      key: ValueKey(_deck[_index].id),
                      report: _deck[_index],
                      approveOpacity: (_x.value / 80).clamp(0.0, 1.0),
                      declineOpacity: (-_x.value / 80).clamp(0.0, 1.0),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DecisionButton(
          icon: HugeIcons.strokeRoundedCancel01,
          color: AppColors.error,
          label: 'Decline',
          onTap: _flying ? null : () => _fly(-1, const Offset(-600, 80)),
        ),
        const SizedBox(width: AppSpacing.xxxl * 2),
        _DecisionButton(
          icon: HugeIcons.strokeRoundedTick02,
          color: AppColors.resolved,
          label: 'Approve',
          onTap: _flying ? null : () => _fly(1, const Offset(600, 80)),
        ),
      ],
    );
  }
}

class _TriageCard extends StatelessWidget {
  final Report report;
  final double approveOpacity;
  final double declineOpacity;

  const _TriageCard({
    super.key,
    required this.report,
    this.approveOpacity = 0,
    this.declineOpacity = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        boxShadow: AppShadows.floating,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ReportImage(report: report)),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title, style: AppTextStyles.heading2),
                    AppSpacing.verticalGapSm,
                    Text(
                      report.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.verticalGapMd,
                    Text(
                      '${report.location}, ${report.affectedLabel}',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: AppSpacing.lg,
            right: AppSpacing.lg,
            child: SlaChip(report: report),
          ),
          _Stamp(
            label: 'APPROVE',
            color: AppColors.resolved,
            opacity: approveOpacity,
            alignment: Alignment.topLeft,
            angle: -0.2,
          ),
          _Stamp(
            label: 'DECLINE',
            color: AppColors.error,
            opacity: declineOpacity,
            alignment: Alignment.topRight,
            angle: 0.2,
          ),
        ],
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  final String label;
  final Color color;
  final double opacity;
  final Alignment alignment;
  final double angle;

  const _Stamp({
    required this.label,
    required this.color,
    required this.opacity,
    required this.alignment,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    if (opacity == 0) return const SizedBox.shrink();
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: 1.3 - 0.3 * opacity,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: color, width: 3),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.heading3.copyWith(color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const _DecisionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.86,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: AppShadows.floating,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          AppSpacing.verticalGapSm,
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _DeckCleared extends StatelessWidget {
  const _DeckCleared();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpringIn(
        spring: AppSprings.slam,
        fromScale: 0.5,
        offsetY: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              HugeIcons.strokeRoundedCheckmarkBadge01,
              size: 64,
              color: AppColors.resolved,
            ),
            AppSpacing.verticalGapLg,
            Text('Triage clear', style: AppTextStyles.heading2),
            AppSpacing.verticalGapXs,
            Text(
              'Nothing is waiting on a decision.',
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}

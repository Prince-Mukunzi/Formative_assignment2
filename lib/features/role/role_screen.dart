import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/session.dart';
import '../../providers/directory_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/menu_row.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/spring_in.dart';
import '../../widgets/motion/spring_value.dart';
import '../../widgets/motion/tilt_card.dart';

class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key});

  @override
  ConsumerState<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen> {
  static const _revealDuration = Duration(milliseconds: 520);

  bool _facultyOpen = false;
  Offset? _revealOrigin;

  void _enter(Session session, Offset origin) {
    if (_revealOrigin != null) return;
    HapticFeedback.mediumImpact();
    setState(() => _revealOrigin = origin);
    Future.delayed(_revealDuration, () {
      if (mounted) ref.read(sessionProvider.notifier).signIn(session);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildContent(),
            if (_revealOrigin != null) _Reveal(origin: _revealOrigin!),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.navy),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              const SpringIn(
                spring: AppSprings.slam,
                fromScale: 0.4,
                offsetY: 0,
                child: _Logo(),
              ),
              AppSpacing.verticalGapXxl,
              SpringIn(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  'Who are you?',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.textOnPrimary,
                    fontSize: 34,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SpringIn(
                delay: const Duration(milliseconds: 260),
                offsetY: 60,
                spring: AppSprings.bouncy,
                child: Builder(
                  builder: (cardContext) => _RoleCard(
                    icon: HugeIcons.strokeRoundedMortarboard01,
                    title: 'Student',
                    onTap: () =>
                        _enter(const StudentSession(), _centerOf(cardContext)),
                  ),
                ),
              ),
              AppSpacing.verticalGapLg,
              SpringIn(
                delay: const Duration(milliseconds: 340),
                offsetY: 60,
                spring: AppSprings.bouncy,
                child: _RoleCard(
                  icon: HugeIcons.strokeRoundedTeacher,
                  title: 'Faculty',
                  isOpen: _facultyOpen,
                  onTap: () => setState(() => _facultyOpen = !_facultyOpen),
                  expansion: _DepartmentPicker(onPicked: _enter),
                ),
              ),
              AppSpacing.verticalGapLg,
              SpringIn(
                delay: const Duration(milliseconds: 420),
                offsetY: 60,
                spring: AppSprings.bouncy,
                child: Builder(
                  builder: (cardContext) => _RoleCard(
                    icon: HugeIcons.strokeRoundedShield01,
                    title: 'Admin',
                    onTap: () =>
                        _enter(const AdminSession(), _centerOf(cardContext)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Offset _centerOf(BuildContext context) {
    final box = context.findRenderObject()! as RenderBox;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
      ),
      child: const Icon(
        HugeIcons.strokeRoundedBug01,
        size: 30,
        color: AppColors.brand,
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isOpen;
  final Widget? expansion;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isOpen = false,
    this.expansion,
  });

  @override
  Widget build(BuildContext context) {
    return TiltCard(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        ),
        child: Column(
          children: [
            Pressable(
              onTap: onTap,
              scale: 0.98,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.chipBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 22, color: AppColors.primary),
                    ),
                    AppSpacing.horizontalGapLg,
                    Expanded(child: Text(title, style: AppTextStyles.heading3)),
                    AppSpacing.horizontalGapSm,
                    SpringValue(
                      value: isOpen ? 1 : 0,
                      spring: AppSprings.bouncy,
                      builder: (_, t, child) => Transform.rotate(
                        angle: t * math.pi / 2,
                        child: child,
                      ),
                      child: const Icon(
                        HugeIcons.strokeRoundedArrowRight01,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (expansion != null)
              SpringValue(
                value: isOpen ? 1 : 0,
                spring: AppSprings.snappy,
                builder: (_, t, child) => ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: math.max(t, 0),
                    child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
                  ),
                ),
                child: expansion,
              ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentPicker extends ConsumerWidget {
  final void Function(Session session, Offset origin) onPicked;

  const _DepartmentPicker({required this.onPicked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(departmentsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          for (final department in departments) ...[
            const Divider(height: 1, color: AppColors.divider),
            Builder(
              builder: (rowContext) => MenuRow(
                icon: department.icon,
                label: department.label,
                onTap: () {
                  final box = rowContext.findRenderObject()! as RenderBox;
                  onPicked(
                    FacultySession(department.id),
                    box.localToGlobal(box.size.center(Offset.zero)),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  final Offset origin;

  const _Reveal({required this.origin});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final radius = size.longestSide * 1.3;
    return IgnorePointer(
      child: SpringValue(
        value: 1,
        from: 0,
        spring: AppSprings.soft,
        builder: (_, t, _) => CustomPaint(
          painter: _RevealPainter(origin: origin, radius: radius * t),
        ),
      ),
    );
  }
}

class _RevealPainter extends CustomPainter {
  final Offset origin;
  final double radius;

  const _RevealPainter({required this.origin, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(origin, radius, Paint()..color = AppColors.background);
  }

  @override
  bool shouldRepaint(_RevealPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

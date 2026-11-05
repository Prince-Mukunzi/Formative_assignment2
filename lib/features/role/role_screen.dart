import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/auth_gate.dart';
import '../../models/person.dart';
import '../../providers/auth_provider.dart';
import '../auth/sign_in_sheet.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/spring_in.dart';
import '../../widgets/motion/spring_value.dart';
import '../../widgets/motion/tilt_card.dart';
import '../../core/utils/app_haptics.dart';

class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key});

  @override
  ConsumerState<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen> {
  static const _revealDuration = Duration(milliseconds: 520);

  Offset? _revealOrigin;

  Future<void> _open(PersonRole role, BuildContext cardContext) async {
    if (_revealOrigin != null) return;
    final origin = _centerOf(cardContext);
    AppHaptics.lightImpact();
    ref.read(authGateProvider.notifier).clearNotice();
    final gate = await SignInSheet.show(context, role);
    if (!mounted || gate == null) return;
    final notifier = ref.read(authGateProvider.notifier);
    if (gate is! Ready) return notifier.release();
    AppHaptics.mediumImpact();
    setState(() => _revealOrigin = origin);
    Future.delayed(_revealDuration, notifier.release);
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
    final notice = switch (ref.watch(authGateProvider)) {
      SignedOut(:final notice) => notice,
      _ => null,
    };
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
                child: AppLogo(onDark: true),
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
                    onTap: () => _open(PersonRole.student, cardContext),
                  ),
                ),
              ),
              AppSpacing.verticalGapLg,
              SpringIn(
                delay: const Duration(milliseconds: 340),
                offsetY: 60,
                spring: AppSprings.bouncy,
                child: Builder(
                  builder: (cardContext) => _RoleCard(
                    icon: HugeIcons.strokeRoundedTeacher,
                    title: 'Faculty',
                    onTap: () => _open(PersonRole.faculty, cardContext),
                  ),
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
                    onTap: () => _open(PersonRole.admin, cardContext),
                  ),
                ),
              ),
              if (notice != null) ...[
                AppSpacing.verticalGapXl,
                SpringIn(
                  child: Text(
                    notice,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ],
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

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.onTap,
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
                    const Icon(
                      HugeIcons.strokeRoundedArrowRight01,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

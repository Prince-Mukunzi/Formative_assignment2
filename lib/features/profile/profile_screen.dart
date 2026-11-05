import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _headerHeight = 230.0;
  static const _statsOverlap = 44.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildHeader(context),
            Transform.translate(
              offset: const Offset(0, -_statsOverlap),
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    _buildStatsCard(),
                    AppSpacing.verticalGapXxl,
                    _buildMenuCard(),
                    AppSpacing.verticalGapXxl,
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: _headerHeight + top,
      padding: EdgeInsets.only(top: top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatar(),
          AppSpacing.verticalGapMd,
          Text(
            '${MockData.userName} Mukunzi',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          AppSpacing.verticalGapXs,
          Text(
            'p.niyomugab@alustudent.com',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: _statsOverlap / 2),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 3),
        boxShadow: AppShadows.floating,
      ),
      child: Center(
        child: Text(
          'PM',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
            fontSize: 30,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 400.ms);
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: const IntrinsicHeight(
        child: Row(
          children: [
            _StatTile(
              count: 8,
              label: 'Reports',
              icon: HugeIcons.strokeRoundedTask01,
              color: AppColors.accent,
              background: AppColors.accentLight,
            ),
            VerticalDivider(width: 1, color: AppColors.divider),
            _StatTile(
              count: 5,
              label: 'Resolved',
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              color: AppColors.resolved,
              background: AppColors.resolvedLight,
            ),
            VerticalDivider(width: 1, color: AppColors.divider),
            _StatTile(
              count: 42,
              label: 'Upvotes',
              icon: HugeIcons.strokeRoundedThumbsUp,
              color: AppColors.inProgress,
              background: AppColors.inProgressLight,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.08, end: 0, duration: 400.ms);
  }

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: const Column(
        children: [
          _MenuItem(
            icon: HugeIcons.strokeRoundedNotification02,
            label: 'Notifications',
            badge: 3,
          ),
          _MenuDivider(),
          _MenuItem(
            icon: HugeIcons.strokeRoundedSettings01,
            label: 'Settings',
          ),
          _MenuDivider(),
          _MenuItem(
            icon: HugeIcons.strokeRoundedInformationCircle,
            label: 'About',
          ),
          _MenuDivider(),
          _MenuItem(
            icon: HugeIcons.strokeRoundedCustomerService01,
            label: 'Help & Support',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms);
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              HugeIcons.strokeRoundedLogout01,
              size: 20,
              color: AppColors.error,
            ),
            AppSpacing.horizontalGapSm,
            Text(
              'Sign Out',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

class _StatTile extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatTile({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          AppSpacing.verticalGapSm,
          Text('$count', style: AppTextStyles.statNumber),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;

  const _MenuItem({required this.icon, required this.label, this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            AppSpacing.horizontalGapMd,
            Expanded(child: Text(label, style: AppTextStyles.labelMedium)),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '$badge',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.horizontalGapSm,
            ],
            const Icon(
              HugeIcons.strokeRoundedArrowRight01,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 68),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            AppSpacing.verticalGapXxl,
            _buildAvatar(),
            AppSpacing.verticalGapLg,
            Text(
              '${MockData.userName} Mukunzi',
              style: AppTextStyles.heading2,
            ),
            AppSpacing.verticalGapXs,
            Text(
              'p.niyomugab@alustudent.com',
              style: AppTextStyles.bodySmall,
            ),
            AppSpacing.verticalGapXxl,
            _buildStatsRow(),
            AppSpacing.verticalGapXxl,
            _buildMenuSection(),
            AppSpacing.verticalGapXxl,
            _buildLogoutButton(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Center(
        child: Text(
          'PM',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.textOnPrimary,
            fontSize: 32,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 400.ms);
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatTile(count: 8, label: 'Reports', icon: HugeIcons.strokeRoundedTask01),
        AppSpacing.horizontalGapMd,
        _StatTile(count: 5, label: 'Resolved', icon: HugeIcons.strokeRoundedCheckmarkCircle02),
        AppSpacing.horizontalGapMd,
        _StatTile(count: 42, label: 'Upvotes', icon: HugeIcons.strokeRoundedThumbsUp),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _MenuItem(
          icon: HugeIcons.strokeRoundedNotification02,
          label: 'Notifications',
          trailing: _buildBadge(3),
        ),
        _MenuItem(
          icon: HugeIcons.strokeRoundedSettings01,
          label: 'Settings',
        ),
        _MenuItem(
          icon: HugeIcons.strokeRoundedInformationCircle,
          label: 'About',
        ),
        _MenuItem(
          icon: HugeIcons.strokeRoundedCustomerService01,
          label: 'Help & Support',
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms);
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        icon: const Icon(HugeIcons.strokeRoundedLogout01, size: 20),
        label: const Text('Sign Out'),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

class _StatTile extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;

  const _StatTile({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.accent),
            AppSpacing.verticalGapSm,
            Text('$count', style: AppTextStyles.statNumber),
            AppSpacing.verticalGapXs,
            Text(label, style: AppTextStyles.statLabel),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
        title: Text(label, style: AppTextStyles.labelMedium),
        trailing: trailing ??
            const Icon(
              HugeIcons.strokeRoundedArrowRight01,
              size: 18,
              color: AppColors.textTertiary,
            ),
        onTap: () {},
      ),
    );
  }
}

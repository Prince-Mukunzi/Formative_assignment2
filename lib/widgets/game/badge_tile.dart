import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../tinted_icon.dart';

class BadgeTile extends StatelessWidget {
  final BadgeKind badge;
  final bool earned;

  const BadgeTile({super.key, required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TintedIcon(icon: badge.icon, accent: earned, muted: !earned),
        AppSpacing.verticalGapSm,
        Text(
          badge.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.labelSmall.copyWith(
            color: earned ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

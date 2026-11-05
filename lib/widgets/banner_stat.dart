import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'stat_tile.dart';

class BannerStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const BannerStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StatTile(
        icon: icon,
        value: value,
        label: label,
        iconColor: AppColors.onPrimaryMuted,
        valueColor: AppColors.textOnPrimary,
        labelColor: AppColors.onPrimaryMuted,
      ),
    );
  }
}

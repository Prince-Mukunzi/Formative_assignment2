import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../tinted_icon.dart';

class ToggleRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          if (icon != null) ...[
            TintedIcon(icon: icon),
            AppSpacing.horizontalGapMd,
          ],
          Expanded(child: Text(label, style: AppTextStyles.labelMedium)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

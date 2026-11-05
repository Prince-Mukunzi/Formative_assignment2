import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../models/report_status.dart';
import 'category_chip.dart';

class StatusFilterBar extends StatelessWidget {
  final ReportStatus? selected;
  final ValueChanged<ReportStatus?> onChanged;

  const StatusFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final status in ReportStatus.values) ...[
            AppSpacing.horizontalGapSm,
            CategoryChip(
              label: status.label,
              isSelected: selected == status,
              onTap: () => onChanged(status),
            ),
          ],
        ],
      ),
    );
  }
}

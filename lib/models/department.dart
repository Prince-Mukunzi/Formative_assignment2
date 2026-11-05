import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import 'report_category.dart';

enum Department {
  electrical('Electrical', HugeIcons.strokeRoundedFlash),
  plumbing('Plumbing', HugeIcons.strokeRoundedDroplet),
  facilities('Facilities', HugeIcons.strokeRoundedBuilding06);

  const Department(this.label, this.icon);
  final String label;
  final IconData icon;

  static Department forCategory(ReportCategory category) => switch (category) {
    ReportCategory.electricity => electrical,
    ReportCategory.water => plumbing,
    ReportCategory.facilities ||
    ReportCategory.furniture ||
    ReportCategory.sanitation ||
    ReportCategory.safety ||
    ReportCategory.all => facilities,
  };
}

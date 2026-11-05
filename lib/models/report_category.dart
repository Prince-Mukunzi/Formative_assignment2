import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';

enum ReportCategory {
  all('All', HugeIcons.strokeRoundedLayers01),
  electricity('Electricity', HugeIcons.strokeRoundedFlash),
  water('Water', HugeIcons.strokeRoundedDroplet),
  facilities('Facilities', HugeIcons.strokeRoundedBuilding06);

  const ReportCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

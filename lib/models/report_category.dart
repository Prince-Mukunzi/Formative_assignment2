import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';

enum ReportCategory {
  all('All', HugeIcons.strokeRoundedLayers01),
  facilities('Facilities', HugeIcons.strokeRoundedBuilding06),
  water('Water', HugeIcons.strokeRoundedDroplet),
  electricity('Electricity', HugeIcons.strokeRoundedFlash),
  furniture('Furniture', HugeIcons.strokeRoundedSofa01),
  sanitation('Sanitation', HugeIcons.strokeRoundedClean),
  safety('Safety', HugeIcons.strokeRoundedShield01);

  const ReportCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

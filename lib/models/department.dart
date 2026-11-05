import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import 'report.dart';
import 'report_category.dart';

class Department {
  final String id;
  final String label;
  final Set<ReportCategory> categories;

  const Department({
    required this.id,
    required this.label,
    required this.categories,
  });

  IconData get icon =>
      categories.firstOrNull?.icon ?? HugeIcons.strokeRoundedUserGroup;

  Map<String, Object?> toMap() => {
    'id': id,
    'label': label,
    'categories': [for (final category in categories) category.name],
  };

  factory Department.fromMap(Map<String, dynamic> map) => Department(
    id: map['id'] as String,
    label: map['label'] as String,
    categories: {
      for (final name in map['categories'] as List<dynamic>)
        ReportCategory.values.byName(name as String),
    },
  );
}

extension Departments on List<Department> {
  Department? byId(String id) => where((d) => d.id == id).firstOrNull;

  Department? ownerOf(Report report) {
    final assigned = report.assignedDepartmentId;
    if (assigned != null) return byId(assigned);
    return where((d) => d.categories.contains(report.category)).firstOrNull;
  }

  // A category has one owner, so saving a team takes its categories from the
  // others.
  List<Department> withSaved(Department saved) {
    final others = [
      for (final d in this)
        if (d.id != saved.id)
          Department(
            id: d.id,
            label: d.label,
            categories: d.categories.difference(saved.categories),
          ),
    ];
    final index = indexWhere((d) => d.id == saved.id);
    return index < 0
        ? [...others, saved]
        : [...others.take(index), saved, ...others.skip(index)];
  }
}

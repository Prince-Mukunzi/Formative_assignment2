import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'report.dart';
import 'report_category.dart';
import 'report_status.dart';

enum ReportSort {
  recent('Most recent'),
  mostImpacted('Most impacted');

  const ReportSort(this.label);
  final String label;
}

enum DatePreset {
  any('Any time'),
  today('Today'),
  week('Last 7 days'),
  month('Last 30 days'),
  custom('Custom range');

  const DatePreset(this.label);
  final String label;
}

class ReportFilter {
  final ReportCategory category;
  final ReportStatus? status;
  final ReportSort sort;
  final DatePreset datePreset;
  final DateTimeRange? customRange;

  const ReportFilter({
    this.category = ReportCategory.all,
    this.status,
    this.sort = ReportSort.recent,
    this.datePreset = DatePreset.any,
    this.customRange,
  });

  ReportFilter copyWith({
    ReportCategory? category,
    ReportStatus? Function()? status,
    ReportSort? sort,
    DatePreset? datePreset,
    DateTimeRange? Function()? customRange,
  }) {
    return ReportFilter(
      category: category ?? this.category,
      status: status != null ? status() : this.status,
      sort: sort ?? this.sort,
      datePreset: datePreset ?? this.datePreset,
      customRange: customRange != null ? customRange() : this.customRange,
    );
  }

  DateTimeRange? get dateRange {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    return switch (datePreset) {
      DatePreset.any => null,
      DatePreset.today => DateTimeRange(start: startOfToday, end: endOfToday),
      DatePreset.week => DateTimeRange(
          start: startOfToday.subtract(const Duration(days: 6)),
          end: endOfToday,
        ),
      DatePreset.month => DateTimeRange(
          start: startOfToday.subtract(const Duration(days: 29)),
          end: endOfToday,
        ),
      DatePreset.custom => customRange == null
          ? null
          : DateTimeRange(
              start: customRange!.start,
              end: customRange!.end.add(const Duration(days: 1)),
            ),
    };
  }

  String? get dateLabel {
    if (datePreset == DatePreset.any) return null;
    if (datePreset != DatePreset.custom) return datePreset.label;
    final range = customRange;
    if (range == null) return null;
    final fmt = DateFormat('MMM d');
    return '${fmt.format(range.start)} - ${fmt.format(range.end)}';
  }

  // Excludes category, which has its own chip row on the home screen.
  int get advancedCount =>
      (status != null ? 1 : 0) +
      (sort != ReportSort.recent ? 1 : 0) +
      (dateLabel != null ? 1 : 0);

  bool get isDefault => advancedCount == 0 && category == ReportCategory.all;

  List<Report> apply(List<Report> reports) {
    final range = dateRange;
    final result = reports.where((r) {
      if (category != ReportCategory.all && r.category != category) {
        return false;
      }
      if (status != null && r.status != status) return false;
      if (range != null &&
          (r.createdAt.isBefore(range.start) ||
              !r.createdAt.isBefore(range.end))) {
        return false;
      }
      return true;
    }).toList();

    result.sort(
      (a, b) => switch (sort) {
        ReportSort.recent => b.createdAt.compareTo(a.createdAt),
        ReportSort.mostImpacted => b.upvotes.compareTo(a.upvotes),
      },
    );
    return result;
  }
}

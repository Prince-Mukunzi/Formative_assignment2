import '../core/utils/row_time.dart';
import 'report_status.dart';
import 'report_category.dart';

class Report {
  static const nudgeCooldown = Duration(hours: 24);

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final ReportStatus status;
  final ReportCategory category;
  final int upvotes;
  final String location;
  final String reportedBy;
  final String reportedByName;
  final DateTime createdAt;
  final bool hasUpvoted;
  final DateTime? approvedAt;
  final DateTime? resolvedAt;
  final DateTime? verifiedAt;
  final DateTime? lastNudgedAt;
  final int nudges;
  final int reopenCount;
  final String? assignedDepartmentId;
  final DateTime? updatedAt;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.category,
    required this.upvotes,
    required this.location,
    required this.reportedBy,
    required this.reportedByName,
    required this.createdAt,
    this.hasUpvoted = false,
    this.approvedAt,
    this.resolvedAt,
    this.verifiedAt,
    this.lastNudgedAt,
    this.nudges = 0,
    this.reopenCount = 0,
    this.assignedDepartmentId,
    this.updatedAt,
  });

  // The reporter plus everyone who backed the report.
  int get affectedStudents => upvotes + 1;

  String get affectedLabel => affectedStudents == 1
      ? '1 student affected'
      : '$affectedStudents students affected';

  bool get isOpen =>
      status == ReportStatus.awaitingApproval ||
      status == ReportStatus.inProgress;

  // Once a team has approved it they are working from what was reported.
  bool get reporterCanChange => status == ReportStatus.awaitingApproval;

  bool get awaitsVerification =>
      status == ReportStatus.resolved && verifiedAt == null;

  bool canNudgeAt(DateTime now) {
    final last = lastNudgedAt;
    return isOpen && (last == null || now.difference(last) >= nudgeCooldown);
  }

  Report copyWith({
    String? title,
    String? description,
    String? imageUrl,
    ReportCategory? category,
    String? location,
    ReportStatus? status,
    int? upvotes,
    bool? hasUpvoted,
    DateTime? approvedAt,
    DateTime? Function()? resolvedAt,
    DateTime? Function()? verifiedAt,
    DateTime? lastNudgedAt,
    int? nudges,
    int? reopenCount,
    String? assignedDepartmentId,
  }) {
    return Report(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      category: category ?? this.category,
      upvotes: upvotes ?? this.upvotes,
      location: location ?? this.location,
      reportedBy: reportedBy,
      reportedByName: reportedByName,
      createdAt: createdAt,
      hasUpvoted: hasUpvoted ?? this.hasUpvoted,
      approvedAt: approvedAt ?? this.approvedAt,
      resolvedAt: resolvedAt != null ? resolvedAt() : this.resolvedAt,
      verifiedAt: verifiedAt != null ? verifiedAt() : this.verifiedAt,
      lastNudgedAt: lastNudgedAt ?? this.lastNudgedAt,
      nudges: nudges ?? this.nudges,
      reopenCount: reopenCount ?? this.reopenCount,
      assignedDepartmentId: assignedDepartmentId ?? this.assignedDepartmentId,
      updatedAt: updatedAt,
    );
  }

  factory Report.fromRow(Map<String, dynamic> row) {
    return Report(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      imageUrl: row['image_url'] as String,
      status: ReportStatus.values.byName(row['status'] as String),
      category: ReportCategory.values.byName(row['category'] as String),
      upvotes: row['upvotes'] as int,
      location: row['location'] as String,
      reportedBy: row['reported_by'] as String,
      reportedByName: row['reported_by_name'] as String,
      createdAt: readTime(row['created_at']),
      approvedAt: readOptionalTime(row['approved_at']),
      resolvedAt: readOptionalTime(row['resolved_at']),
      verifiedAt: readOptionalTime(row['verified_at']),
      lastNudgedAt: readOptionalTime(row['last_nudged_at']),
      nudges: row['nudges'] as int,
      reopenCount: row['reopen_count'] as int,
      assignedDepartmentId: row['assigned_department_id'] as String?,
      updatedAt: readOptionalTime(row['updated_at']),
    );
  }
}

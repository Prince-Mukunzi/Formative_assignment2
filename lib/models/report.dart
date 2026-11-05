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

  Report upvoteToggled() => copyWith(
    hasUpvoted: !hasUpvoted,
    upvotes: upvotes + (hasUpvoted ? -1 : 1),
  );

  Report nudged(DateTime now) =>
      copyWith(nudges: nudges + 1, lastNudgedAt: now);

  Report approved(DateTime now) =>
      copyWith(status: ReportStatus.inProgress, approvedAt: now);

  Report declined() => copyWith(status: ReportStatus.declined);

  Report resolved(DateTime now) =>
      copyWith(status: ReportStatus.resolved, resolvedAt: () => now);

  Report verified(DateTime now) => copyWith(verifiedAt: () => now);

  // Restarts the clock from now on the shorter reopen window, see SlaPolicy.
  Report reopened(DateTime now) => copyWith(
    status: ReportStatus.inProgress,
    approvedAt: now,
    resolvedAt: () => null,
    verifiedAt: () => null,
    reopenCount: reopenCount + 1,
  );

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
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'status': status.name,
      'category': category.name,
      'upvotes': upvotes,
      'location': location,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'hasUpvoted': hasUpvoted,
      'approvedAt': approvedAt?.millisecondsSinceEpoch,
      'resolvedAt': resolvedAt?.millisecondsSinceEpoch,
      'verifiedAt': verifiedAt?.millisecondsSinceEpoch,
      'lastNudgedAt': lastNudgedAt?.millisecondsSinceEpoch,
      'nudges': nudges,
      'reopenCount': reopenCount,
      'assignedDepartmentId': assignedDepartmentId,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    DateTime? optionalDate(String key) {
      final value = map[key] as int?;
      return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
    }

    return Report(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      status: ReportStatus.values.byName(map['status'] as String),
      category: ReportCategory.values.byName(map['category'] as String),
      upvotes: map['upvotes'] as int,
      location: map['location'] as String,
      reportedBy: map['reportedBy'] as String,
      reportedByName: map['reportedByName'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      hasUpvoted: map['hasUpvoted'] as bool,
      approvedAt: optionalDate('approvedAt'),
      resolvedAt: optionalDate('resolvedAt'),
      verifiedAt: optionalDate('verifiedAt'),
      lastNudgedAt: optionalDate('lastNudgedAt'),
      nudges: map['nudges'] as int,
      reopenCount: map['reopenCount'] as int,
      assignedDepartmentId: map['assignedDepartmentId'] as String?,
    );
  }
}

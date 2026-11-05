import 'report_status.dart';
import 'report_category.dart';

class Report {
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
  });

  Report copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    ReportStatus? status,
    ReportCategory? category,
    int? upvotes,
    String? location,
    String? reportedBy,
    String? reportedByName,
    DateTime? createdAt,
    bool? hasUpvoted,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      category: category ?? this.category,
      upvotes: upvotes ?? this.upvotes,
      location: location ?? this.location,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByName: reportedByName ?? this.reportedByName,
      createdAt: createdAt ?? this.createdAt,
      hasUpvoted: hasUpvoted ?? this.hasUpvoted,
    );
  }

  Map<String, dynamic> toMap() {
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
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
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
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}

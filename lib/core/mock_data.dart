import '../models/report.dart';
import '../models/report_status.dart';
import '../models/report_category.dart';

abstract final class MockData {
  static const _sinkImage =
      'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=600&q=80';
  static const _electricImage =
      'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&q=80';
  static const _waterImage =
      'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=600&q=80';
  static const _facilityImage =
      'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=600&q=80';

  static final List<Report> reports = [
    Report(
      id: '1',
      title: 'Broken Sink',
      description:
          'When You Open The Water Just Don\'t Expect It To Stay In The Sink. Half of it ends up on the floor.',
      imageUrl: _sinkImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.water,
      upvotes: 12,
      location: 'Block C, Rm 204',
      reportedBy: 'user1',
      reportedByName: 'Prince M.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Report(
      id: '2',
      title: 'Lights Flickering Again',
      description:
          'The hallway lights have been doing their haunted house impression for a week now. Not fun at 2am.',
      imageUrl: _electricImage,
      status: ReportStatus.inProgress,
      category: ReportCategory.electricity,
      upvotes: 24,
      location: 'East Wing, Floor 3',
      reportedBy: 'user2',
      reportedByName: 'Alice K.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Report(
      id: '3',
      title: 'Water Shortage in Dorm',
      description:
          'No water pressure above the second floor since yesterday morning. Showers are basically a suggestion at this point.',
      imageUrl: _waterImage,
      status: ReportStatus.inProgress,
      category: ReportCategory.water,
      upvotes: 31,
      location: 'Dorm B, All Floors',
      reportedBy: 'user3',
      reportedByName: 'John D.',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Report(
      id: '4',
      title: 'No Electricity in Lab 2',
      description:
          'Power has been out since morning. Can\'t charge laptops, can\'t run experiments. Productivity is at zero.',
      imageUrl: _electricImage,
      status: ReportStatus.resolved,
      category: ReportCategory.electricity,
      upvotes: 18,
      location: 'Science Block, Lab 2',
      reportedBy: 'user4',
      reportedByName: 'Sarah W.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Report(
      id: '5',
      title: 'Damaged Desk in Room 104',
      description:
          'One of the desk legs is barely holding on. It wobbles like it\'s dancing every time you write.',
      imageUrl: _facilityImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.facilities,
      upvotes: 8,
      location: 'Block A, Rm 104',
      reportedBy: 'user5',
      reportedByName: 'Grace L.',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Report(
      id: '6',
      title: 'Leaking Roof After Rain',
      description:
          'Every time it rains the ceiling near the staircase turns into a waterfall. Someone\'s gonna slip.',
      imageUrl: _waterImage,
      status: ReportStatus.resolved,
      category: ReportCategory.facilities,
      upvotes: 15,
      location: 'Main Hall, Staircase',
      reportedBy: 'user6',
      reportedByName: 'Tom B.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Report(
      id: '7',
      title: 'Broken Window Latch',
      description:
          'Window won\'t close properly in the study room. Cold air and bugs are having a field day.',
      imageUrl: _facilityImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.facilities,
      upvotes: 6,
      location: 'Library, Floor 2',
      reportedBy: 'user7',
      reportedByName: 'Mike R.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static const String userName = 'Prince';
}

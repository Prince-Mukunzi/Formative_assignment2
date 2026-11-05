import '../models/report.dart';
import '../models/report_status.dart';
import '../models/report_category.dart';

abstract final class MockData {
  static const _sinkImage =
      'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=400&q=80';
  static const _electricImage =
      'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80';
  static const _waterImage =
      'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400&q=80';
  static const _facilityImage =
      'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400&q=80';

  static final List<Report> reports = [
    Report(
      id: '1',
      title: 'Broken Sink',
      description:
          'The sink in the second floor bathroom is leaking badly. Water is pooling on the floor and creating a safety hazard.',
      imageUrl: _sinkImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.water,
      upvotes: 12,
      location: 'Building A, Floor 2',
      reportedBy: 'user1',
      reportedByName: 'Prince M.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Report(
      id: '2',
      title: 'Broken Sink',
      description:
          'Kitchen sink pipe burst causing water damage to the counter area.',
      imageUrl: _sinkImage,
      status: ReportStatus.resolved,
      category: ReportCategory.water,
      upvotes: 12,
      location: 'Building B, Kitchen',
      reportedBy: 'user2',
      reportedByName: 'Alice K.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Report(
      id: '3',
      title: 'Broken Sink',
      description: 'Bathroom sink faucet does not turn off completely.',
      imageUrl: _sinkImage,
      status: ReportStatus.resolved,
      category: ReportCategory.water,
      upvotes: 12,
      location: 'Building C, Floor 1',
      reportedBy: 'user3',
      reportedByName: 'John D.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Report(
      id: '4',
      title: 'Broken Sink',
      description:
          'Lab sink is clogged and overflowing during use.',
      imageUrl: _sinkImage,
      status: ReportStatus.resolved,
      category: ReportCategory.water,
      upvotes: 12,
      location: 'Lab Building, Floor 3',
      reportedBy: 'user4',
      reportedByName: 'Sarah W.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Report(
      id: '5',
      title: 'Power Outage',
      description:
          'Frequent power cuts in the east wing affecting all rooms on the third floor.',
      imageUrl: _electricImage,
      status: ReportStatus.inProgress,
      category: ReportCategory.electricity,
      upvotes: 24,
      location: 'East Wing, Floor 3',
      reportedBy: 'user5',
      reportedByName: 'Mike R.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Report(
      id: '6',
      title: 'Leaking Roof',
      description:
          'Water dripping from the ceiling near the staircase after heavy rain.',
      imageUrl: _waterImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.facilities,
      upvotes: 8,
      location: 'Main Hall',
      reportedBy: 'user6',
      reportedByName: 'Grace L.',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Report(
      id: '7',
      title: 'Broken Window',
      description:
          'Window pane cracked in the study room, cold air coming in.',
      imageUrl: _facilityImage,
      status: ReportStatus.inProgress,
      category: ReportCategory.facilities,
      upvotes: 15,
      location: 'Library, Floor 2',
      reportedBy: 'user7',
      reportedByName: 'Tom B.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static const String userName = 'Prince';
  static const int activeCount = 24;
  static const int resolvedCount = 14;
  static const int inProgressCount = 4;
}

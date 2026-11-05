import '../models/department.dart';
import '../models/game.dart';
import '../models/person.dart';
import '../models/report.dart';
import '../models/report_status.dart';
import '../models/report_category.dart';

abstract final class MockData {
  static const _sinkImage =
      'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=600&q=80';
  static const _electricImage =
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600&q=80';
  static const _waterImage =
      'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=600&q=80';
  static const _facilityImage =
      'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=600&q=80';

  static final List<Report> reports = [
    Report(
      id: '1',
      title: 'Broken Sink',
      description: 'When You Open The Water Just Don\'t Expect It To Stay In The Sink. Half of it ends up on the floor.',
      imageUrl: _sinkImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.water,
      upvotes: 12,
      location: 'Block C, Rm 204',
      reportedBy: currentStudentId,
      reportedByName: 'Prince M.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Report(
      id: '2',
      title: 'Lights Flickering Again',
      description: 'The hallway lights have been doing their haunted house impression for a week now. Not fun at 2am.',
      imageUrl: _electricImage,
      status: ReportStatus.inProgress,
      category: ReportCategory.electricity,
      upvotes: 24,
      location: 'East Wing, Floor 3',
      reportedBy: 'user2',
      reportedByName: 'Alice K.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      approvedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      nudges: 2,
    ),
    Report(
      id: '3',
      title: 'Water Shortage in Dorm',
      description: 'No water pressure above the second floor since yesterday morning. Showers are basically a suggestion at this point.',
      imageUrl: _waterImage,
      status: ReportStatus.inProgress,
      category: ReportCategory.water,
      upvotes: 31,
      location: 'Dorm B, All Floors',
      reportedBy: 'user3',
      reportedByName: 'John D.',
      createdAt: DateTime.now().subtract(const Duration(hours: 50)),
      approvedAt: DateTime.now().subtract(const Duration(hours: 49)),
      nudges: 1,
    ),
    Report(
      id: '4',
      title: 'No Electricity in Lab 2',
      description: 'Power has been out since morning. Can\'t charge laptops, can\'t run experiments. Productivity is at zero.',
      imageUrl: _electricImage,
      status: ReportStatus.resolved,
      category: ReportCategory.electricity,
      upvotes: 18,
      location: 'Science Block, Lab 2',
      reportedBy: 'user4',
      reportedByName: 'Sarah W.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      approvedAt: DateTime.now().subtract(const Duration(days: 3)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Report(
      id: '5',
      title: 'Damaged Desk in Room 104',
      description: 'One of the desk legs is barely holding on. It wobbles like it\'s dancing every time you write.',
      imageUrl: _facilityImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.furniture,
      upvotes: 8,
      location: 'Block A, Rm 104',
      reportedBy: 'user5',
      reportedByName: 'Grace L.',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Report(
      id: '6',
      title: 'Leaking Roof After Rain',
      description: 'Every time it rains the ceiling near the staircase turns into a waterfall. Someone\'s gonna slip.',
      imageUrl: _waterImage,
      status: ReportStatus.resolved,
      category: ReportCategory.facilities,
      upvotes: 15,
      location: 'Main Hall, Staircase',
      reportedBy: 'user6',
      reportedByName: 'Tom B.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      approvedAt: DateTime.now().subtract(const Duration(days: 5)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Report(
      id: '7',
      title: 'Broken Window Latch',
      description: 'Window won\'t close properly in the study room. Cold air and bugs are having a field day.',
      imageUrl: _facilityImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.safety,
      upvotes: 6,
      location: 'Library, Floor 2',
      reportedBy: 'user7',
      reportedByName: 'Mike R.',
      createdAt: DateTime.now().subtract(const Duration(hours: 30)),
    ),
    Report(
      id: '8',
      title: 'Sockets Sparking at Desks',
      description: 'Two of the desk sockets spark when you plug in a charger. Nobody wants to be the next one to try.',
      imageUrl: _electricImage,
      status: ReportStatus.inProgress,
      category: ReportCategory.electricity,
      upvotes: 9,
      location: 'Library, Floor 1',
      reportedBy: currentStudentId,
      reportedByName: 'Prince M.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      approvedAt: DateTime.now().subtract(const Duration(hours: 40)),
    ),
    Report(
      id: '9',
      title: 'Clogged Shower Drain',
      description: 'The drain backs up within a minute. The whole bathroom floods if you take longer than that.',
      imageUrl: _sinkImage,
      status: ReportStatus.resolved,
      category: ReportCategory.sanitation,
      upvotes: 14,
      location: 'Dorm A, Floor 2',
      reportedBy: currentStudentId,
      reportedByName: 'Prince M.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      approvedAt: DateTime.now().subtract(const Duration(days: 4)),
      resolvedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Report(
      id: '10',
      title: 'Ceiling Tile About to Fall',
      description: 'Hanging by one corner right above the main walkway. It moves whenever the door slams.',
      imageUrl: _facilityImage,
      status: ReportStatus.inProgress,
      category: ReportCategory.safety,
      upvotes: 27,
      location: 'Main Hall, Entrance',
      reportedBy: 'user8',
      reportedByName: 'Nadia O.',
      createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
      approvedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Report(
      id: '11',
      title: 'Hot Water Out Since Monday',
      description: 'Cold showers only on the whole west side. The boiler room has been locked and nobody knows why.',
      imageUrl: _waterImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.water,
      upvotes: 19,
      location: 'Dorm C, West Wing',
      reportedBy: 'user9',
      reportedByName: 'Eric T.',
      createdAt: DateTime.now().subtract(const Duration(hours: 16)),
    ),
    Report(
      id: '12',
      title: 'Projector Keeps Cutting Out',
      description: 'Loses power every ten minutes mid-lecture. The breaker in the room trips along with it.',
      imageUrl: _electricImage,
      status: ReportStatus.awaitingApproval,
      category: ReportCategory.electricity,
      upvotes: 11,
      location: 'Block B, Rm 12',
      reportedBy: 'user10',
      reportedByName: 'Lina M.',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
  ];

  static const departments = [
    Department(
      id: 'facilities',
      label: 'Facilities',
      categories: {ReportCategory.facilities},
    ),
    Department(
      id: 'plumbing',
      label: 'Plumbing',
      categories: {ReportCategory.water},
    ),
    Department(
      id: 'electrical',
      label: 'Electrical',
      categories: {ReportCategory.electricity},
    ),
    Department(
      id: 'furniture',
      label: 'Furniture',
      categories: {ReportCategory.furniture},
    ),
    Department(
      id: 'sanitation',
      label: 'Sanitation',
      categories: {ReportCategory.sanitation},
    ),
    Department(
      id: 'safety',
      label: 'Safety',
      categories: {ReportCategory.safety},
    ),
  ];

  static const locations = [
    'Block A',
    'Block B',
    'Block C',
    'Dorm A',
    'Dorm B',
    'Dorm C',
    'East Wing',
    'Library',
    'Main Hall',
    'Science Block',
  ];

  static final List<Person> people = [
    for (final entry in {
      for (final r in reports) r.reportedBy: r.reportedByName,
    }.entries)
      Person(id: entry.key, name: entry.value, role: PersonRole.student),
    const Person(
      id: 'staff1',
      name: 'Daniel N.',
      role: PersonRole.faculty,
      departmentId: 'electrical',
    ),
    const Person(
      id: 'staff2',
      name: 'Esther U.',
      role: PersonRole.faculty,
      departmentId: 'plumbing',
    ),
    const Person(
      id: 'staff3',
      name: 'Joseph K.',
      role: PersonRole.faculty,
      departmentId: 'facilities',
    ),
    const Person(
      id: 'staff4',
      name: 'Aline M.',
      role: PersonRole.faculty,
      departmentId: 'furniture',
    ),
    const Person(
      id: 'staff5',
      name: 'Patrick H.',
      role: PersonRole.faculty,
      departmentId: 'sanitation',
    ),
    const Person(
      id: 'staff6',
      name: 'Diane I.',
      role: PersonRole.faculty,
      departmentId: 'safety',
    ),
  ];

  static const String userName = 'Prince';
  static const String currentStudentId = 'user1';
  static const String currentStudentName = 'Prince M.';

  static const leaderboardPeers = [
    (name: 'Alice K.', xp: 420),
    (name: 'John D.', xp: 285),
    (name: 'Nadia O.', xp: 190),
    (name: 'Sarah W.', xp: 95),
    (name: 'Grace L.', xp: 60),
  ];

  // Leaves the student 10 XP short of Scout, so the first action in a fresh
  // install shows a full reward.
  static GameState get initialGame {
    final now = DateTime.now();
    XpEvent event(String key, XpReason reason, int daysAgo) => XpEvent(
      key: key,
      reason: reason,
      at: now.subtract(Duration(days: daysAgo)),
      seen: true,
    );
    return GameState(
      ledger: [
        event('reportFiled:9', XpReason.reportFiled, 4),
        event('photoAdded:9', XpReason.photoAdded, 4),
        event('reportApproved:9', XpReason.reportApproved, 4),
        event('reportResolved:9', XpReason.reportResolved, 2),
        event('reportFiled:8', XpReason.reportFiled, 2),
        event('photoAdded:8', XpReason.photoAdded, 2),
        event('reportApproved:8', XpReason.reportApproved, 2),
        event('reportFiled:1', XpReason.reportFiled, 1),
      ],
      celebrated: const {BadgeKind.firstCatch, BadgeKind.fixedIt},
    );
  }
}

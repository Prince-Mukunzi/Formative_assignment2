import 'package:alu_bug_bounty/models/app_settings.dart';
import 'package:alu_bug_bounty/models/department.dart';
import 'package:alu_bug_bounty/models/notice.dart';
import 'package:alu_bug_bounty/models/report.dart';
import 'package:alu_bug_bounty/models/report_category.dart';
import 'package:alu_bug_bounty/models/report_status.dart';
import 'package:alu_bug_bounty/models/session.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 11, 5, 12);

const _student = StudentSession(uid: 'me', name: 'Me', email: 'me@x');
const _faculty = FacultySession('plumbing', uid: 'f', name: 'F', email: 'f@x');
const _admin = AdminSession(uid: 'a', name: 'A', email: 'a@x');

const _teams = [
  Department(
    id: 'plumbing',
    label: 'Plumbing',
    categories: {ReportCategory.water},
  ),
];

Report _report({
  String id = 'r',
  String by = 'me',
  ReportStatus status = ReportStatus.awaitingApproval,
  ReportCategory category = ReportCategory.water,
  int upvotes = 0,
  Duration age = Duration.zero,
}) => Report(
  id: id,
  title: 'Tap',
  description: 'd',
  imageUrl: '',
  status: status,
  category: category,
  upvotes: upvotes,
  location: 'Block B',
  reportedBy: by,
  reportedByName: 'Me',
  createdAt: _now.subtract(age),
);

void main() {
  test('a student hears when their report is approved', () {
    final notices = feedNotices(
      session: _student,
      departments: _teams,
      before: [_report()],
      after: [_report(status: ReportStatus.inProgress)],
    );
    expect(notices.single.topic, NotificationTopic.reportUpdates);
  });

  test('a student is not told about their own reopen', () {
    final notices = feedNotices(
      session: _student,
      departments: _teams,
      before: [_report(status: ReportStatus.resolved)],
      after: [_report(status: ReportStatus.inProgress)],
    );
    expect(notices, isEmpty);
  });

  test('new backers on my report are counted together', () {
    final notices = feedNotices(
      session: _student,
      departments: _teams,
      before: [_report()],
      after: [_report(upvotes: 3)],
    );
    expect(notices.single.title, '3 students backed your report');
  });

  test('faculty hear only about new reports their team owns', () {
    final notices = feedNotices(
      session: _faculty,
      departments: _teams,
      before: const [],
      after: [
        _report(id: 'water'),
        _report(id: 'power', category: ReportCategory.electricity),
      ],
    );
    expect(notices.map((n) => n.reportId), ['water']);
  });

  test('admins hear about a new report no team owns', () {
    final notices = feedNotices(
      session: _admin,
      departments: _teams,
      before: const [],
      after: [_report(category: ReportCategory.electricity)],
    );
    expect(notices.single.topic, NotificationTopic.unownedReports);
  });

  test('an overdue report is only flagged once', () {
    final late = [_report(age: const Duration(days: 3))];
    final first = clockNotices(
      session: _admin,
      departments: _teams,
      reports: late,
      now: _now,
      reminded: const {},
    );
    expect(first.single.topic, NotificationTopic.overdueReports);
    final again = clockNotices(
      session: _admin,
      departments: _teams,
      reports: late,
      now: _now,
      reminded: {reminderKey(first.single)},
    );
    expect(again, isEmpty);
  });

  test('a board move reads as a climb or a slip', () {
    expect(
      boardNotice(teamLabel: 'Plumbing', before: 3, after: 1)?.title,
      'Plumbing moved up to #1',
    );
    expect(boardNotice(teamLabel: 'Plumbing', before: 2, after: 2), isNull);
  });
}

import 'accountability.dart';
import 'app_settings.dart';
import 'department.dart';
import 'report.dart';
import 'report_status.dart';
import 'session.dart';
import 'sla.dart';

class Notice {
  final NotificationTopic topic;
  final String title;
  final String body;
  final String? reportId;

  const Notice({
    required this.topic,
    required this.title,
    required this.body,
    this.reportId,
  });
}

/// What changed in the live feed that this person should hear about. Changes
/// they made themselves on this device are not news to them, so a student
/// reopening their own report says nothing.
List<Notice> feedNotices({
  required Session session,
  required List<Department> departments,
  required List<Report> before,
  required List<Report> after,
}) {
  final previous = {for (final report in before) report.id: report};
  final notices = <Notice>[];
  for (final report in after) {
    final old = previous[report.id];
    switch (session) {
      case StudentSession(:final uid):
        if (report.reportedBy != uid || old == null) continue;
        final update = _statusNotice(old.status, report);
        if (update != null) notices.add(update);
        final backers = report.upvotes - old.upvotes;
        if (backers > 0) {
          notices.add(
            Notice(
              topic: NotificationTopic.upvotes,
              title: backers == 1
                  ? 'Someone backed your report'
                  : '$backers students backed your report',
              body: report.title,
              reportId: report.id,
            ),
          );
        }
      case FacultySession(:final departmentId):
        if (old != null || departments.ownerOf(report)?.id != departmentId) {
          continue;
        }
        notices.add(
          Notice(
            topic: NotificationTopic.newReports,
            title: 'New report for your team',
            body: report.title,
            reportId: report.id,
          ),
        );
      case AdminSession():
        if (old != null || !report.isOpen) continue;
        if (departments.ownerOf(report) == null) {
          notices.add(
            Notice(
              topic: NotificationTopic.unownedReports,
              title: 'A report has no team',
              body: report.title,
              reportId: report.id,
            ),
          );
        }
    }
  }
  return notices;
}

Notice? _statusNotice(ReportStatus was, Report report) {
  final title = switch ((was, report.status)) {
    (ReportStatus.awaitingApproval, ReportStatus.inProgress) =>
      'Your report was approved',
    (_, ReportStatus.resolved) when was != ReportStatus.resolved =>
      'Marked fixed. Does it work?',
    (_, ReportStatus.declined) when was != ReportStatus.declined =>
      'Your report was declined',
    _ => null,
  };
  if (title == null) return null;
  return Notice(
    topic: NotificationTopic.reportUpdates,
    title: title,
    body: report.title,
    reportId: report.id,
  );
}

/// Faculty hear when their team climbs or slips on the board.
Notice? boardNotice({
  required String teamLabel,
  required int? before,
  required int? after,
}) {
  if (before == null || after == null || before == after) return null;
  return Notice(
    topic: NotificationTopic.boardChanges,
    title: after < before
        ? '$teamLabel moved up to #$after'
        : '$teamLabel slipped to #$after',
    body: after < before
        ? 'Keep closing reports to hold the spot'
        : 'Clear overdue reports to climb back',
  );
}

/// Reminders that come from the clock rather than from anyone's action. Each
/// report is only ever reminded once, tracked in [reminded].
List<Notice> clockNotices({
  required Session session,
  required List<Department> departments,
  required List<Report> reports,
  required DateTime now,
  required Set<String> reminded,
}) {
  final notices = <Notice>[];
  for (final report in reports.where((r) => r.isOpen)) {
    switch (session) {
      case FacultySession(:final departmentId):
        if (departments.ownerOf(report)?.id != departmentId) continue;
        final left = report.timeLeftAt(now);
        final key = 'due:${report.id}';
        if (left == null || left.isNegative || left.inHours >= 24) continue;
        if (reminded.contains(key)) continue;
        notices.add(
          Notice(
            topic: NotificationTopic.deadlines,
            title: 'Due in ${_hours(left)}',
            body: report.title,
            reportId: report.id,
          ),
        );
      case AdminSession():
        final key = 'late:${report.id}';
        if (report.slaStateAt(now) != SlaState.overdue) continue;
        if (reminded.contains(key)) continue;
        notices.add(
          Notice(
            topic: NotificationTopic.overdueReports,
            title: 'Now overdue',
            body: report.title,
            reportId: report.id,
          ),
        );
      case StudentSession():
        break;
    }
  }
  return notices;
}

String reminderKey(Notice notice) => switch (notice.topic) {
  NotificationTopic.deadlines => 'due:${notice.reportId}',
  NotificationTopic.overdueReports => 'late:${notice.reportId}',
  _ => '',
};

Notice dailySummary(List<Report> reports, DateTime now, int unowned) {
  final reading = PressureReading.of(reports, now);
  final open = reports.where((r) => r.isOpen).length;
  return Notice(
    topic: NotificationTopic.dailySummary,
    title: 'Today on campus',
    body: '$open open, ${reading.overdue} late, $unowned with no team',
  );
}

String _hours(Duration left) =>
    left.inHours < 1 ? '${left.inMinutes}m' : '${left.inHours}h';

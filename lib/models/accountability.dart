import 'department.dart';
import 'report.dart';
import 'report_status.dart';
import 'sla.dart';

enum PressureLevel {
  calm('Under control'),
  rising('Pressure rising'),
  high('Students are waiting'),
  critical('Critical backlog');

  const PressureLevel(this.label);
  final String label;

  static PressureLevel forScore(int score) {
    if (score >= 75) return critical;
    if (score >= 45) return high;
    if (score >= 15) return rising;
    return calm;
  }
}

class PressureReading {
  final int score;
  final int overdue;
  final int waitingStudents;
  final int dueWithin24h;

  const PressureReading({
    required this.score,
    required this.overdue,
    required this.waitingStudents,
    required this.dueWithin24h,
  });

  PressureLevel get level => PressureLevel.forScore(score);

  factory PressureReading.of(Iterable<Report> reports, DateTime now) {
    var raw = 0;
    var overdue = 0;
    var waiting = 0;
    var dueSoon = 0;
    for (final report in reports.where((r) => r.isOpen)) {
      final state = report.slaStateAt(now);
      raw += switch (state) {
        SlaState.overdue => 30,
        SlaState.critical => 16,
        SlaState.warning => 7,
        SlaState.calm || null => 2,
      };
      if (state == SlaState.overdue) overdue++;
      waiting += report.affectedStudents;
      final left = report.timeLeftAt(now);
      if (left != null && !left.isNegative && left.inHours < 24) dueSoon++;
    }
    return PressureReading(
      score: raw.clamp(0, 100),
      overdue: overdue,
      waitingStudents: waiting,
      dueWithin24h: dueSoon,
    );
  }
}

class DepartmentScore {
  final Department department;
  final int points;
  final int resolved;
  final int open;
  final int overdue;
  final int reopened;

  const DepartmentScore({
    required this.department,
    required this.points,
    required this.resolved,
    required this.open,
    required this.overdue,
    required this.reopened,
  });
}

List<DepartmentScore> departmentBoard(Iterable<Report> reports, DateTime now) {
  final board = Department.values.map((department) {
    final owned = reports.where((r) => r.department == department);
    final resolved =
        owned.where((r) => r.status == ReportStatus.resolved).length;
    final open = owned.where((r) => r.isOpen).length;
    final overdue =
        owned.where((r) => r.slaStateAt(now) == SlaState.overdue).length;
    final reopened = owned.fold(0, (sum, r) => sum + r.reopenCount);
    return DepartmentScore(
      department: department,
      points: resolved * 10 - overdue * 15 - reopened * 10,
      resolved: resolved,
      open: open,
      overdue: overdue,
      reopened: reopened,
    );
  }).toList();
  board.sort((a, b) => b.points.compareTo(a.points));
  return board;
}

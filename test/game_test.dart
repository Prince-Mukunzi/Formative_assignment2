import 'package:alu_bug_bounty/core/mock_data.dart';
import 'package:alu_bug_bounty/models/accountability.dart';
import 'package:alu_bug_bounty/models/department.dart';
import 'package:alu_bug_bounty/models/game.dart';
import 'package:alu_bug_bounty/models/report.dart';
import 'package:alu_bug_bounty/models/report_category.dart';
import 'package:alu_bug_bounty/models/report_status.dart';
import 'package:alu_bug_bounty/models/sla.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 11, 5, 12);

Report _report({
  ReportStatus status = ReportStatus.awaitingApproval,
  ReportCategory category = ReportCategory.water,
  Duration age = Duration.zero,
  DateTime? approvedAt,
  int upvotes = 0,
  int nudges = 0,
  int reopenCount = 0,
}) {
  return Report(
    id: 'r',
    title: 't',
    description: 'd',
    imageUrl: '',
    status: status,
    category: category,
    upvotes: upvotes,
    location: 'l',
    reportedBy: 'me',
    reportedByName: 'Me',
    createdAt: _now.subtract(age),
    approvedAt: approvedAt,
    nudges: nudges,
    reopenCount: reopenCount,
  );
}

void main() {
  group('SLA clock', () {
    test('upvotes and nudges pull the deadline in', () {
      final base = _report().deadline!;
      final backed = _report(upvotes: 3, nudges: 1).deadline!;
      expect(base.difference(backed), const Duration(hours: 2));
    });

    test('crowd pressure cannot shrink the window below its floor', () {
      final window = _report(upvotes: 10000).slaWindow!;
      expect(window, SlaPolicy.triageWindow * SlaPolicy.minimumFraction);
    });

    test('state escalates as time runs out', () {
      final report = _report();
      expect(report.slaStateAt(_now), SlaState.calm);
      expect(
        report.slaStateAt(_now.add(const Duration(hours: 14))),
        SlaState.warning,
      );
      expect(
        report.slaStateAt(_now.add(const Duration(hours: 22))),
        SlaState.critical,
      );
      expect(
        report.slaStateAt(_now.add(const Duration(hours: 25))),
        SlaState.overdue,
      );
    });

    test('closed reports have no clock', () {
      final done = _report(status: ReportStatus.resolved);
      expect(done.deadline, isNull);
      expect(done.slaStateAt(_now), isNull);
    });

    test('reopening restarts on the shorter window', () {
      final reopened = _report(status: ReportStatus.resolved).reopened(_now);
      expect(reopened.status, ReportStatus.inProgress);
      expect(reopened.resolvedAt, isNull);
      expect(reopened.deadline, _now.add(SlaPolicy.reopenWindow));
    });
  });

  group('XP', () {
    const empty = GameState(ledger: [], celebrated: {});
    XpEvent event(String key, XpReason reason) =>
        XpEvent(key: key, reason: reason, at: _now);

    test('the same award cannot be claimed twice', () {
      final once = empty.award(event('upvoteGiven:1', XpReason.upvoteGiven));
      final twice = once.award(event('upvoteGiven:1', XpReason.upvoteGiven));
      expect(twice.xp, XpReason.upvoteGiven.xp);
    });

    test('ranks follow thresholds and progress stays in range', () {
      expect(Rank.forXp(0), Rank.spotter);
      expect(Rank.forXp(149), Rank.spotter);
      expect(Rank.forXp(150), Rank.scout);
      expect(Rank.legend.progressAt(99999), 1);
      expect(Rank.scout.progressAt(275), 0.5);
    });

    test('streak counts back from today or yesterday and stops at a gap', () {
      DateTime daysAgo(int n) => _now.subtract(Duration(days: n));
      expect(streakDays([daysAgo(0), daysAgo(1), daysAgo(3)], _now), 2);
      expect(streakDays([daysAgo(1), daysAgo(2)], _now), 2);
      expect(streakDays([daysAgo(2)], _now), 0);
    });

    test('a pending moment reports rank-ups and wants a celebration', () {
      const stats = GameStats(
        filed: 1,
        resolved: 0,
        mostUpvotes: 0,
        nudgesSent: 0,
        fixesChecked: 0,
        streak: 1,
      );
      final game = GameState(
        ledger: [
          for (final (i, reason) in const [
            XpReason.reportResolved,
            XpReason.reportResolved,
            XpReason.reportApproved,
            XpReason.reportFiled,
            XpReason.photoAdded,
            XpReason.detailAdded,
          ].indexed)
            XpEvent(key: 'old$i', reason: reason, at: _now, seen: true),
        ],
        celebrated: const {BadgeKind.firstCatch},
      ).award(event('new', XpReason.nudgeSent));
      final moment = RewardMoment.pending(game, stats)!;
      expect(moment.gained, XpReason.nudgeSent.xp);
      expect(moment.rankUp, Rank.scout);
      expect(moment.deservesCelebration, isTrue);
    });

    test('revoking a report removes only the XP scoped to it', () {
      final game = empty
          .award(event('reportFiled:r1', XpReason.reportFiled))
          .award(event('nudgeSent:r1:2026-11-5', XpReason.nudgeSent))
          .award(event('reportFiled:r10', XpReason.reportFiled));
      expect(game.revoke('r1').ledger.map((e) => e.key), ['reportFiled:r10']);
    });

    test('a lone upvote stays a micro reward', () {
      const stats = GameStats(
        filed: 0,
        resolved: 0,
        mostUpvotes: 0,
        nudgesSent: 0,
        fixesChecked: 0,
        streak: 0,
      );
      final game = empty.award(event('k', XpReason.upvoteGiven));
      expect(RewardMoment.pending(game, stats)!.deservesCelebration, isFalse);
    });

    test('pending XP shrinks as a report advances', () {
      expect(pendingXpFor(_report()), 90);
      expect(pendingXpFor(_report(status: ReportStatus.inProgress)), 65);
      expect(pendingXpFor(_report(status: ReportStatus.declined)), 0);
    });

    test('a reopened report promises no XP it already paid', () {
      expect(
        pendingXpFor(_report(status: ReportStatus.inProgress, reopenCount: 1)),
        0,
      );
    });

    test('reopening a report does not revoke the fixed badge', () {
      final game = const GameState(ledger: [], celebrated: {}).award(
        XpEvent(
          key: 'reportResolved:r',
          reason: XpReason.reportResolved,
          at: _now,
        ),
      );
      final stats = statsFor(
        game,
        [_report(status: ReportStatus.inProgress, reopenCount: 1)],
        'me',
        _now,
      );
      expect(BadgeKind.fixedIt.isEarned(stats), isTrue);
    });
  });

  group('Accountability', () {
    test('pressure climbs with overdue work and clamps at 100', () {
      final late = _report(age: const Duration(days: 3));
      expect(PressureReading.of([late], _now).overdue, 1);
      expect(PressureReading.of([], _now).level, PressureLevel.calm);
      expect(PressureReading.of(List.filled(9, late), _now).score, 100);
    });

    test('students waiting counts reporter and backers on open reports', () {
      final reading = PressureReading.of([
        _report(upvotes: 4),
        _report(status: ReportStatus.resolved, upvotes: 50),
      ], _now);
      expect(reading.waitingStudents, 5);
    });

    test('overdue work sinks a department below one that delivers', () {
      final board = departmentBoard(
        [
          _report(category: ReportCategory.water, age: const Duration(days: 3)),
          _report(
            category: ReportCategory.electricity,
            status: ReportStatus.resolved,
          ),
        ],
        _now,
        MockData.departments,
      );
      expect(board.first.department.id, 'electrical');
      expect(board.first.points, 10);
      expect(board.last.department.id, 'plumbing');
      expect(board.last.points, -15);
    });
  });

  group('Prizes', () {
    test('the next prize is the cheapest one still locked', () {
      expect(Prize.nextFor(0), Prize.cafeVoucher);
      expect(Prize.nextFor(1000), Prize.tShirt);
      expect(Prize.nextFor(25000), isNull);
    });

    test('a reward lists only the prizes it crossed', () {
      const moment = RewardMoment(
        events: [],
        xpBefore: 990,
        xpAfter: 2500,
        badges: [],
      );
      expect(moment.prizes, [Prize.cafeVoucher, Prize.tShirt]);
      expect(moment.deservesCelebration, isTrue);
    });
  });

  group('Teams', () {
    const water = Department(
      id: 'w',
      label: 'Water',
      categories: {ReportCategory.water},
    );
    const power = Department(
      id: 'p',
      label: 'Power',
      categories: {ReportCategory.electricity},
    );

    test('saving a team takes its categories from the others', () {
      final teams = [water, power].withSaved(
        const Department(
          id: 'new',
          label: 'Utilities',
          categories: {ReportCategory.water, ReportCategory.electricity},
        ),
      );
      expect(teams.byId('w')!.categories, isEmpty);
      expect(teams.byId('p')!.categories, isEmpty);
      expect(teams.ownerOf(_report())!.id, 'new');
    });

    test('a category nobody owns leaves the report with no team', () {
      expect(<Department>[power].ownerOf(_report()), isNull);
    });

    test('an assignment overrides the category owner', () {
      final moved = _report().copyWith(assignedDepartmentId: 'p');
      expect([water, power].ownerOf(moved)!.id, 'p');
    });
  });
}

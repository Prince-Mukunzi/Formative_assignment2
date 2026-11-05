import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import 'report.dart';
import 'report_status.dart';

enum XpReason {
  reportFiled('Report filed', 10, isMajor: true),
  photoAdded('Photo evidence', 5),
  detailAdded('Detailed description', 5),
  reportApproved('Report approved by faculty', 25, isMajor: true),
  reportResolved('Your report got fixed', 50, isMajor: true),
  fixChecked('Checked the fix', 15, isMajor: true),
  upvoteGiven('Backed a report', 2),
  nudgeSent('Followed up', 5);

  const XpReason(this.label, this.xp, {this.isMajor = false});
  final String label;
  final int xp;
  final bool isMajor;
}

class XpEvent {
  final String key;
  final XpReason reason;
  final DateTime at;
  final bool seen;

  const XpEvent({
    required this.key,
    required this.reason,
    required this.at,
    this.seen = false,
  });

  XpEvent markSeen() => XpEvent(key: key, reason: reason, at: at, seen: true);

  factory XpEvent.fromMap(String key, Map<String, dynamic> map) => XpEvent(
    key: key,
    reason: XpReason.values.byName(map['reason'] as String),
    at: map['at'] as DateTime,
    seen: map['seen'] as bool,
  );
}

enum Rank {
  spotter('Spotter', 0, HugeIcons.strokeRoundedEye),
  scout('Scout', 150, HugeIcons.strokeRoundedTarget01),
  tracker('Tracker', 400, HugeIcons.strokeRoundedRocket01),
  hunter('Hunter', 800, HugeIcons.strokeRoundedBug01),
  exterminator('Exterminator', 1500, HugeIcons.strokeRoundedShield01),
  legend('Campus Legend', 3000, HugeIcons.strokeRoundedCrown);

  const Rank(this.label, this.threshold, this.icon);
  final String label;
  final int threshold;
  final IconData icon;

  static Rank forXp(int xp) =>
      values.lastWhere((rank) => xp >= rank.threshold, orElse: () => spotter);

  Rank? get next => index + 1 < values.length ? values[index + 1] : null;

  double progressAt(int xp) {
    final upcoming = next;
    if (upcoming == null) return 1;
    return ((xp - threshold) / (upcoming.threshold - threshold)).clamp(0, 1);
  }
}

enum Prize {
  cafeVoucher('Cafe voucher', 1000, HugeIcons.strokeRoundedCoffee02),
  tShirt('ALU T-shirt', 2500, HugeIcons.strokeRoundedTShirt),
  hoodie('ALU hoodie', 5000, HugeIcons.strokeRoundedHoodie),
  headphones('Headphones', 10000, HugeIcons.strokeRoundedHeadphones),
  tablet('Tablet', 25000, HugeIcons.strokeRoundedTablet01);

  const Prize(this.label, this.xp, this.icon);
  final String label;
  final int xp;
  final IconData icon;

  bool unlockedAt(int total) => total >= xp;

  double progressAt(int total) => (total / xp).clamp(0, 1);

  static Prize? nextFor(int total) {
    for (final prize in values) {
      if (!prize.unlockedAt(total)) return prize;
    }
    return null;
  }
}

class GameState {
  final List<XpEvent> ledger;

  const GameState({required this.ledger});

  int get xp => ledger.fold(0, (sum, event) => sum + event.reason.xp);

  Iterable<XpEvent> get unseen => ledger.where((event) => !event.seen);

  // Keys make every award idempotent, so toggling an upvote or a re-resolved
  // report can never be farmed for repeat XP.
  GameState award(XpEvent event) {
    if (ledger.any((existing) => existing.key == event.key)) return this;
    return GameState(ledger: [...ledger, event]);
  }

  GameState revoke(String reportId) => GameState(
    ledger: [
      for (final event in ledger)
        if (!event.key.split(':').skip(1).contains(reportId)) event,
    ],
  );


}

class RewardMoment {
  final List<XpEvent> events;
  final int xpBefore;
  final int xpAfter;

  const RewardMoment({
    required this.events,
    required this.xpBefore,
    required this.xpAfter,
  });

  int get gained => xpAfter - xpBefore;

  Rank? get rankUp {
    final after = Rank.forXp(xpAfter);
    return after == Rank.forXp(xpBefore) ? null : after;
  }

  List<Prize> get prizes => [
    for (final prize in Prize.values)
      if (prize.unlockedAt(xpAfter) && !prize.unlockedAt(xpBefore)) prize,
  ];

  bool get deservesCelebration =>
      rankUp != null ||
      prizes.isNotEmpty ||
      events.any((event) => event.reason.isMajor);

  static RewardMoment? pending(GameState game) {
    final events = game.unseen.toList();
    if (events.isEmpty) return null;
    final gained = events.fold(0, (sum, event) => sum + event.reason.xp);
    return RewardMoment(
      events: events,
      xpBefore: game.xp - gained,
      xpAfter: game.xp,
    );
  }
}

// XP still on the table for a student's report, used to pull them back to it.
// A reopened report has already paid its fix and check, and the ledger will
// not pay them twice.
int pendingXpFor(Report report) {
  if (report.reopenCount > 0) return 0;
  return switch (report.status) {
    ReportStatus.awaitingApproval =>
      XpReason.reportApproved.xp +
          XpReason.reportResolved.xp +
          XpReason.fixChecked.xp,
    ReportStatus.inProgress =>
      XpReason.reportResolved.xp + XpReason.fixChecked.xp,
    ReportStatus.resolved =>
      report.verifiedAt == null ? XpReason.fixChecked.xp : 0,
    ReportStatus.declined => 0,
  };
}

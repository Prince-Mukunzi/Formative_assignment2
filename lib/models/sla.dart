import 'report.dart';
import 'report_status.dart';

abstract final class SlaPolicy {
  static const triageWindow = Duration(hours: 24);
  static const resolveWindow = Duration(hours: 72);
  static const reopenWindow = Duration(hours: 24);
  static const upvoteCut = Duration(minutes: 20);
  static const nudgeCut = Duration(hours: 1);
  static const minimumFraction = 0.25;
}

enum SlaState { calm, warning, critical, overdue }

extension ReportSla on Report {
  Duration? get slaWindow {
    final Duration base = switch (status) {
      ReportStatus.awaitingApproval => SlaPolicy.triageWindow,
      ReportStatus.inProgress =>
        reopenCount > 0 ? SlaPolicy.reopenWindow : SlaPolicy.resolveWindow,
      _ => Duration.zero,
    };
    if (base == Duration.zero) return null;
    final cut = SlaPolicy.upvoteCut * upvotes + SlaPolicy.nudgeCut * nudges;
    final floor = base * SlaPolicy.minimumFraction;
    final effective = base - cut;
    return effective < floor ? floor : effective;
  }

  DateTime? get deadline {
    final window = slaWindow;
    if (window == null) return null;
    final start = status == ReportStatus.inProgress
        ? approvedAt ?? createdAt
        : createdAt;
    return start.add(window);
  }

  Duration? timeLeftAt(DateTime now) => deadline?.difference(now);

  SlaState? slaStateAt(DateTime now) {
    final window = slaWindow;
    final left = timeLeftAt(now);
    if (window == null || left == null) return null;
    if (left.isNegative) return SlaState.overdue;
    final fraction = left.inSeconds / window.inSeconds;
    if (fraction < 0.15) return SlaState.critical;
    if (fraction < 0.5) return SlaState.warning;
    return SlaState.calm;
  }
}

String formatSlaDuration(Duration duration) {
  final d = duration.abs();
  String two(int n) => n.toString().padLeft(2, '0');
  if (d.inDays >= 1) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours >= 1) return '${d.inHours}h ${two(d.inMinutes % 60)}m';
  return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
}

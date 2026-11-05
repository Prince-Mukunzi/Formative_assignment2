import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/mock_data.dart';
import '../models/accountability.dart';
import '../models/department.dart';
import '../models/game.dart';
import '../models/report.dart';
import '../models/report_category.dart';
import '../models/report_status.dart';
import '../services/report_service.dart';
import 'clock_provider.dart';
import 'directory_provider.dart';
import 'game_provider.dart';
import 'session_provider.dart';

final reportServiceProvider = Provider(
  (ref) => ReportService(ref.watch(localStoreProvider)),
);

class ReportsNotifier extends Notifier<List<Report>> {
  static const minDetailLength = 30;

  @override
  List<Report> build() => ref.watch(reportServiceProvider).load();

  GameNotifier get _game => ref.read(gameProvider.notifier);

  void _set(List<Report> next) {
    state = next;
    ref.read(reportServiceProvider).save(next);
  }

  Report _update(String id, Report Function(Report) change) {
    late Report updated;
    _set([
      for (final report in state)
        if (report.id == id) updated = change(report) else report,
    ]);
    return updated;
  }

  void _creditReporter(Report report, XpReason reason) {
    if (report.reportedBy != MockData.currentStudentId) return;
    _game.award(reason, report.id);
  }

  void create({
    required String title,
    required String description,
    required String location,
    required ReportCategory category,
    required String imageUrl,
  }) {
    final report = Report(
      id: const Uuid().v4(),
      title: title,
      description: description,
      imageUrl: imageUrl,
      status: ReportStatus.awaitingApproval,
      category: category,
      upvotes: 0,
      location: location,
      reportedBy: MockData.currentStudentId,
      reportedByName: MockData.currentStudentName,
      createdAt: DateTime.now(),
    );
    _set([report, ...state]);
    _game.award(XpReason.reportFiled, report.id);
    _creditEvidence(report);
  }

  void edit(
    String id, {
    required String title,
    required String description,
    required String location,
    required ReportCategory category,
    required String imageUrl,
  }) {
    final report = _update(
      id,
      (r) => r.copyWith(
        title: title,
        description: description,
        location: location,
        category: category,
        imageUrl: imageUrl,
      ),
    );
    _creditEvidence(report);
  }

  void withdraw(String id) {
    _game.revoke(id);
    delete(id);
  }

  void _creditEvidence(Report report) {
    if (report.imageUrl.isNotEmpty) {
      _game.award(XpReason.photoAdded, report.id);
    }
    if (report.description.length >= minDetailLength) {
      _game.award(XpReason.detailAdded, report.id);
    }
  }

  int toggleUpvote(String id) {
    final report = _update(id, (r) => r.upvoteToggled());
    return report.hasUpvoted ? _game.award(XpReason.upvoteGiven, id) : 0;
  }

  int nudge(String id) {
    final now = DateTime.now();
    final report = _update(id, (r) => r.nudged(now));
    final day = '${now.year}-${now.month}-${now.day}';
    return _game.award(XpReason.nudgeSent, '${report.id}:$day');
  }

  void approve(String id) {
    final report = _update(id, (r) => r.approved(DateTime.now()));
    _creditReporter(report, XpReason.reportApproved);
  }

  void decline(String id) => _update(id, (r) => r.declined());

  void resolve(String id) {
    final report = _update(id, (r) => r.resolved(DateTime.now()));
    _creditReporter(report, XpReason.reportResolved);
  }

  void confirmFix(String id) {
    final report = _update(id, (r) => r.verified(DateTime.now()));
    _creditReporter(report, XpReason.fixChecked);
  }

  void reopen(String id) => _update(id, (r) => r.reopened(DateTime.now()));

  void reassign(String id, String departmentId) =>
      _update(id, (r) => r.copyWith(assignedDepartmentId: departmentId));

  void delete(String id) => _set([
    for (final report in state)
      if (report.id != id) report,
  ]);

  void reportStillBroken(String id) {
    final report = _update(id, (r) => r.reopened(DateTime.now()));
    _creditReporter(report, XpReason.fixChecked);
  }
}

final reportsProvider = NotifierProvider<ReportsNotifier, List<Report>>(
  ReportsNotifier.new,
);

final reportByIdProvider = Provider.family<Report?, String>((ref, id) {
  return ref.watch(
    reportsProvider.select(
      (reports) => reports.where((r) => r.id == id).firstOrNull,
    ),
  );
});

final departmentReportsProvider = Provider.family<List<Report>, String>((
  ref,
  departmentId,
) {
  final departments = ref.watch(departmentsProvider);
  return ref
      .watch(reportsProvider)
      .where((r) => departments.ownerOf(r)?.id == departmentId)
      .toList();
});

final departmentBoardProvider = Provider<List<DepartmentScore>>((ref) {
  return departmentBoard(
    ref.watch(reportsProvider),
    ref.watch(minuteProvider),
    ref.watch(departmentsProvider),
  );
});

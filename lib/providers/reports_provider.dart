import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accountability.dart';
import '../models/department.dart';
import '../models/game.dart';
import '../models/report.dart';
import '../models/report_category.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';
import 'clock_provider.dart';
import 'directory_provider.dart';
import 'game_provider.dart';
import 'session_provider.dart';
import 'sync_provider.dart';

final reportServiceProvider = Provider((ref) => ReportService());

final storageServiceProvider = Provider((ref) => StorageService());

class ReportsNotifier extends Notifier<List<Report>> {
  static const minDetailLength = 30;

  List<Report> _reports = const [];
  Set<String> _upvoted = const {};

  @override
  List<Report> build() {
    final uid = ref.watch(sessionUidProvider);
    if (uid == null) return const [];
    final service = ref.watch(reportServiceProvider);
    follow(ref, service.watchAll(), Feed.reports, (next) {
      _reports = next;
      _publish();
    });
    follow(ref, service.watchUpvotedBy(uid), Feed.reports, (next) {
      _upvoted = next;
      _publish();
    });
    return const [];
  }

  void _publish() => state = [
    for (final report in _reports)
      _upvoted.contains(report.id)
          ? report.copyWith(hasUpvoted: true)
          : report,
  ];

  ReportService get _service => ref.read(reportServiceProvider);

  GameNotifier get _game => ref.read(gameProvider.notifier);

  String get _uid => ref.read(sessionUidProvider) ?? '';

  Report? _byId(String id) => state.where((r) => r.id == id).firstOrNull;

  void _send(Future<void> write, {String? predictedFor}) => send(
    ref,
    write,
    onError: predictedFor == null ? null : () => _game.forget(predictedFor),
  );

  // Photos upload before the report is written, so the stored URL is always
  // one other people can load.
  Future<String> _hosted(String reportId, String imagePath) async {
    if (imagePath.isEmpty || imagePath.startsWith('http')) return imagePath;
    return ref
        .read(storageServiceProvider)
        .uploadReportImage(
          uid: _uid,
          reportId: reportId,
          localPath: imagePath,
        );
  }

  Future<void> create({
    required String title,
    required String description,
    required String location,
    required ReportCategory category,
    required String imageUrl,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    final id = _service.newId();
    final hostedUrl = await _hosted(id, imageUrl);
    _send(
      _service.create(
        id: id,
        uid: session.uid,
        name: session.name,
        title: title,
        description: description,
        location: location,
        category: category,
        imageUrl: hostedUrl,
      ),
      predictedFor: id,
    );
    _game.award(XpReason.reportFiled, id);
    _predictEvidence(id, hostedUrl, description);
  }

  Future<void> edit(
    String id, {
    required String title,
    required String description,
    required String location,
    required ReportCategory category,
    required String imageUrl,
  }) async {
    final hostedUrl = await _hosted(id, imageUrl);
    _send(
      _service.editContent(
        id,
        uid: _uid,
        title: title,
        description: description,
        location: location,
        category: category,
        imageUrl: hostedUrl,
      ),
    );
    _predictEvidence(id, hostedUrl, description);
  }

  void withdraw(String id) {
    _game.revoke(id);
    delete(id);
  }

  void _predictEvidence(String id, String imageUrl, String description) {
    if (imageUrl.isNotEmpty) _game.award(XpReason.photoAdded, id);
    if (description.length >= minDetailLength) {
      _game.award(XpReason.detailAdded, id);
    }
  }

  int toggleUpvote(String id) {
    final report = _byId(id);
    if (report == null) return 0;
    final on = !report.hasUpvoted;
    _upvoted = on ? {..._upvoted, id} : ({..._upvoted}..remove(id));
    _publish();
    _send(_service.setUpvote(id, _uid, on: on));
    return on ? _game.award(XpReason.upvoteGiven, id) : 0;
  }

  int nudge(String id) {
    _send(_service.nudge(id, _uid));
    final day = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    return _game.award(XpReason.nudgeSent, '$id:$day');
  }

  void approve(String id) => _send(_service.approve(id, _uid));

  void decline(String id) => _send(_service.decline(id, _uid));

  void resolve(String id) => _send(_service.resolve(id, _uid));

  void confirmFix(String id) {
    _send(_service.confirmFix(id, _uid));
    _game.award(XpReason.fixChecked, id);
  }

  void reopen(String id) => _send(_service.reopen(id, _uid));

  void reassign(String id, String departmentId) =>
      _send(_service.reassign(id, _uid, departmentId));

  void delete(String id) => _send(_service.delete(id));

  void reportStillBroken(String id) {
    _send(_service.reopen(id, _uid));
    _game.award(XpReason.fixChecked, id);
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

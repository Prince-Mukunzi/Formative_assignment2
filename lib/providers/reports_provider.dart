import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accountability.dart';
import '../models/department.dart';
import '../models/game.dart';
import '../models/report.dart';
import '../models/report_category.dart';
import '../models/report_status.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';
import 'clock_provider.dart';
import 'directory_provider.dart';
import 'game_provider.dart';
import 'session_provider.dart';
import 'sync_provider.dart';

final reportServiceProvider = Provider((ref) => ReportService());

final storageServiceProvider = Provider((ref) => StorageService());

typedef _PendingChange = ({
  DateTime? baseline,
  Report? Function(Report report) apply,
});

class ReportsNotifier extends Notifier<List<Report>> {
  static const minDetailLength = 30;

  List<Report> _reports = const [];
  Set<String> _upvoted = const {};

  // Local changes shown at once and dropped when the server's copy of that
  // report changes. An apply that returns null hides the report.
  final _pending = <String, _PendingChange>{};

  @override
  List<Report> build() {
    _pending.clear();
    final uid = ref.watch(sessionUidProvider);
    if (uid == null) return const [];
    final service = ref.watch(reportServiceProvider);
    follow(ref, service.watchAll(), Feed.reports, (next) {
      _reports = next;
      _dropSettled();
      _publish();
    });
    follow(ref, service.watchUpvotedBy(uid), Feed.reports, (next) {
      _upvoted = next;
      _publish();
    });
    return const [];
  }

  void _dropSettled() {
    final server = {for (final report in _reports) report.id: report};
    _pending.removeWhere(
      (id, change) => server[id]?.updatedAt != change.baseline,
    );
  }

  void _publish() => state = [
    for (final report in _reports)
      if (_shown(report) case final shown?)
        _upvoted.contains(shown.id) ? shown.copyWith(hasUpvoted: true) : shown,
  ];

  Report? _shown(Report report) {
    final change = _pending[report.id];
    return change == null ? report : change.apply(report);
  }

  ReportService get _service => ref.read(reportServiceProvider);

  StorageService get _storage => ref.read(storageServiceProvider);

  GameNotifier get _game => ref.read(gameProvider.notifier);

  String get _uid => ref.read(sessionUidProvider) ?? '';

  Report? _byId(String id) => state.where((r) => r.id == id).firstOrNull;

  void _change(
    String id,
    Report? Function(Report report) apply,
    Future<void> write, {
    void Function()? onError,
  }) {
    final server = _reports.where((r) => r.id == id).firstOrNull;
    if (server != null) {
      final earlier = _pending[id];
      _pending[id] = (
        baseline: server.updatedAt,
        apply: earlier == null
            ? apply
            : (report) {
                final changed = earlier.apply(report);
                return changed == null ? null : apply(changed);
              },
      );
      _publish();
    }
    send(
      ref,
      write,
      onError: () {
        _pending.remove(id);
        onError?.call();
        _publish();
      },
    );
  }

  // Photos upload before the report is written, so the stored URL is always
  // one other people can load.
  Future<String> _hosted(String reportId, String imagePath) async {
    if (imagePath.isEmpty || imagePath.startsWith('http')) return imagePath;
    return _storage.uploadReportImage(
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
    if (ref.read(sessionProvider) == null) return;
    final id = _service.newId();
    final hostedUrl = await _hosted(id, imageUrl);
    await _service.create(
      id: id,
      title: title,
      description: description,
      location: location,
      category: category,
      imageUrl: hostedUrl,
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
    final previousImage = _byId(id)?.imageUrl ?? '';
    final hostedUrl = await _hosted(id, imageUrl);
    await _service.editContent(
      id,
      title: title,
      description: description,
      location: location,
      category: category,
      imageUrl: hostedUrl,
    );
    if (previousImage != hostedUrl) {
      await _storage.removeReportImage(previousImage);
    }
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
    final before = _upvoted;
    _upvoted = on ? {..._upvoted, id} : ({..._upvoted}..remove(id));
    _change(
      id,
      (r) => r.copyWith(upvotes: r.upvotes + (on ? 1 : -1)),
      _service.setUpvote(id, on: on),
      onError: () => _upvoted = before,
    );
    return on ? _game.award(XpReason.upvoteGiven, id) : 0;
  }

  int nudge(String id) {
    final now = DateTime.now();
    _change(
      id,
      (r) => r.copyWith(nudges: r.nudges + 1, lastNudgedAt: now),
      _service.nudge(id),
    );
    final day = now.toUtc().toIso8601String().substring(0, 10);
    return _game.award(XpReason.nudgeSent, '$id:$day');
  }

  void approve(String id) => _change(
    id,
    (r) =>
        r.copyWith(status: ReportStatus.inProgress, approvedAt: DateTime.now()),
    _service.approve(id),
  );

  void decline(String id) => _change(
    id,
    (r) => r.copyWith(status: ReportStatus.declined),
    _service.decline(id),
  );

  void resolve(String id) => _change(
    id,
    (r) => r.copyWith(
      status: ReportStatus.resolved,
      resolvedAt: () => DateTime.now(),
    ),
    _service.resolve(id),
  );

  void confirmFix(String id) {
    _change(
      id,
      (r) => r.copyWith(verifiedAt: () => DateTime.now()),
      _service.confirmFix(id),
    );
    _game.award(XpReason.fixChecked, id);
  }

  void reopen(String id) => _change(id, _reopened, _service.reopen(id));

  Report _reopened(Report r) => r.copyWith(
    status: ReportStatus.inProgress,
    approvedAt: DateTime.now(),
    resolvedAt: () => null,
    verifiedAt: () => null,
    reopenCount: r.reopenCount + 1,
  );

  void reassign(String id, String departmentId) => _change(
    id,
    (r) => r.copyWith(assignedDepartmentId: departmentId),
    _service.reassign(id, departmentId),
  );

  void delete(String id) {
    final imageUrl = _byId(id)?.imageUrl ?? '';
    _change(
      id,
      (_) => null,
      _service.delete(id).then((_) => _storage.removeReportImage(imageUrl)),
    );
  }

  void reportStillBroken(String id) {
    reopen(id);
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

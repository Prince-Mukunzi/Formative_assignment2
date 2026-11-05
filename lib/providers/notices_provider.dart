import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accountability.dart';
import '../models/department.dart';
import '../models/notice.dart';
import '../models/session.dart';
import 'clock_provider.dart';
import 'directory_provider.dart';
import 'reports_provider.dart';
import 'session_provider.dart';
import 'settings_provider.dart';
import 'sync_provider.dart';

/// In-app notifications, queued oldest first. A muted topic is never queued,
/// but its reminders still count as sent so unmuting does not replay them.
class NoticesNotifier extends Notifier<List<Notice>> {
  static const _storeKey = 'notices.v1';

  bool _live = false;
  Set<String> _reminded = {};
  String? _summaryDay;

  @override
  List<Notice> build() {
    _live = false;
    final session = ref.watch(sessionProvider);
    if (session == null) return const [];
    _load(session.uid);

    ref.listen(dataReadyProvider, (_, ready) {
      if (!ready || _live) return;
      _live = true;
      _checkClock();
      _summarise();
    }, fireImmediately: true);

    ref.listen(reportsProvider, (before, after) {
      if (!_live || before == null) return;
      _queue(
        feedNotices(
          session: session,
          departments: ref.read(departmentsProvider),
          before: before,
          after: after,
        ),
      );
    });

    ref.listen(minuteProvider, (_, _) {
      if (_live) _checkClock();
    });

    if (session is FacultySession) {
      int? placeIn(List<DepartmentScore> board) {
        final index = board.indexWhere(
          (score) => score.department.id == session.departmentId,
        );
        return index < 0 ? null : index + 1;
      }

      ref.listen(departmentBoardProvider, (before, after) {
        if (!_live || before == null) return;
        final notice = boardNotice(
          teamLabel:
              ref.read(departmentsProvider).byId(session.departmentId)?.label ??
              'Your team',
          before: placeIn(before),
          after: placeIn(after),
        );
        if (notice != null) _queue([notice]);
      });
    }
    return const [];
  }

  void post(Notice notice) => _queue([notice]);

  void dismiss() {
    if (state.isNotEmpty) state = state.sublist(1);
  }

  void _queue(List<Notice> notices) {
    if (notices.isEmpty) return;
    final muted = ref.read(settingsProvider).muted;
    final keys = notices.map(reminderKey).where((key) => key.isNotEmpty);
    if (keys.isNotEmpty) {
      _reminded = {..._reminded, ...keys};
      _save();
    }
    final heard = [
      for (final notice in notices)
        if (!muted.contains(notice.topic)) notice,
    ];
    if (heard.isNotEmpty) state = [...state, ...heard];
  }

  void _checkClock() {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    _queue(
      clockNotices(
        session: session,
        departments: ref.read(departmentsProvider),
        reports: ref.read(reportsProvider),
        now: ref.read(minuteProvider),
        reminded: _reminded,
      ),
    );
  }

  void _summarise() {
    if (ref.read(sessionProvider) is! AdminSession) return;
    final now = ref.read(minuteProvider);
    final today = now.toIso8601String().substring(0, 10);
    if (_summaryDay == today) return;
    _summaryDay = today;
    _save();
    final reports = ref.read(reportsProvider);
    final departments = ref.read(departmentsProvider);
    final unowned = reports
        .where((r) => r.isOpen && departments.ownerOf(r) == null)
        .length;
    _queue([dailySummary(reports, now, unowned)]);
  }

  String? _uid;

  void _load(String uid) {
    _uid = uid;
    final stored = ref.read(localStoreProvider).read(_storeKey);
    final mine = stored is Map ? stored[uid] : null;
    if (mine is! Map) {
      _reminded = {};
      _summaryDay = null;
      return;
    }
    final reminded = mine['reminded'];
    _reminded = {
      if (reminded is List)
        for (final key in reminded)
          if (key is String) key,
    };
    final day = mine['summaryDay'];
    _summaryDay = day is String ? day : null;
  }

  void _save() {
    final uid = _uid;
    if (uid == null) return;
    final store = ref.read(localStoreProvider);
    final stored = store.read(_storeKey);
    store.write(_storeKey, {
      if (stored is Map) ...stored,
      uid: {'reminded': _reminded.toList(), 'summaryDay': _summaryDay},
    });
  }
}

final noticesProvider = NotifierProvider<NoticesNotifier, List<Notice>>(
  NoticesNotifier.new,
);

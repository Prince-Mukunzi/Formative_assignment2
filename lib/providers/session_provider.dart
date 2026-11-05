import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/department.dart';
import '../models/session.dart';
import '../services/local_store.dart';
import '../services/session_service.dart';
import 'directory_provider.dart';

final localStoreProvider = Provider<LocalStore>(
  (ref) => throw StateError('localStoreProvider must be overridden in main'),
);

final sessionServiceProvider = Provider(
  (ref) => SessionService(ref.watch(localStoreProvider)),
);

class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() {
    final service = ref.watch(sessionServiceProvider);
    final session = service.load();
    final removed =
        session is FacultySession &&
        ref.read(departmentsProvider).byId(session.departmentId) == null;
    if (removed) service.clear();
    return removed ? null : session;
  }

  void signIn(Session session) {
    state = session;
    ref.read(sessionServiceProvider).save(session);
  }

  void signOut() {
    state = null;
    ref.read(sessionServiceProvider).clear();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);

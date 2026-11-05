import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session.dart';
import '../services/local_store.dart';
import '../services/session_service.dart';

final localStoreProvider = Provider<LocalStore>(
  (ref) => throw StateError('localStoreProvider must be overridden in main'),
);

final sessionServiceProvider = Provider(
  (ref) => SessionService(ref.watch(localStoreProvider)),
);

class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => ref.watch(sessionServiceProvider).load();

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

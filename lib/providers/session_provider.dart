import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_gate.dart';
import '../models/session.dart';
import '../services/local_store.dart';
import 'auth_provider.dart';

final localStoreProvider = Provider<LocalStore>(
  (ref) => throw StateError('localStoreProvider must be overridden in main'),
);

final sessionProvider = Provider<Session?>(
  (ref) => switch (ref.watch(authGateProvider)) {
    Ready(:final session) => session,
    _ => null,
  },
);

final sessionUidProvider = Provider<String?>(
  (ref) => ref.watch(sessionProvider.select((session) => session?.uid)),
);

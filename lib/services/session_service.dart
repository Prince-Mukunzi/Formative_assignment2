import '../models/session.dart';
import 'local_store.dart';

class SessionService {
  static const _key = 'session.v1';

  final LocalStore _store;

  const SessionService(this._store);

  Session? load() {
    final raw = _store.read(_key);
    return raw == null ? null : Session.fromMap(raw as Map<String, dynamic>);
  }

  Future<void> save(Session session) => _store.write(_key, session.toMap());

  Future<void> clear() => _store.remove(_key);
}

import '../core/mock_data.dart';
import '../models/game.dart';
import 'local_store.dart';

class GameService {
  static const _key = 'game.v1';

  final LocalStore _store;

  const GameService(this._store);

  GameState load() {
    final raw = _store.read(_key);
    if (raw == null) return MockData.initialGame;
    return GameState.fromMap(raw as Map<String, dynamic>);
  }

  Future<void> save(GameState state) => _store.write(_key, state.toMap());
}

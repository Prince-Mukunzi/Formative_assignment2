import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game.dart';
import '../models/session.dart';
import '../services/game_service.dart';
import 'session_provider.dart';
import 'sync_provider.dart';

final gameServiceProvider = Provider((ref) => GameService());

/// The server owns the ledger. Awards the app expects are shown at once as
/// predictions under the same key, and disappear when the real event lands.
class GameNotifier extends Notifier<GameState> {
  List<XpEvent> _server = const [];
  final _predicted = <String, XpEvent>{};
  final _withdrawn = <String>{};
  final _seenKeys = <String>{};

  @override
  GameState build() {
    _predicted.clear();
    _withdrawn.clear();
    _seenKeys.clear();
    _server = const [];
    final uid = ref.watch(sessionUidProvider);
    if (uid == null || ref.read(sessionProvider) is! StudentSession) {
      return const GameState(ledger: []);
    }
    follow(ref, ref.watch(gameServiceProvider).watchLedger(uid), Feed.ledger, (
      events,
    ) {
      _server = events;
      _catchUpSeen();
      _publish();
    });
    return const GameState(ledger: []);
  }

  bool _isWithdrawn(String key) =>
      key.split(':').skip(1).any(_withdrawn.contains);

  void _publish() {
    final serverKeys = {for (final event in _server) event.key};
    _predicted.removeWhere((key, _) => serverKeys.contains(key));
    state = GameState(
      ledger: [
        for (final event in [..._server, ..._predicted.values])
          if (!_isWithdrawn(event.key))
            _seenKeys.contains(event.key) ? event.markSeen() : event,
      ],
    );
  }

  // Events acknowledged while they were still predictions get marked seen
  // once the server has written them.
  void _catchUpSeen() {
    final uid = ref.read(sessionUidProvider);
    final stale = [
      for (final event in _server)
        if (!event.seen && _seenKeys.contains(event.key)) event.key,
    ];
    if (uid == null || stale.isEmpty) return;
    send(ref, ref.read(gameServiceProvider).markSeen(stale));
  }

  /// Returns the XP expected: 0 when this award was already claimed.
  int award(XpReason reason, String scope) {
    final key = '${reason.name}:$scope';
    if (state.ledger.any((event) => event.key == key)) return 0;
    _predicted[key] = XpEvent(key: key, reason: reason, at: DateTime.now());
    _publish();
    return reason.xp;
  }

  void forget(String reportId) {
    _predicted.removeWhere(
      (key, _) => key.split(':').skip(1).contains(reportId),
    );
    _publish();
  }

  void revoke(String reportId) {
    _withdrawn.add(reportId);
    _publish();
  }

  void acknowledge(RewardMoment moment) {
    final uid = ref.read(sessionUidProvider);
    if (uid == null) return;
    _seenKeys.addAll(moment.events.map((event) => event.key));
    _catchUpSeen();
    _publish();
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

final pendingRewardProvider = Provider<RewardMoment?>((ref) {
  return RewardMoment.pending(ref.watch(gameProvider));
});

final leaderboardProvider = StreamProvider.autoDispose<List<LeaderEntry>>(
  (ref) => ref.watch(gameServiceProvider).watchLeaderboard(),
);

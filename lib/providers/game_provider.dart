import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/mock_data.dart';
import '../models/game.dart';
import '../services/game_service.dart';
import 'reports_provider.dart';
import 'session_provider.dart';

final gameServiceProvider = Provider(
  (ref) => GameService(ref.watch(localStoreProvider)),
);

class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() => ref.watch(gameServiceProvider).load();

  /// Returns the XP actually granted: 0 when this award was already claimed.
  int award(XpReason reason, String scope) {
    final next = state.award(
      XpEvent(key: '${reason.name}:$scope', reason: reason, at: DateTime.now()),
    );
    if (identical(next, state)) return 0;
    _update(next);
    return reason.xp;
  }

  void acknowledge(RewardMoment moment) {
    _update(state.seen(moment.badges.toSet()));
  }

  void _update(GameState next) {
    state = next;
    ref.read(gameServiceProvider).save(next);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

final gameStatsProvider = Provider<GameStats>((ref) {
  return statsFor(
    ref.watch(gameProvider),
    ref.watch(reportsProvider),
    MockData.currentStudentId,
    DateTime.now(),
  );
});

final pendingRewardProvider = Provider<RewardMoment?>((ref) {
  return RewardMoment.pending(
    ref.watch(gameProvider),
    ref.watch(gameStatsProvider),
  );
});

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game.dart';
import 'backend.dart';
import 'row_decoding.dart';

typedef LeaderEntry = ({String uid, String name, int xp});

class GameService {
  static const leaderboardSize = 20;

  final SupabaseClient _db;

  GameService({SupabaseClient? db}) : _db = db ?? backend;

  Stream<List<XpEvent>> watchLedger(String uid) => _db
      .from('xp_events')
      .stream(primaryKey: ['uid', 'key'])
      .eq('uid', uid)
      .map((rows) => decodeRows(rows, XpEvent.fromRow));

  Future<void> markSeen(Iterable<String> keys) => _db
      .rpc<void>('mark_xp_seen', params: {'keys': keys.toList()})
      .timeout(backendTimeout);

  Stream<List<LeaderEntry>> watchLeaderboard() => _db
      .from('leaderboard')
      .stream(primaryKey: ['uid'])
      .order('xp')
      .limit(leaderboardSize)
      .map(
        (rows) => [
          for (final row in rows)
            if (row case {
              'uid': final String uid,
              'name': final String name,
              'xp': final int xp,
            })
              (uid: uid, name: name, xp: xp),
        ],
      );
}

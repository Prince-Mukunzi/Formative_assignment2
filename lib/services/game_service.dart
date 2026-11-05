import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game.dart';
import 'firestore_decoding.dart';

typedef LeaderEntry = ({String uid, String name, int xp});

class GameService {
  static const leaderboardSize = 20;

  final FirebaseFirestore _db;

  GameService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _events(String uid) =>
      _db.collection('users/$uid/xpEvents');

  Stream<List<XpEvent>> watchLedger(String uid) => _events(uid).snapshots().map(
    (snapshot) => [
      for (final doc in snapshot.docs) ?decodeOrSkip(doc, XpEvent.fromMap),
    ],
  );

  Future<void> markSeen(String uid, Iterable<String> keys) {
    final batch = _db.batch();
    for (final key in keys) {
      batch.update(_events(uid).doc(key), {'seen': true});
    }
    return batch.commit();
  }

  Stream<List<LeaderEntry>> watchLeaderboard() => _db
      .collection('leaderboard')
      .orderBy('xp', descending: true)
      .limit(leaderboardSize)
      .snapshots()
      .map(
        (snapshot) => [
          for (final doc in snapshot.docs)
            if (doc.data() case {'name': final String name, 'xp': final int xp})
              (uid: doc.id, name: name, xp: xp),
        ],
      );
}

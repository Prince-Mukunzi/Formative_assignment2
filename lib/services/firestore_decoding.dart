import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

// A server timestamp reads as null until the write reaches the server. Only
// required stamps are filled in with the local time, so a fresh report or
// XP event shows at once; optional ones stay null for that moment.
const _requiredStamps = {'createdAt', 'at'};

Map<String, dynamic> _withDates(Map<String, dynamic> data, bool pending) => {
  for (final MapEntry(:key, :value) in data.entries)
    key: switch (value) {
      Timestamp() => value.toDate(),
      null when pending && _requiredStamps.contains(key) => DateTime.now(),
      _ => value,
    },
};

/// Decodes one document, skipping it if it does not match the model so a
/// single bad document cannot break a whole list.
T? decodeOrSkip<T>(
  DocumentSnapshot<Map<String, dynamic>> doc,
  T Function(String id, Map<String, dynamic> data) decode,
) {
  try {
    final data = doc.data();
    if (data == null) return null;
    return decode(doc.id, _withDates(data, doc.metadata.hasPendingWrites));
  } on Object catch (error) {
    developer.log(
      'Skipped malformed document ${doc.reference.path}',
      error: error,
      level: 900,
    );
    return null;
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  final SharedPreferences _prefs;

  const LocalStore(this._prefs);

  Object? read(String key) {
    final raw = _prefs.getString(key);
    return raw == null ? null : jsonDecode(raw);
  }

  Future<void> write(String key, Object? value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> remove(String key) => _prefs.remove(key);

  // Data the app kept on the device before it moved to Firestore.
  static const _legacyKeys = [
    'session.v1',
    'reports.v1',
    'departments.v1',
    'people.v1',
    'locations.v1',
    'game.v1',
  ];

  Future<void> dropLegacyData() async {
    for (final key in _legacyKeys) {
      await _prefs.remove(key);
    }
  }
}

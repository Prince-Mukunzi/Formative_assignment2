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
}

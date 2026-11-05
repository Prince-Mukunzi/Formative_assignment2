import '../models/app_settings.dart';
import 'local_store.dart';

class SettingsService {
  static const _key = 'settings.v1';

  final LocalStore _store;

  const SettingsService(this._store);

  AppSettings load() => AppSettings.fromJson(_store.read(_key));

  Future<void> save(AppSettings settings) =>
      _store.write(_key, settings.toJson());
}

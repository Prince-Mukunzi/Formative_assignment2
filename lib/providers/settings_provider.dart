import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/app_haptics.dart';
import '../core/utils/app_motion_prefs.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';
import 'session_provider.dart';

final settingsServiceProvider = Provider(
  (ref) => SettingsService(ref.watch(localStoreProvider)),
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final settings = ref.watch(settingsServiceProvider).load();
    AppHaptics.enabled = settings.haptics;
    AppMotionPrefs.reduced = settings.reduceMotion;
    return settings;
  }

  void _set(AppSettings next) {
    state = next;
    AppHaptics.enabled = next.haptics;
    AppMotionPrefs.reduced = next.reduceMotion;
    ref.read(settingsServiceProvider).save(next);
  }

  void setTopic(NotificationTopic topic, {required bool enabled}) => _set(
    state.copyWith(
      muted: enabled
          ? (state.muted.toSet()..remove(topic))
          : {...state.muted, topic},
    ),
  );

  void setHaptics(bool value) => _set(state.copyWith(haptics: value));

  void setReduceMotion(bool value) => _set(state.copyWith(reduceMotion: value));

  void setCelebrations(bool value) => _set(state.copyWith(celebrations: value));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

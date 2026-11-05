import 'dart:io';

import 'package:alu_bug_bounty/core/app_info.dart';
import 'package:alu_bug_bounty/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings survive a round trip', () {
    const settings = AppSettings(
      muted: {NotificationTopic.upvotes},
      haptics: false,
      reduceMotion: true,
      celebrations: false,
    );
    final restored = AppSettings.fromJson(settings.toJson());
    expect(restored.muted, {NotificationTopic.upvotes});
    expect(restored.haptics, isFalse);
    expect(restored.reduceMotion, isTrue);
    expect(restored.celebrations, isFalse);
  });

  test('malformed settings fall back to defaults', () {
    final restored = AppSettings.fromJson({'muted': 'nope', 'haptics': 'x'});
    expect(restored.muted, isEmpty);
    expect(restored.haptics, isTrue);
    expect(AppSettings.fromJson(null).celebrations, isTrue);
  });

  test('displayed version matches pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('version: $appVersion+'));
  });
}

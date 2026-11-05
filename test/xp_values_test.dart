import 'dart:convert';
import 'dart:io';

import 'package:alu_bug_bounty/models/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app XP matches what the server awards', () {
    final server = jsonDecode(
      File('functions/src/xp.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(
      {for (final reason in XpReason.values) reason.name: reason.xp},
      server,
    );
  });
}

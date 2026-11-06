import 'dart:io';

import 'package:alu_bug_bounty/models/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app XP matches what the database awards', () {
    final sql = Directory('supabase/migrations')
        .listSync()
        .whereType<File>()
        .map((file) => file.readAsStringSync())
        .join('\n');
    final awarded = {
      for (final match in RegExp(r"when '(\w+)' then (\d+)").allMatches(sql))
        match.group(1)!: int.parse(match.group(2)!),
    };
    expect({
      for (final reason in XpReason.values) reason.name: reason.xp,
    }, awarded);
  });
}

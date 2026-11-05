import 'package:alu_bug_bounty/core/utils/time_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 5, 17, 30);

  String label(Duration ago) => postedLabel(now.subtract(ago), now);

  test('recent reports count minutes', () {
    expect(label(Duration.zero), 'Just now');
    expect(label(const Duration(minutes: 2)), '2m ago');
  });

  test('older reports use calendar days, not 24 hour windows', () {
    expect(label(const Duration(hours: 3)), 'Today');
    expect(label(const Duration(hours: 18)), 'Yesterday');
    expect(label(const Duration(days: 3)), '3 days ago');
    expect(postedLabel(DateTime(2026, 10, 2), now), '2 Oct');
    expect(postedLabel(DateTime(2025, 10, 2), now), '2 Oct 2025');
  });
}

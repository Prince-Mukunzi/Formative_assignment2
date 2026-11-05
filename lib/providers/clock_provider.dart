import 'package:flutter_riverpod/flutter_riverpod.dart';

final secondTickProvider = StreamProvider<DateTime>(
  (ref) => Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
);

final nowProvider = Provider<DateTime>(
  (ref) => ref.watch(secondTickProvider).valueOrNull ?? DateTime.now(),
);

final minuteProvider = Provider<DateTime>((ref) {
  final minute = ref.watch(
    nowProvider.select(
      (now) => DateTime(now.year, now.month, now.day, now.hour, now.minute),
    ),
  );
  return minute;
});

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session.dart';
import 'directory_provider.dart';
import 'game_provider.dart';
import 'reports_provider.dart';
import 'session_provider.dart';

enum Feed { departments, locations, reports, ledger, people }

/// Which live feeds have delivered their first snapshot for this session.
class LoadedFeeds extends Notifier<Set<Feed>> {
  @override
  Set<Feed> build() {
    ref.watch(sessionUidProvider);
    return const {};
  }

  void mark(Feed feed) {
    if (!state.contains(feed)) state = {...state, feed};
  }
}

final loadedFeedsProvider = NotifierProvider<LoadedFeeds, Set<Feed>>(
  LoadedFeeds.new,
);

final dataReadyProvider = Provider<bool>((ref) {
  final loaded = ref.watch(loadedFeedsProvider);
  final needed = switch (ref.watch(sessionProvider)) {
    null => const <Feed>{},
    StudentSession() => const {
      Feed.departments,
      Feed.locations,
      Feed.reports,
      Feed.ledger,
    },
    FacultySession() => const {Feed.departments, Feed.locations, Feed.reports},
    AdminSession() => const {
      Feed.departments,
      Feed.locations,
      Feed.reports,
      Feed.people,
    },
  };
  // Feeds start only once something listens to their notifier, and the
  // loading screen shows none of them, so listening here starts them.
  for (final feed in needed) {
    ref.listen(_providerOf(feed), (_, _) {});
  }
  return loaded.containsAll(needed);
});

ProviderListenable<Object?> _providerOf(Feed feed) => switch (feed) {
  Feed.departments => departmentsProvider,
  Feed.locations => locationsProvider,
  Feed.reports => reportsProvider,
  Feed.ledger => gameProvider,
  Feed.people => peopleProvider,
};

/// The latest write the server refused, shown once as a snackbar.
class WriteErrors extends Notifier<String?> {
  @override
  String? build() => null;

  void report(Object error) {
    developer.log('Write failed', error: error, level: 1000);
    state = 'That did not save. Check your connection and try again.';
  }

  void clear() => state = null;
}

final writeErrorsProvider = NotifierProvider<WriteErrors, String?>(
  WriteErrors.new,
);

/// Subscribes [notifierRef] to [stream] for the provider's lifetime.
void follow<T>(
  Ref notifierRef,
  Stream<T> stream,
  Feed feed,
  void Function(T value) onData,
) {
  final subscription = stream.listen(
    (value) {
      onData(value);
      notifierRef.read(loadedFeedsProvider.notifier).mark(feed);
    },
    onError: (Object error) =>
        developer.log('Feed ${feed.name} failed', error: error, level: 1000),
  );
  notifierRef.onDispose(subscription.cancel);
}

/// Fires a write without blocking the UI; local snapshots already show it.
void send(Ref notifierRef, Future<void> write, {void Function()? onError}) {
  unawaited(
    write.catchError((Object error) {
      notifierRef.read(writeErrorsProvider.notifier).report(error);
      onError?.call();
    }),
  );
}

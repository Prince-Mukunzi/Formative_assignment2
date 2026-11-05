import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_gate.dart';
import '../models/auth_user.dart';
import '../models/person.dart';
import '../models/session.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final profileServiceProvider = Provider((ref) => ProfileService());

final currentPersonProvider = Provider<Person?>(
  (ref) => switch (ref.watch(authGateProvider)) {
    Ready(:final person) => person,
    _ => null,
  },
);

class AuthGateNotifier extends Notifier<AuthGate> {
  static const _entryTimeout = Duration(seconds: 30);

  StreamSubscription<AuthUser?>? _authChanges;
  StreamSubscription<Person?>? _profileChanges;
  String? _watchedUid;
  bool _provisioning = false;

  PersonRole? _expectedRole;
  String? _pendingName;
  String? _notice;

  Completer<AuthGate>? _entry;
  AuthGate? _held;

  AuthService get _auth => ref.read(authServiceProvider);

  @override
  AuthGate build() {
    _authChanges = ref.watch(authServiceProvider).changes.listen(_onUser);
    ref.onDispose(() {
      _authChanges?.cancel();
      _profileChanges?.cancel();
    });
    return const AuthLoading();
  }

  void _onUser(AuthUser? user) {
    if (user == null) {
      _stopWatching();
      final notice = _notice;
      _notice = null;
      _resolve(SignedOut(notice));
      return;
    }
    if (!user.emailVerified) {
      _stopWatching();
      _resolve(NeedsVerification(user.email));
      return;
    }
    if (_watchedUid == user.uid) return;
    _stopWatching();
    _watchedUid = user.uid;
    if (_entry == null) state = const AuthLoading();
    _profileChanges = ref
        .read(profileServiceProvider)
        .watch(user.uid)
        .listen(_onProfile, onError: (Object _) => _refuse(_connectionNotice));
  }

  void _stopWatching() {
    _profileChanges?.cancel();
    _profileChanges = null;
    _watchedUid = null;
  }

  Future<void> _onProfile(Person? next) async {
    if (next == null) return _provision();
    if (next.suspended) return _resolve(const Suspended());
    final expected = _expectedRole;
    if (expected != null && expected != next.role) {
      return _refuse(
        'This account is registered as ${next.role.label.toLowerCase()}. '
        'Choose ${next.role.label} to sign in.',
      );
    }
    _expectedRole = null;
    final session = Session.of(next);
    _resolve(
      session == null
          ? const Blocked('Your account has no team yet. Contact an admin.')
          : Ready(session, next),
    );
  }

  Future<void> _provision() async {
    if (_provisioning) return;
    _provisioning = true;
    try {
      await _auth.provision(name: _pendingName);
      _pendingName = null;
    } on AuthFailure catch (failure) {
      await _refuse(failure.message);
    } finally {
      _provisioning = false;
    }
  }

  Future<void> _refuse(String notice) async {
    _expectedRole = null;
    _notice = notice;
    await _auth.signOut();
  }

  void _resolve(AuthGate gate) {
    final entry = _entry;
    if (entry == null) {
      state = gate;
      return;
    }
    _held = gate;
    if (!entry.isCompleted) entry.complete(gate);
  }

  static const _connectionNotice = 'Could not load your account. Try again.';

  /// Runs a sign-in action and holds the result back from the router until
  /// [release], so the role screen can finish its reveal first.
  Future<AuthGate> enter(
    PersonRole role,
    Future<void> Function(AuthService auth) action, {
    String? name,
  }) async {
    _expectedRole = role;
    _pendingName = name;
    final entry = _entry = Completer<AuthGate>();
    try {
      await action(_auth);
      return await entry.future.timeout(_entryTimeout);
    } on TimeoutException {
      await _refuse(_connectionNotice);
      return const SignedOut(_connectionNotice);
    } catch (_) {
      _entry = null;
      _expectedRole = null;
      rethrow;
    }
  }

  void release() {
    final held = _held;
    _entry = null;
    _held = null;
    state = switch (held) {
      SignedOut() => const SignedOut(),
      null => state,
      _ => held,
    };
  }

  void clearNotice() {
    if (state case SignedOut(notice: _?)) state = const SignedOut();
  }

  Future<void> checkVerification() => _auth.refresh();

  Future<void> resendVerification() => _auth.resendVerification();

  Future<void> signOut() => _auth.signOut();
}

final authGateProvider = NotifierProvider<AuthGateNotifier, AuthGate>(
  AuthGateNotifier.new,
);

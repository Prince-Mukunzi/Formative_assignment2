import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../models/auth_user.dart';
import 'backend.dart';

class AuthService {
  final SupabaseClient _client;
  final _awaitingCode = StreamController<AuthUser?>.broadcast();
  Future<void>? _googleReady;

  AuthService({SupabaseClient? client}) : _client = client ?? backend;

  GoTrueClient get _auth => _client.auth;

  /// Signed-in users, plus the email still waiting for its code: an
  /// unconfirmed account has no session, so the auth state alone cannot
  /// say a code is due.
  Stream<AuthUser?> get changes {
    final subscriptions = <StreamSubscription<AuthUser?>>[];
    late final StreamController<AuthUser?> merged;
    merged = StreamController<AuthUser?>(
      onListen: () => subscriptions.addAll([
        _auth.onAuthStateChange
            .map((state) => _toAuthUser(state.session?.user))
            .listen(merged.add, onError: merged.addError),
        _awaitingCode.stream.listen(merged.add),
      ]),
      onCancel: () => Future.wait([for (final s in subscriptions) s.cancel()]),
    );
    return merged.stream;
  }

  AuthUser? _toAuthUser(User? user) {
    final email = user?.email;
    if (user == null || email == null) return null;
    return AuthUser(
      uid: user.id,
      email: email.toLowerCase(),
      emailVerified: user.emailConfirmedAt != null,
    );
  }

  void _expectCode(String email) => _awaitingCode.add(
    AuthUser(uid: '', email: email.toLowerCase(), emailVerified: false),
  );

  Future<void> signIn(String email, String password) => _guard(() async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (error) {
      if (error.code != 'email_not_confirmed') rethrow;
      await _auth.resend(type: OtpType.signup, email: email);
      _expectCode(email);
    }
  });

  Future<void> signUp(String email, String password, {String? name}) =>
      _guard(() async {
        final response = await _auth.signUp(
          email: email,
          password: password,
          data: {'name': ?name},
        );
        if (response.session == null) _expectCode(email);
      });

  Future<void> verifyCode(String email, String code) => _guard(
    () => _auth.verifyOTP(type: OtpType.signup, email: email, token: code),
  );

  Future<void> resendCode(String email) =>
      _guard(() => _auth.resend(type: OtpType.signup, email: email));

  // The native iOS SDK aborts the whole app when it has no client ID, so
  // refuse here instead of letting the tap crash.
  Future<void> signInWithGoogle() => _guard(() async {
    const iosClientId = BackendConfig.googleIosClientId;
    const webClientId = BackendConfig.googleWebClientId;
    if (webClientId.isEmpty || (Platform.isIOS && iosClientId.isEmpty)) {
      throw const AuthFailure('Google sign-in is not set up yet.');
    }
    final google = GoogleSignIn.instance;
    await (_googleReady ??= google.initialize(
      clientId: Platform.isIOS ? iosClientId : null,
      serverClientId: webClientId,
    ));
    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelled();
      }
      throw const AuthFailure('Google sign-in did not finish. Try again.');
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthFailure('Google sign-in did not finish. Try again.');
    }
    await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  });

  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.resetPasswordForEmail(email));

  Future<void> provision({String? name}) => _guard(
    () =>
        _client.rpc<void>('provision_account', params: {'display_name': name}),
  );

  Future<void> signOut() async {
    if (_googleReady != null) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
    _awaitingCode.add(null);
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action().timeout(backendTimeout);
    } on TimeoutException {
      throw const AuthFailure('That took too long. Check your connection.');
    } on SocketException {
      throw const AuthFailure('No connection. Check your network.');
    } on AuthException catch (error) {
      throw AuthFailure(_authMessage(error));
    } on PostgrestException catch (error) {
      throw AuthFailure(switch (error.message) {
        'no-access' =>
          'This email has no access. Students sign in with their '
              '@alustudent.com email. Faculty and admins need an invite.',
        'unverified' => 'Verify your email first.',
        _ => 'Could not set up your account. Try again.',
      });
    }
  }

  String _authMessage(AuthException error) => switch (error.code) {
    'email_address_invalid' ||
    'validation_failed' => 'That email does not look right.',
    'invalid_credentials' => 'Email or password is incorrect.',
    'user_already_exists' ||
    'email_exists' => 'That email already has an account. Sign in.',
    'weak_password' => 'Use at least 8 characters for your password.',
    'otp_expired' => 'That code is wrong or has expired.',
    'over_request_rate_limit' || 'over_email_send_rate_limit' =>
      'Too many attempts. Wait a minute and try again.',
    'user_banned' => 'This account is disabled.',
    null when error is AuthRetryableFetchException =>
      'No connection. Check your network.',
    _ => 'Something went wrong. Try again.',
  };
}

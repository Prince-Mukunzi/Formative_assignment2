import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';
import '../models/auth_user.dart';
import 'firebase_setup.dart';

class AuthService {
  static const _timeout = Duration(seconds: 20);

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  Future<void>? _googleReady;

  AuthService({FirebaseAuth? auth, FirebaseFunctions? functions})
    : _auth = auth ?? FirebaseAuth.instance,
      _functions =
          functions ?? FirebaseFunctions.instanceFor(region: functionsRegion);

  Stream<AuthUser?> get changes => _auth.userChanges().map(_toAuthUser);

  AuthUser? _toAuthUser(User? user) {
    final email = user?.email;
    if (user == null || email == null) return null;
    return AuthUser(
      uid: user.uid,
      email: email.toLowerCase(),
      emailVerified: user.emailVerified,
    );
  }

  Future<void> signIn(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(email: email, password: password),
  );

  Future<void> signUp(String email, String password) => _guard(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
  });

  // The native iOS SDK aborts the whole app when it has no client ID, so
  // refuse here instead of letting the tap crash.
  Future<void> signInWithGoogle() => _guard(() async {
    final clientId = DefaultFirebaseOptions.currentPlatform.iosClientId;
    if (Platform.isIOS && clientId == null) {
      throw const AuthFailure('Google sign-in is not set up yet.');
    }
    final google = GoogleSignIn.instance;
    await (_googleReady ??= google.initialize(clientId: clientId));
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
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  });

  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  Future<void> resendVerification() =>
      _guard(() async => _auth.currentUser?.sendEmailVerification());

  // The ID token keeps the old email_verified claim until it is refreshed,
  // and the provisioning function reads that claim.
  Future<void> refresh() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.reload();
    final current = _auth.currentUser;
    if (current != null && current.emailVerified) {
      await current.getIdToken(true);
    }
  });

  Future<void> provision({String? name}) => _guard(
    () => _functions.httpsCallable('provisionAccount').call<Object?>({
      'name': ?name,
    }),
  );

  Future<void> signOut() async {
    if (_googleReady != null) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action().timeout(_timeout);
    } on TimeoutException {
      throw const AuthFailure('That took too long. Check your connection.');
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_authMessage(error.code));
    } on FirebaseFunctionsException catch (error) {
      throw AuthFailure(switch (error.code) {
        'permission-denied' =>
          'This email has no access. Students sign in with their '
              '@alustudent.com email. Faculty and admins need an invite.',
        'failed-precondition' => 'Verify your email first.',
        _ => 'Could not set up your account. Try again.',
      });
    }
  }

  String _authMessage(String code) => switch (code) {
    'invalid-email' => 'That email does not look right.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Email or password is incorrect.',
    'email-already-in-use' => 'That email already has an account. Sign in.',
    'weak-password' => 'Use at least 8 characters for your password.',
    'too-many-requests' => 'Too many attempts. Wait a minute and try again.',
    'network-request-failed' => 'No connection. Check your network.',
    'user-disabled' => 'This account is disabled.',
    _ => 'Something went wrong. Try again.',
  };
}

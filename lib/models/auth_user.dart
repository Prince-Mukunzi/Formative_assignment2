class AuthUser {
  final String uid;
  final String email;
  final bool emailVerified;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
  });
}

class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}

class AuthCancelled implements Exception {
  const AuthCancelled();
}

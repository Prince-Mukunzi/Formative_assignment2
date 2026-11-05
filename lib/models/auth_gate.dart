import 'person.dart';
import 'session.dart';

sealed class AuthGate {
  const AuthGate();
}

final class AuthLoading extends AuthGate {
  const AuthLoading();
}

final class SignedOut extends AuthGate {
  final String? notice;

  const SignedOut([this.notice]);
}

final class NeedsVerification extends AuthGate {
  final String email;

  const NeedsVerification(this.email);
}

final class Suspended extends AuthGate {
  const Suspended();
}

final class Blocked extends AuthGate {
  final String message;

  const Blocked(this.message);
}

final class Ready extends AuthGate {
  final Session session;
  final Person person;

  const Ready(this.session, this.person);
}

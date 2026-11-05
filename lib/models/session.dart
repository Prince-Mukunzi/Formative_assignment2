import 'person.dart';

sealed class Session {
  final String uid;
  final String name;
  final String email;

  const Session({required this.uid, required this.name, required this.email});

  PersonRole get role;

  static Session? of(Person person) => switch (person.role) {
    PersonRole.student => StudentSession(
      uid: person.id,
      name: person.name,
      email: person.email,
    ),
    PersonRole.admin => AdminSession(
      uid: person.id,
      name: person.name,
      email: person.email,
    ),
    PersonRole.faculty => switch (person.departmentId) {
      final departmentId? => FacultySession(
        departmentId,
        uid: person.id,
        name: person.name,
        email: person.email,
      ),
      null => null,
    },
  };
}

final class StudentSession extends Session {
  const StudentSession({
    required super.uid,
    required super.name,
    required super.email,
  });

  @override
  PersonRole get role => PersonRole.student;
}

final class FacultySession extends Session {
  final String departmentId;

  const FacultySession(
    this.departmentId, {
    required super.uid,
    required super.name,
    required super.email,
  });

  @override
  PersonRole get role => PersonRole.faculty;
}

final class AdminSession extends Session {
  const AdminSession({
    required super.uid,
    required super.name,
    required super.email,
  });

  @override
  PersonRole get role => PersonRole.admin;
}

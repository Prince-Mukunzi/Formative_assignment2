import 'department.dart';

sealed class Session {
  const Session();

  Map<String, Object?> toMap();

  static Session fromMap(Map<String, dynamic> map) {
    return switch (map['role']) {
      'student' => const StudentSession(),
      'faculty' => FacultySession(
        Department.values.byName(map['department'] as String),
      ),
      final role => throw FormatException('Unknown role: $role'),
    };
  }
}

final class StudentSession extends Session {
  const StudentSession();

  @override
  Map<String, Object?> toMap() => {'role': 'student'};
}

final class FacultySession extends Session {
  final Department department;

  const FacultySession(this.department);

  @override
  Map<String, Object?> toMap() => {
    'role': 'faculty',
    'department': department.name,
  };
}

sealed class Session {
  const Session();

  Map<String, Object?> toMap();

  static Session fromMap(Map<String, dynamic> map) {
    return switch (map['role']) {
      'student' => const StudentSession(),
      'faculty' => FacultySession(map['department'] as String),
      'admin' => const AdminSession(),
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
  final String departmentId;

  const FacultySession(this.departmentId);

  @override
  Map<String, Object?> toMap() => {
    'role': 'faculty',
    'department': departmentId,
  };
}

final class AdminSession extends Session {
  const AdminSession();

  @override
  Map<String, Object?> toMap() => {'role': 'admin'};
}

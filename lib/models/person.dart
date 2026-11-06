enum PersonRole {
  student('Student'),
  faculty('Faculty'),
  admin('Admin');

  const PersonRole(this.label);
  final String label;
}

class Person {
  final String id;
  final String name;
  final String email;
  final PersonRole role;
  final String? departmentId;
  final bool suspended;

  const Person({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.departmentId,
    this.suspended = false,
  });

  factory Person.fromRow(Map<String, dynamic> row) => Person(
    id: row['id'] as String,
    name: row['name'] as String,
    email: row['email'] as String,
    role: PersonRole.values.byName(row['role'] as String),
    departmentId: row['department_id'] as String?,
    suspended: row['suspended'] as bool,
  );
}

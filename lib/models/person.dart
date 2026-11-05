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
  final Set<String> celebrated;

  const Person({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.departmentId,
    this.suspended = false,
    this.celebrated = const {},
  });

  factory Person.fromMap(String id, Map<String, dynamic> map) => Person(
    id: id,
    name: map['name'] as String,
    email: map['email'] as String,
    role: PersonRole.values.byName(map['role'] as String),
    departmentId: map['departmentId'] as String?,
    suspended: map['suspended'] as bool,
    celebrated: {
      for (final badge in map['celebrated'] as List<dynamic>) badge as String,
    },
  );
}

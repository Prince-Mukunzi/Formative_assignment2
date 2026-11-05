enum PersonRole { student, faculty }

class Person {
  final String id;
  final String name;
  final PersonRole role;
  final String? departmentId;
  final bool suspended;

  const Person({
    required this.id,
    required this.name,
    required this.role,
    this.departmentId,
    this.suspended = false,
  });

  Person copyWith({String? departmentId, bool? suspended}) => Person(
    id: id,
    name: name,
    role: role,
    departmentId: departmentId ?? this.departmentId,
    suspended: suspended ?? this.suspended,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'role': role.name,
    'departmentId': departmentId,
    'suspended': suspended,
  };

  factory Person.fromMap(Map<String, dynamic> map) => Person(
    id: map['id'] as String,
    name: map['name'] as String,
    role: PersonRole.values.byName(map['role'] as String),
    departmentId: map['departmentId'] as String?,
    suspended: map['suspended'] as bool,
  );
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/department.dart';
import 'backend.dart';
import 'row_decoding.dart';

class DirectoryService {
  final SupabaseClient _db;

  DirectoryService({SupabaseClient? db}) : _db = db ?? backend;

  Stream<List<Department>> watchDepartments() => _db
      .from('departments')
      .stream(primaryKey: ['id'])
      .order('label', ascending: true)
      .map((rows) => decodeRows(rows, Department.fromRow));

  /// The server also takes the saved team's categories from the others.
  Future<void> saveDepartment(Department department) =>
      _call('save_department', {
        'department': department.id,
        'department_label': department.label,
        'owned': [for (final category in department.categories) category.name],
      });

  Future<void> removeDepartment(String id) =>
      _call('remove_department', {'department': id});

  Stream<List<String>> watchLocations() => _db
      .from('locations')
      .stream(primaryKey: ['name'])
      .order('name', ascending: true)
      .map(
        (rows) => [
          for (final row in rows)
            if (row['name'] case final String name) name,
        ],
      );

  Future<void> addLocation(String location) =>
      _call('add_location', {'location': location});

  Future<void> removeLocation(String location) =>
      _call('remove_location', {'location': location});

  Future<void> _call(String function, Map<String, Object?> params) =>
      _db.rpc<void>(function, params: params).timeout(backendTimeout);
}

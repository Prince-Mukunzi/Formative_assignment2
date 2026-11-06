import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/person.dart';
import 'backend.dart';
import 'row_decoding.dart';

class ProfileService {
  final SupabaseClient _db;

  ProfileService({SupabaseClient? db}) : _db = db ?? backend;

  Stream<Person?> watch(String uid) => _db
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', uid)
      .map(
        (rows) => rows.isEmpty ? null : decodeRow(rows.first, Person.fromRow),
      );

  Stream<List<Person>> watchAll() => _db
      .from('profiles')
      .stream(primaryKey: ['id'])
      .order('name', ascending: true)
      .map((rows) => decodeRows(rows, Person.fromRow));

  Future<void> setSuspended(String uid, {required bool suspended}) =>
      _call('set_suspended', {'member': uid, 'is_suspended': suspended});

  Future<void> moveToDepartment(String uid, String departmentId) =>
      _call('move_to_department', {'member': uid, 'department': departmentId});

  Future<void> invite({
    required String email,
    required PersonRole role,
    String? departmentId,
  }) => _call('invite_member', {
    'invitee': email,
    'member_role': role.name,
    'department': departmentId,
  });

  Future<void> _call(String function, Map<String, Object?> params) =>
      _db.rpc<void>(function, params: params).timeout(backendTimeout);
}

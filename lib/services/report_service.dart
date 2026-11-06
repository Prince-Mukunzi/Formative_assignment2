import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/report.dart';
import '../models/report_category.dart';
import 'backend.dart';
import 'row_decoding.dart';

/// Reads stream from the reports table; every write is a database function
/// that checks the caller's role and the report's state.
class ReportService {
  final SupabaseClient _db;

  ReportService({SupabaseClient? db}) : _db = db ?? backend;

  String newId() => const Uuid().v4();

  Stream<List<Report>> watchAll() => _db
      .from('reports')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((rows) => decodeRows(rows, Report.fromRow));

  Stream<Set<String>> watchUpvotedBy(String uid) => _db
      .from('upvotes')
      .stream(primaryKey: ['report_id', 'uid'])
      .eq('uid', uid)
      .map(
        (rows) => {
          for (final row in rows)
            if (row['report_id'] case final String id) id,
        },
      );

  Future<void> create({
    required String id,
    required String title,
    required String description,
    required String location,
    required ReportCategory category,
    required String imageUrl,
  }) => _call('file_report', {
    'report_id': id,
    ..._content(title, description, location, category, imageUrl),
  });

  Future<void> editContent(
    String id, {
    required String title,
    required String description,
    required String location,
    required ReportCategory category,
    required String imageUrl,
  }) => _call('edit_report', {
    'report_id': id,
    ..._content(title, description, location, category, imageUrl),
  });

  Map<String, Object?> _content(
    String title,
    String description,
    String location,
    ReportCategory category,
    String imageUrl,
  ) => {
    'title': title,
    'description': description,
    'location': location,
    'category': category.name,
    'image_url': imageUrl,
  };

  Future<void> setUpvote(String id, {required bool on}) =>
      _call('set_upvote', {'report_id': id, 'upvoted': on});

  Future<void> nudge(String id) => _call('nudge_report', {'report_id': id});

  Future<void> approve(String id) => _call('approve_report', {'report_id': id});

  Future<void> decline(String id) => _call('decline_report', {'report_id': id});

  Future<void> resolve(String id) => _call('resolve_report', {'report_id': id});

  Future<void> confirmFix(String id) => _call('confirm_fix', {'report_id': id});

  // Restarts the clock on the shorter reopen window, see SlaPolicy.
  Future<void> reopen(String id) => _call('reopen_report', {'report_id': id});

  Future<void> reassign(String id, String departmentId) =>
      _call('reassign_report', {'report_id': id, 'department': departmentId});

  Future<void> delete(String id) => _call('delete_report', {'report_id': id});

  Future<void> _call(String function, Map<String, Object?> params) =>
      _db.rpc<void>(function, params: params).timeout(backendTimeout);
}

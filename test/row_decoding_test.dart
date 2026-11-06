import 'package:alu_bug_bounty/models/report.dart';
import 'package:alu_bug_bounty/models/report_category.dart';
import 'package:alu_bug_bounty/models/report_status.dart';
import 'package:alu_bug_bounty/services/row_decoding.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> reportRow({Map<String, dynamic> overrides = const {}}) => {
  'id': '7f1c2b4e-0000-4000-8000-000000000001',
  'title': 'Broken sink',
  'description': 'Leaks',
  'location': 'Block A',
  'category': 'water',
  'image_url': '',
  'status': 'awaitingApproval',
  'upvotes': 2,
  'nudges': 0,
  'reopen_count': 0,
  'reported_by': 'u1',
  'reported_by_name': 'Ada',
  'assigned_department_id': null,
  'created_at': '2026-11-06T09:30:00+00:00',
  'approved_at': null,
  'resolved_at': '2026-11-07T10:00:00.123456+00:00',
  'verified_at': null,
  'last_nudged_at': null,
  'updated_at': '2026-11-07T10:00:00.123456+00:00',
  'updated_by': 'u1',
  ...overrides,
};

void main() {
  test('a report row decodes with UTC timestamps read as local time', () {
    final report = Report.fromRow(reportRow());
    expect(report.category, ReportCategory.water);
    expect(report.status, ReportStatus.awaitingApproval);
    expect(report.upvotes, 2);
    expect(report.createdAt.isUtc, isFalse);
    expect(report.createdAt.toUtc(), DateTime.utc(2026, 11, 6, 9, 30));
    expect(report.resolvedAt, isNotNull);
    expect(report.approvedAt, isNull);
  });

  test('a malformed row is skipped instead of breaking the list', () {
    final reports = decodeRows([
      reportRow(),
      reportRow(overrides: {'status': 'lost'}),
      reportRow(overrides: {'created_at': null}),
    ], Report.fromRow);
    expect(reports, hasLength(1));
  });
}

import 'package:alu_bug_bounty/models/report_category.dart';
import 'package:alu_bug_bounty/models/report_status.dart';
import 'package:alu_bug_bounty/services/report_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore db;
  late ReportService service;

  setUp(() {
    db = FakeFirebaseFirestore();
    service = ReportService(db: db);
  });

  Future<String> file() async {
    final id = service.newId();
    await service.create(
      id: id,
      uid: 'u1',
      name: 'Ada',
      title: 'Broken sink',
      description: 'Leaks',
      location: 'Block A',
      category: ReportCategory.water,
      imageUrl: '',
    );
    return id;
  }

  test('a filed report reads back as awaiting approval', () async {
    final id = await file();
    final reports = await service.watchAll().first;
    expect(reports.single.id, id);
    expect(reports.single.status, ReportStatus.awaitingApproval);
    expect(reports.single.reportedBy, 'u1');
  });

  test('a malformed document is skipped instead of breaking the list', () async {
    await file();
    await db.collection('reports').doc('bad').set({
      'title': 'No other fields',
      'createdAt': DateTime(2026),
    });
    expect(await service.watchAll().first, hasLength(1));
  });

  test('upvotes are tracked per student', () async {
    final id = await file();
    await service.setUpvote(id, 'u2', on: true);
    expect(await service.watchUpvotedBy('u2').first, {id});
    expect((await service.watchAll().first).single.upvotes, 1);
    await service.setUpvote(id, 'u2', on: false);
    expect(await service.watchUpvotedBy('u2').first, isEmpty);
  });

  test('staff actions stamp who acted', () async {
    final id = await file();
    await service.approve(id, 'staff');
    final doc = await db.collection('reports').doc(id).get();
    expect(doc.get('status'), 'inProgress');
    expect(doc.get('updatedBy'), 'staff');
  });
}

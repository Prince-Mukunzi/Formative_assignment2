import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report.dart';
import '../models/report_category.dart';
import 'firestore_decoding.dart';

class ReportService {
  final FirebaseFirestore _db;

  ReportService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection('reports');

  String newId() => _reports.doc().id;

  Stream<List<Report>> watchAll() => _reports
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => [
          for (final doc in snapshot.docs) ?decodeOrSkip(doc, Report.fromMap),
        ],
      );

  Stream<Set<String>> watchUpvotedBy(String uid) => _db
      .collectionGroup('upvotes')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map(
        (snapshot) => {
          for (final doc in snapshot.docs) ?doc.reference.parent.parent?.id,
        },
      );

  Future<void> create({
    required String id,
    required String uid,
    required String name,
    required String title,
    required String description,
    required String location,
    required ReportCategory category,
    required String imageUrl,
  }) => _reports.doc(id).set({
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'status': 'awaitingApproval',
    'category': category.name,
    'upvotes': 0,
    'location': location,
    'reportedBy': uid,
    'reportedByName': name,
    'createdAt': FieldValue.serverTimestamp(),
    'approvedAt': null,
    'resolvedAt': null,
    'verifiedAt': null,
    'lastNudgedAt': null,
    'nudges': 0,
    'reopenCount': 0,
    'assignedDepartmentId': null,
    'updatedBy': uid,
  });

  Future<void> editContent(
    String id, {
    required String uid,
    required String title,
    required String description,
    required String location,
    required ReportCategory category,
    required String imageUrl,
  }) => _update(id, uid, {
    'title': title,
    'description': description,
    'location': location,
    'category': category.name,
    'imageUrl': imageUrl,
  });

  Future<void> setUpvote(String id, String uid, {required bool on}) {
    final batch = _db.batch();
    final upvote = _reports.doc(id).collection('upvotes').doc(uid);
    batch.update(_reports.doc(id), {
      'upvotes': FieldValue.increment(on ? 1 : -1),
      'updatedBy': uid,
    });
    if (on) {
      batch.set(upvote, {
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      batch.delete(upvote);
    }
    return batch.commit();
  }

  Future<void> nudge(String id, String uid) => _update(id, uid, {
    'nudges': FieldValue.increment(1),
    'lastNudgedAt': FieldValue.serverTimestamp(),
  });

  Future<void> approve(String id, String uid) => _update(id, uid, {
    'status': 'inProgress',
    'approvedAt': FieldValue.serverTimestamp(),
  });

  Future<void> decline(String id, String uid) =>
      _update(id, uid, {'status': 'declined'});

  Future<void> resolve(String id, String uid) => _update(id, uid, {
    'status': 'resolved',
    'resolvedAt': FieldValue.serverTimestamp(),
  });

  Future<void> confirmFix(String id, String uid) =>
      _update(id, uid, {'verifiedAt': FieldValue.serverTimestamp()});

  // Restarts the clock on the shorter reopen window, see SlaPolicy.
  Future<void> reopen(String id, String uid) => _update(id, uid, {
    'status': 'inProgress',
    'approvedAt': FieldValue.serverTimestamp(),
    'resolvedAt': null,
    'verifiedAt': null,
    'reopenCount': FieldValue.increment(1),
  });

  Future<void> reassign(String id, String uid, String departmentId) =>
      _update(id, uid, {'assignedDepartmentId': departmentId});

  Future<void> delete(String id) => _reports.doc(id).delete();

  Future<void> _update(String id, String uid, Map<String, Object?> fields) =>
      _reports.doc(id).update({...fields, 'updatedBy': uid});
}

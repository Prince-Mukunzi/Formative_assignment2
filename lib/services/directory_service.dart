import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/department.dart';
import 'firestore_decoding.dart';

class DirectoryService {
  final FirebaseFirestore _db;

  DirectoryService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _departments =>
      _db.collection('departments');

  DocumentReference<Map<String, dynamic>> get _locations =>
      _db.doc('config/locations');

  Stream<List<Department>> watchDepartments() =>
      _departments.orderBy('label').snapshots().map(
        (snapshot) => [
          for (final doc in snapshot.docs) ?decodeOrSkip(doc, Department.fromMap),
        ],
      );

  Future<void> saveDepartments(List<Department> departments) {
    final batch = _db.batch();
    for (final department in departments) {
      batch.set(_departments.doc(department.id), department.toMap());
    }
    return batch.commit();
  }

  Future<void> removeDepartment(String id) => _departments.doc(id).delete();

  Stream<List<String>> watchLocations() => _locations.snapshots().map(
    (doc) => [
      for (final item in doc.data()?['items'] as List<dynamic>? ?? const [])
        if (item is String) item,
    ],
  );

  Future<void> addLocation(String location) => _locations.set({
    'items': FieldValue.arrayUnion([location]),
  }, SetOptions(merge: true));

  Future<void> removeLocation(String location) => _locations.update({
    'items': FieldValue.arrayRemove([location]),
  });
}

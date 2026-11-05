import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/person.dart';

class ProfileService {
  final FirebaseFirestore _db;

  ProfileService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // A cached "missing" is not trusted: on a new device the profile exists
  // on the server but not yet locally.
  Stream<Person?> watch(String uid) => _users
      .doc(uid)
      .snapshots(includeMetadataChanges: true)
      .where((doc) => doc.exists || !doc.metadata.isFromCache)
      .map((doc) => doc.exists ? _decode(doc) : null);

  Stream<List<Person>> watchAll() => _users.snapshots().map(
    (snapshot) => [
      for (final doc in snapshot.docs) ?_decode(doc),
    ],
  );

  Person? _decode(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      return Person.fromMap(doc.id, doc.data()!);
    } on Object catch (error) {
      developer.log('Skipped malformed user ${doc.id}', error: error, level: 900);
      return null;
    }
  }

  Future<void> setSuspended(String uid, {required bool suspended}) =>
      _users.doc(uid).update({'suspended': suspended});

  Future<void> moveToDepartment(String uid, String departmentId) =>
      _users.doc(uid).update({'departmentId': departmentId});

  Future<void> invite({
    required String email,
    required PersonRole role,
    required String invitedBy,
    String? departmentId,
  }) => _db.collection('invites').doc(email.trim().toLowerCase()).set({
    'role': role.name,
    'departmentId': ?departmentId,
    'invitedBy': invitedBy,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

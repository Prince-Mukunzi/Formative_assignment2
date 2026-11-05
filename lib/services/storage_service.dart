import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static const _timeout = Duration(seconds: 60);

  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadReportImage({
    required String uid,
    required String reportId,
    required String localPath,
  }) async {
    final extension = localPath.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'png' => 'image/png',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref('reports/$uid/$reportId/$stamp.$extension');
    await ref
        .putFile(File(localPath), SettableMetadata(contentType: contentType))
        .timeout(_timeout);
    return ref.getDownloadURL().timeout(_timeout);
  }
}

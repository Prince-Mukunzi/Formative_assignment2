import 'dart:developer' as developer;
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend.dart';

class StorageService {
  static const _timeout = Duration(seconds: 60);

  final SupabaseClient _db;

  StorageService({SupabaseClient? db}) : _db = db ?? backend;

  StorageFileApi get _photos => _db.storage.from(photoBucket);

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
    final path = '$uid/$reportId/$stamp.$extension';
    await _photos
        .upload(
          path,
          File(localPath),
          fileOptions: FileOptions(contentType: contentType),
        )
        .timeout(_timeout);
    return _photos.getPublicUrl(path);
  }

  /// Best effort: a photo left behind costs storage, not correctness.
  Future<void> removeReportImage(String imageUrl) async {
    final path = _pathOf(imageUrl);
    if (path == null) return;
    try {
      await _photos.remove([path]).timeout(_timeout);
    } on Object catch (error) {
      developer.log('Could not remove $path', error: error, level: 900);
    }
  }

  String? _pathOf(String imageUrl) {
    final marker = '/object/public/$photoBucket/';
    final index = imageUrl.indexOf(marker);
    if (index < 0) return null;
    return Uri.decodeComponent(imageUrl.substring(index + marker.length));
  }
}

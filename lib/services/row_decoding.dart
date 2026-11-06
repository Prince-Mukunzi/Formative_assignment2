import 'dart:developer' as developer;

/// Decodes each row, skipping any that do not match the model so a single
/// bad row cannot break a whole list.
List<T> decodeRows<T>(
  List<Map<String, dynamic>> rows,
  T Function(Map<String, dynamic> row) decode,
) => [for (final row in rows) ?decodeRow(row, decode)];

T? decodeRow<T>(
  Map<String, dynamic> row,
  T Function(Map<String, dynamic> row) decode,
) {
  try {
    return decode(row);
  } on Object catch (error) {
    developer.log('Skipped malformed row $row', error: error, level: 900);
    return null;
  }
}

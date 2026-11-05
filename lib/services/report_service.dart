import '../core/mock_data.dart';
import '../models/report.dart';
import 'local_store.dart';

class ReportService {
  static const _key = 'reports.v1';

  final LocalStore _store;

  const ReportService(this._store);

  List<Report> load() {
    final raw = _store.read(_key);
    if (raw == null) return MockData.reports;
    return [
      for (final item in raw as List<dynamic>)
        Report.fromMap(item as Map<String, dynamic>),
    ];
  }

  Future<void> save(List<Report> reports) =>
      _store.write(_key, [for (final report in reports) report.toMap()]);
}

import '../core/mock_data.dart';
import '../models/department.dart';
import '../models/person.dart';
import 'local_store.dart';

class DirectoryService {
  static const _departmentsKey = 'departments.v1';
  static const _peopleKey = 'people.v1';
  static const _locationsKey = 'locations.v1';

  final LocalStore _store;

  const DirectoryService(this._store);

  List<Department> loadDepartments() {
    final raw = _store.read(_departmentsKey);
    if (raw == null) return MockData.departments;
    return [
      for (final item in raw as List<dynamic>)
        Department.fromMap(item as Map<String, dynamic>),
    ];
  }

  Future<void> saveDepartments(List<Department> departments) => _store.write(
    _departmentsKey,
    [for (final department in departments) department.toMap()],
  );

  List<Person> loadPeople() {
    final raw = _store.read(_peopleKey);
    if (raw == null) return MockData.people;
    return [
      for (final item in raw as List<dynamic>)
        Person.fromMap(item as Map<String, dynamic>),
    ];
  }

  Future<void> savePeople(List<Person> people) =>
      _store.write(_peopleKey, [for (final person in people) person.toMap()]);

  List<String> loadLocations() {
    final raw = _store.read(_locationsKey);
    if (raw == null) return MockData.locations;
    return [for (final item in raw as List<dynamic>) item as String];
  }

  Future<void> saveLocations(List<String> locations) =>
      _store.write(_locationsKey, locations);
}

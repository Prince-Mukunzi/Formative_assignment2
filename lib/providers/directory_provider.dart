import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/department.dart';
import '../models/person.dart';
import '../models/session.dart';
import '../services/directory_service.dart';
import 'session_provider.dart';

final directoryServiceProvider = Provider(
  (ref) => DirectoryService(ref.watch(localStoreProvider)),
);

class DepartmentsNotifier extends Notifier<List<Department>> {
  @override
  List<Department> build() =>
      ref.watch(directoryServiceProvider).loadDepartments();

  void _set(List<Department> next) {
    state = next;
    ref.read(directoryServiceProvider).saveDepartments(next);
  }

  void save(Department department) => _set(state.withSaved(department));

  void remove(String id) => _set([
    for (final department in state)
      if (department.id != id) department,
  ]);
}

final departmentsProvider =
    NotifierProvider<DepartmentsNotifier, List<Department>>(
      DepartmentsNotifier.new,
    );

final currentDepartmentProvider = Provider<Department?>((ref) {
  final session = ref.watch(sessionProvider);
  if (session is! FacultySession) return null;
  return ref.watch(departmentsProvider).byId(session.departmentId);
});

class PeopleNotifier extends Notifier<List<Person>> {
  @override
  List<Person> build() => ref.watch(directoryServiceProvider).loadPeople();

  void _update(String id, Person Function(Person) change) {
    final next = [
      for (final person in state)
        if (person.id == id) change(person) else person,
    ];
    state = next;
    ref.read(directoryServiceProvider).savePeople(next);
  }

  void setSuspended(String id, {required bool suspended}) =>
      _update(id, (p) => p.copyWith(suspended: suspended));

  void moveToDepartment(String id, String departmentId) =>
      _update(id, (p) => p.copyWith(departmentId: departmentId));
}

final peopleProvider = NotifierProvider<PeopleNotifier, List<Person>>(
  PeopleNotifier.new,
);

class LocationsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.watch(directoryServiceProvider).loadLocations();

  void _set(List<String> next) {
    state = next;
    ref.read(directoryServiceProvider).saveLocations(next);
  }

  void add(String location) {
    if (location.isEmpty || state.contains(location)) return;
    _set([...state, location]);
  }

  void remove(String location) => _set([
    for (final existing in state)
      if (existing != location) existing,
  ]);
}

final locationsProvider = NotifierProvider<LocationsNotifier, List<String>>(
  LocationsNotifier.new,
);

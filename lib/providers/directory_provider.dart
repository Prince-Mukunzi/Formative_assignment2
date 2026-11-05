import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/department.dart';
import '../models/person.dart';
import '../models/session.dart';
import '../services/directory_service.dart';
import 'auth_provider.dart';
import 'session_provider.dart';
import 'sync_provider.dart';

final directoryServiceProvider = Provider((ref) => DirectoryService());

DirectoryService _directory(Ref ref) => ref.read(directoryServiceProvider);

class DepartmentsNotifier extends Notifier<List<Department>> {
  @override
  List<Department> build() {
    if (ref.watch(sessionUidProvider) == null) return const [];
    follow(
      ref,
      ref.watch(directoryServiceProvider).watchDepartments(),
      Feed.departments,
      (next) => state = next,
    );
    return const [];
  }

  void save(Department department) {
    final next = state.withSaved(department);
    state = next;
    send(ref, _directory(ref).saveDepartments(next));
  }

  void remove(String id) {
    state = [
      for (final department in state)
        if (department.id != id) department,
    ];
    send(ref, _directory(ref).removeDepartment(id));
  }
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
  List<Person> build() {
    if (ref.watch(sessionProvider.select((s) => s is AdminSession))) {
      follow(
        ref,
        ref.watch(profileServiceProvider).watchAll(),
        Feed.people,
        (next) => state = next,
      );
    }
    return const [];
  }

  void setSuspended(String id, {required bool suspended}) => send(
    ref,
    ref.read(profileServiceProvider).setSuspended(id, suspended: suspended),
  );

  void moveToDepartment(String id, String departmentId) => send(
    ref,
    ref.read(profileServiceProvider).moveToDepartment(id, departmentId),
  );

  Future<void> invite({
    required String email,
    required PersonRole role,
    String? departmentId,
  }) async {
    final uid = ref.read(sessionUidProvider);
    if (uid == null) return;
    await ref
        .read(profileServiceProvider)
        .invite(
          email: email,
          role: role,
          invitedBy: uid,
          departmentId: departmentId,
        );
  }
}

final peopleProvider = NotifierProvider<PeopleNotifier, List<Person>>(
  PeopleNotifier.new,
);

class LocationsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    if (ref.watch(sessionUidProvider) == null) return const [];
    follow(
      ref,
      ref.watch(directoryServiceProvider).watchLocations(),
      Feed.locations,
      (next) => state = next,
    );
    return const [];
  }

  void add(String location) {
    if (location.isEmpty || state.contains(location)) return;
    send(ref, _directory(ref).addLocation(location));
  }

  void remove(String location) =>
      send(ref, _directory(ref).removeLocation(location));
}

final locationsProvider = NotifierProvider<LocationsNotifier, List<String>>(
  LocationsNotifier.new,
);

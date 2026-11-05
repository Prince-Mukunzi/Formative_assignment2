import 'package:flutter/cupertino.dart' show CupertinoPage;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_shell.dart';
import '../../features/auth/blocked_screen.dart';
import '../../features/auth/loading_screen.dart';
import '../../features/auth/verify_screen.dart';
import '../../features/faculty/faculty_shell.dart';
import '../../features/faculty/triage_screen.dart';
import '../../features/report/create_report_screen.dart';
import '../../features/rewards/progress_screen.dart';
import '../../features/role/role_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/shell/suspended_screen.dart';
import '../../models/auth_gate.dart';
import '../../models/department.dart';
import '../../models/session.dart';
import '../../providers/auth_provider.dart';
import '../../providers/directory_provider.dart';
import '../../providers/sync_provider.dart';

abstract final class AppRoutes {
  static const loading = '/loading';
  static const role = '/role';
  static const verify = '/verify';
  static const suspended = '/suspended';
  static const blocked = '/blocked';
  static const student = '/student';
  static const newReport = '/student/report/new';
  static String editReport(String id) => '/student/report/$id/edit';
  static const progress = '/student/progress';
  static const faculty = '/faculty';
  static const triage = '/faculty/triage';
  static const admin = '/admin';
}

Page<void> _fadeIn(Widget child) => CustomTransitionPage(
  child: child,
  transitionDuration: const Duration(milliseconds: 260),
  transitionsBuilder: (_, animation, _, child) =>
      FadeTransition(opacity: animation, child: child),
);

final routerProvider = Provider<GoRouter>((ref) {
  final gateChanges = ValueNotifier(0);
  ref.listen(authGateProvider, (_, _) => gateChanges.value++);
  ref.listen(dataReadyProvider, (_, _) => gateChanges.value++);
  ref.listen(departmentsProvider, (_, _) => gateChanges.value++);
  ref.onDispose(gateChanges.dispose);

  String? only(String location, String target) =>
      location == target ? null : target;

  return GoRouter(
    initialLocation: AppRoutes.loading,
    refreshListenable: gateChanges,
    redirect: (_, state) {
      final location = state.matchedLocation;
      return switch (ref.read(authGateProvider)) {
        AuthLoading() => only(location, AppRoutes.loading),
        SignedOut() => only(location, AppRoutes.role),
        NeedsVerification() => only(location, AppRoutes.verify),
        Suspended() => only(location, AppRoutes.suspended),
        Blocked() => only(location, AppRoutes.blocked),
        Ready() when !ref.read(dataReadyProvider) => only(
          location,
          AppRoutes.loading,
        ),
        Ready(session: FacultySession(:final departmentId))
            when ref.read(departmentsProvider).byId(departmentId) == null =>
          only(location, AppRoutes.blocked),
        Ready(:final session) => switch (session) {
          StudentSession() =>
            location.startsWith(AppRoutes.student) ? null : AppRoutes.student,
          FacultySession() =>
            location.startsWith(AppRoutes.faculty) ? null : AppRoutes.faculty,
          AdminSession() =>
            location.startsWith(AppRoutes.admin) ? null : AppRoutes.admin,
        },
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.loading,
        pageBuilder: (_, _) => _fadeIn(const LoadingScreen()),
      ),
      GoRoute(
        path: AppRoutes.verify,
        pageBuilder: (_, _) => _fadeIn(const VerifyScreen()),
      ),
      GoRoute(
        path: AppRoutes.suspended,
        pageBuilder: (_, _) => _fadeIn(const SuspendedScreen()),
      ),
      GoRoute(
        path: AppRoutes.blocked,
        pageBuilder: (_, _) => _fadeIn(const BlockedScreen()),
      ),
      GoRoute(
        path: AppRoutes.role,
        pageBuilder: (_, _) => _fadeIn(const RoleScreen()),
      ),
      GoRoute(
        path: AppRoutes.student,
        pageBuilder: (_, _) => _fadeIn(const AppShell()),
        routes: [
          GoRoute(
            path: 'report/new',
            pageBuilder: (_, _) =>
                const CupertinoPage(child: CreateReportScreen()),
          ),
          GoRoute(
            path: 'report/:id/edit',
            pageBuilder: (_, state) => CupertinoPage(
              child: CreateReportScreen(reportId: state.pathParameters['id']),
            ),
          ),
          GoRoute(
            path: 'progress',
            pageBuilder: (_, _) => const CupertinoPage(child: ProgressScreen()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.admin,
        pageBuilder: (_, _) => _fadeIn(const AdminShell()),
      ),
      GoRoute(
        path: AppRoutes.faculty,
        pageBuilder: (_, _) => _fadeIn(const FacultyShell()),
        routes: [
          GoRoute(
            path: 'triage',
            pageBuilder: (_, _) => const CupertinoPage(child: TriageScreen()),
          ),
        ],
      ),
    ],
  );
});

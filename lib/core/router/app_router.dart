import 'package:flutter/cupertino.dart' show CupertinoPage;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_shell.dart';
import '../../features/faculty/faculty_shell.dart';
import '../../features/faculty/triage_screen.dart';
import '../../features/report/create_report_screen.dart';
import '../../features/rewards/progress_screen.dart';
import '../../features/role/role_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../models/session.dart';
import '../../providers/session_provider.dart';

abstract final class AppRoutes {
  static const role = '/role';
  static const student = '/student';
  static const newReport = '/student/report/new';
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
  final sessionChanges = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => sessionChanges.value++);
  ref.onDispose(sessionChanges.dispose);

  return GoRouter(
    initialLocation: AppRoutes.role,
    refreshListenable: sessionChanges,
    redirect: (_, state) {
      final location = state.matchedLocation;
      return switch (ref.read(sessionProvider)) {
        null => location == AppRoutes.role ? null : AppRoutes.role,
        StudentSession() =>
          location.startsWith(AppRoutes.student) ? null : AppRoutes.student,
        FacultySession() =>
          location.startsWith(AppRoutes.faculty) ? null : AppRoutes.faculty,
        AdminSession() =>
          location.startsWith(AppRoutes.admin) ? null : AppRoutes.admin,
      };
    },
    routes: [
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

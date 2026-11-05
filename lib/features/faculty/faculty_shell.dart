import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/router/app_router.dart';
import '../../models/report.dart';
import '../../models/report_status.dart';
import '../../models/session.dart';
import '../../providers/reports_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/report_detail_sheet.dart';
import '../profile/profile_screen.dart';
import 'board_screen.dart';
import 'queue_screen.dart';

class FacultyShell extends ConsumerStatefulWidget {
  const FacultyShell({super.key});

  @override
  ConsumerState<FacultyShell> createState() => _FacultyShellState();
}

class _FacultyShellState extends ConsumerState<FacultyShell> {
  int _currentIndex = 0;

  void _onReportTap(Report report) => ReportDetailSheet.show(context, report);

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (session is! FacultySession) return const SizedBox.shrink();
    final department = session.department;
    final untriaged = ref
        .watch(reportsProvider)
        .where(
          (r) =>
              r.department == department &&
              r.status == ReportStatus.awaitingApproval,
        )
        .length;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            QueueScreen(department: department, onReportTap: _onReportTap),
            BoardScreen(department: department),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: AppBottomNav.facultyItems,
          action: NavActionButton(
            icon: HugeIcons.strokeRoundedCards01,
            badge: untriaged,
            onTap: () => context.push(AppRoutes.triage),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/mock_data.dart';
import '../../core/router/app_router.dart';
import '../../models/report.dart';
import '../../providers/directory_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/report_detail_sheet.dart';
import '../home/home_screen.dart';
import '../report/reports_list_screen.dart';
import '../profile/profile_screen.dart';
import '../rewards/reward_director.dart';
import 'suspended_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  void _onReportTap(Report report) {
    ReportDetailSheet.show(context, report);
  }

  @override
  Widget build(BuildContext context) {
    final suspended = ref.watch(
      peopleProvider.select(
        (people) =>
            people.any((p) => p.id == MockData.currentStudentId && p.suspended),
      ),
    );
    if (suspended) return const SuspendedScreen();
    return RewardDirector(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(onReportTap: _onReportTap),
              ReportsListScreen(onReportTap: _onReportTap),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: AppBottomNav.studentItems,
            action: NavActionButton(
              icon: HugeIcons.strokeRoundedAdd01,
              onTap: () => context.push(AppRoutes.newReport),
            ),
          ),
        ),
      ),
    );
  }
}

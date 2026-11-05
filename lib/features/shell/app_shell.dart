import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/report_detail_sheet.dart';
import '../home/home_screen.dart';
import '../report/reports_list_screen.dart';
import '../report/create_report_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _onReportTap(Report report) {
    ReportDetailSheet.show(context, report);
  }

  void _onCreateReport() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => const CreateReportScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onCreateReport: _onCreateReport,
      ),
    );
  }
}

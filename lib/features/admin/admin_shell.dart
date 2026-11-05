import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../widgets/app_bottom_nav.dart';
import '../profile/profile_screen.dart';
import 'overview_screen.dart';
import 'people_screen.dart';
import 'reports_screen.dart';
import 'team_sheet.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            OverviewScreen(),
            ReportsScreen(),
            PeopleScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: AppBottomNav.adminItems,
          action: NavActionButton(
            icon: HugeIcons.strokeRoundedAdd01,
            onTap: () => TeamSheet.show(context),
          ),
        ),
      ),
    );
  }
}

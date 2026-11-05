import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/notice_screen.dart';

class SuspendedScreen extends ConsumerWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NoticeScreen(
      title: 'Account suspended',
      message: 'Contact an administrator.',
      actions: [
        AppButton(
          label: 'Sign out',
          isFilled: false,
          onTap: () => ref.read(authGateProvider.notifier).signOut(),
        ),
      ],
    );
  }
}

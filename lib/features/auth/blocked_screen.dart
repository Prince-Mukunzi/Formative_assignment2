import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/auth_gate.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/notice_screen.dart';

class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = switch (ref.watch(authGateProvider)) {
      Blocked(:final message) => message,
      _ => 'Your team was removed. Contact an admin.',
    };
    return NoticeScreen(
      title: 'Not quite yet',
      message: message,
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

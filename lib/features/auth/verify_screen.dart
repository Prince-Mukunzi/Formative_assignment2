import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/auth_gate.dart';
import '../../models/auth_user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/notice_screen.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  static const _pollEvery = Duration(seconds: 4);

  late final Timer _poll;
  bool _resent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(_pollEvery, (_) => _check());
  }

  @override
  void dispose() {
    _poll.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    try {
      await ref.read(authGateProvider.notifier).checkVerification();
    } on AuthFailure {
      // Polling retries on its own; a single failed check is not worth a message.
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authGateProvider.notifier).resendVerification();
      if (mounted) setState(() => _resent = true);
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = switch (ref.watch(authGateProvider)) {
      NeedsVerification(:final email) => email,
      _ => 'your email',
    };
    return NoticeScreen(
      title: 'Check your inbox',
      message:
          _error ??
          'We sent a link to $email. Open it and this screen moves on by '
              'itself.',
      actions: [
        AppButton(
          label: _resent ? 'Sent again' : 'Resend link',
          onTap: _resent ? null : _resend,
        ),
        AppButton(
          label: 'Use another account',
          isFilled: false,
          onTap: () => ref.read(authGateProvider.notifier).signOut(),
        ),
      ],
    );
  }
}

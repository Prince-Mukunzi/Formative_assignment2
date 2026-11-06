import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../models/auth_gate.dart';
import '../../models/auth_user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/filled_field.dart';
import '../../widgets/notice_screen.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  static const _codeLength = 6;

  final _code = TextEditingController();
  bool _busy = false;
  bool _resent = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.length != _codeLength) {
      setState(() => _error = 'Enter the $_codeLength-digit code.');
      return;
    }
    await _attempt(() => ref.read(authGateProvider.notifier).verify(code));
  }

  Future<void> _resend() async {
    await _attempt(() => ref.read(authGateProvider.notifier).resendCode());
    if (mounted && _error == null) setState(() => _resent = true);
  }

  Future<void> _attempt(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
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
          'We sent a $_codeLength-digit code to $email. If this email '
              'already has an account, sign in instead.',
      actions: [
        FilledField(
          controller: _code,
          hint: 'Code',
          icon: HugeIcons.strokeRoundedSquareLock02,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_codeLength),
          ],
          onSubmitted: (_) => _verify(),
        ),
        AppButton(label: _busy ? 'Checking' : 'Verify', onTap: _verify),
        AppButton(
          label: _resent ? 'Sent again' : 'Resend code',
          isFilled: false,
          onTap: _resent || _busy ? null : _resend,
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

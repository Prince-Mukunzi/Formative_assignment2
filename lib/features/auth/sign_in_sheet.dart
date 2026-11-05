import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';
import '../../models/auth_gate.dart';
import '../../models/auth_user.dart';
import '../../models/person.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/filled_field.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/shake.dart';
import '../../widgets/motion/spring_expand.dart';

class SignInSheet extends ConsumerStatefulWidget {
  final PersonRole role;

  const SignInSheet({super.key, required this.role});

  /// Resolves with the gate the sign-in reached, or null if dismissed.
  static Future<AuthGate?> show(BuildContext context, PersonRole role) {
    return showModalBottomSheet<AuthGate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXxl),
        ),
      ),
      builder: (_) => SignInSheet(role: role),
    );
  }

  @override
  ConsumerState<SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends ConsumerState<SignInSheet> {
  static const _minPasswordLength = 8;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _creating = false;
  bool _busy = false;
  String? _message;
  bool _messageIsError = true;
  int _shake = 0;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String get _emailHint => switch (widget.role) {
    PersonRole.student => 'you@alustudent.com',
    _ => 'Email your invite was sent to',
  };

  void _fail(String message) {
    AppHaptics.mediumImpact();
    setState(() {
      _message = message;
      _messageIsError = true;
      _shake++;
    });
  }

  String? _validate() {
    if (_creating && _name.text.trim().isEmpty) return 'Add your name.';
    if (!_email.text.contains('@')) return 'Enter your email.';
    if (_password.text.length < _minPasswordLength) {
      return 'Use at least $_minPasswordLength characters for your password.';
    }
    return null;
  }

  Future<void> _submitPassword() {
    final invalid = _validate();
    if (invalid != null) {
      _fail(invalid);
      return Future.value();
    }
    final email = _email.text.trim();
    final password = _password.text;
    return _run(
      (auth) => _creating
          ? auth.signUp(email, password)
          : auth.signIn(email, password),
      name: _creating ? _name.text.trim() : null,
    );
  }

  Future<void> _run(
    Future<void> Function(AuthService auth) action, {
    String? name,
  }) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _message = null;
    });
    final gate = ref.read(authGateProvider.notifier);
    try {
      final result = await gate.enter(widget.role, action, name: name);
      if (!mounted) return;
      if (result case SignedOut(:final notice)) {
        gate.release();
        _fail(notice ?? 'Could not sign you in. Try again.');
      } else {
        Navigator.of(context).pop(result);
      }
    } on AuthCancelled {
      // The user closed the Google prompt; nothing to report.
    } on AuthFailure catch (failure) {
      if (mounted) _fail(failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (!email.contains('@')) return _fail('Enter your email first.');
    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      if (mounted) {
        setState(() {
          _message = 'Reset link sent to $email.';
          _messageIsError = false;
        });
      }
    } on AuthFailure catch (failure) {
      _fail(failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _message;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            AppSpacing.lg,
      ),
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _creating ? 'Create account' : '${widget.role.label} sign in',
              style: AppTextStyles.heading2,
            ),
            AppSpacing.verticalGapXl,
            SpringExpand(
              open: _creating,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FilledField(
                  controller: _name,
                  hint: 'Full name',
                  icon: HugeIcons.strokeRoundedUser,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                ),
              ),
            ),
            FilledField(
              controller: _email,
              hint: _emailHint,
              icon: HugeIcons.strokeRoundedMail01,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            AppSpacing.verticalGapSm,
            FilledField(
              controller: _password,
              hint: 'Password',
              icon: HugeIcons.strokeRoundedSquareLock02,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: [
                _creating ? AutofillHints.newPassword : AutofillHints.password,
              ],
              onSubmitted: (_) => _submitPassword(),
            ),
            if (message != null) ...[
              AppSpacing.verticalGapMd,
              Shake(
                trigger: _shake,
                child: Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _messageIsError
                        ? AppColors.brand
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            AppSpacing.verticalGapXl,
            AppButton(
              label: _busy
                  ? 'One moment'
                  : _creating
                  ? 'Create account'
                  : 'Sign in',
              onTap: _busy ? null : _submitPassword,
            ),
            AppSpacing.verticalGapSm,
            AppButton(
              label: 'Continue with Google',
              icon: HugeIcons.strokeRoundedGoogle,
              isFilled: false,
              onTap: _busy ? null : () => _run((auth) => auth.signInWithGoogle()),
            ),
            AppSpacing.verticalGapLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuietLink(
                  label: _creating ? 'I have an account' : 'Create account',
                  onTap: () => setState(() {
                    _creating = !_creating;
                    _message = null;
                  }),
                ),
                if (!_creating)
                  _QuietLink(label: 'Forgot password?', onTap: _resetPassword),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuietLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuietLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

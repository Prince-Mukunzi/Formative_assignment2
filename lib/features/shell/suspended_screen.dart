import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/session_provider.dart';
import '../../widgets/app_button.dart';

class SuspendedScreen extends ConsumerWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('Account suspended', style: AppTextStyles.heading1),
              AppSpacing.verticalGapXs,
              Text('Contact an administrator.', style: AppTextStyles.subtitle),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Sign out',
                  isFilled: false,
                  onTap: () => ref.read(sessionProvider.notifier).signOut(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

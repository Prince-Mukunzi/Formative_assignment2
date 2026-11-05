import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'motion/spring_in.dart';

class NoticeScreen extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actions;

  const NoticeScreen({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              SpringIn(child: Text(title, style: AppTextStyles.heading1)),
              AppSpacing.verticalGapXs,
              SpringIn(
                delay: const Duration(milliseconds: 80),
                child: Text(message, style: AppTextStyles.subtitle),
              ),
              const Spacer(),
              for (final (index, action) in actions.indexed) ...[
                if (index > 0) AppSpacing.verticalGapSm,
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

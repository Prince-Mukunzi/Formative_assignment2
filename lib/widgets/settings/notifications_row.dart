import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_settings.dart';
import '../../providers/session_provider.dart';
import '../../providers/settings_provider.dart';
import '../motion/pressable.dart';
import '../motion/spring_expand.dart';
import '../motion/spring_value.dart';
import '../tinted_icon.dart';
import 'toggle_row.dart';

class NotificationsRow extends ConsumerStatefulWidget {
  const NotificationsRow({super.key});

  @override
  ConsumerState<NotificationsRow> createState() => _NotificationsRowState();
}

class _NotificationsRowState extends ConsumerState<NotificationsRow> {
  static const _labelInset = 52.0;

  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final topics = NotificationTopic.forSession(ref.watch(sessionProvider));
    final muted = ref.watch(settingsProvider.select((s) => s.muted));
    final enabled = topics.where((topic) => !muted.contains(topic)).length;
    return Column(
      children: [
        Pressable(
          onTap: () => setState(() => _open = !_open),
          scale: 0.98,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                const TintedIcon(icon: HugeIcons.strokeRoundedNotification01),
                AppSpacing.horizontalGapMd,
                Expanded(
                  child: Text(
                    'Notifications',
                    style: AppTextStyles.labelMedium,
                  ),
                ),
                Text(
                  '$enabled of ${topics.length}',
                  style: AppTextStyles.bodySmall,
                ),
                AppSpacing.horizontalGapSm,
                SpringValue(
                  value: _open ? 1 : 0,
                  spring: AppSprings.bouncy,
                  builder: (_, t, child) =>
                      Transform.rotate(angle: t * math.pi / 2, child: child),
                  child: const Icon(
                    HugeIcons.strokeRoundedArrowRight01,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SpringExpand(
          open: _open,
          child: Padding(
            padding: const EdgeInsets.only(left: _labelInset),
            child: Column(
              children: [
                for (final topic in topics)
                  ToggleRow(
                    label: topic.label,
                    value: !muted.contains(topic),
                    onChanged: (value) => ref
                        .read(settingsProvider.notifier)
                        .setTopic(topic, enabled: value),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

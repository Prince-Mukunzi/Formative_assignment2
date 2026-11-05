import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_text_styles.dart';
import '../core/utils/time_format.dart';
import '../providers/clock_provider.dart';

class PostedLabel extends ConsumerWidget {
  final DateTime posted;

  const PostedLabel({super.key, required this.posted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      postedLabel(posted, ref.watch(minuteProvider)),
      style: AppTextStyles.bodySmall,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../models/game.dart';
import '../../models/notice.dart';
import '../../providers/game_provider.dart';
import '../../providers/notices_provider.dart';
import '../../providers/settings_provider.dart';
import 'reward_overlay.dart';

/// Turns pending XP into feedback. Also catches rewards earned while away,
/// such as faculty approving a report between sessions.
class RewardDirector extends ConsumerStatefulWidget {
  final Widget child;

  const RewardDirector({super.key, required this.child});

  @override
  ConsumerState<RewardDirector> createState() => _RewardDirectorState();
}

class _RewardDirectorState extends ConsumerState<RewardDirector> {
  // Lets the screen that triggered the reward finish transitioning first.
  static const _settle = Duration(milliseconds: 500);

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _present());
  }

  Future<void> _present() async {
    if (_busy) return;
    _busy = true;
    await Future<void>.delayed(_settle);
    if (!mounted) return;
    final RewardMoment? moment = ref.read(pendingRewardProvider);
    if (moment != null) {
      if (moment.deservesCelebration &&
          ref.read(settingsProvider).celebrations) {
        await RewardOverlay.show(context, moment);
      } else if (moment.gained > 0) {
        ref.read(noticesProvider.notifier).post(_xpNotice(moment));
      }
      if (mounted) ref.read(gameProvider.notifier).acknowledge(moment);
    }
    _busy = false;
  }

  // With celebrations off, or for small wins, XP still gets a quiet heads-up.
  Notice _xpNotice(RewardMoment moment) {
    final prize = moment.prizes.lastOrNull;
    final rank = moment.rankUp;
    return Notice(
      topic: NotificationTopic.prizes,
      title: '+${moment.gained} XP',
      body: prize != null
          ? 'Prize unlocked: ${prize.label}'
          : rank != null
          ? 'You reached ${rank.label}'
          : moment.events.map((event) => event.reason.label).toSet().join(', '),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingRewardProvider, (_, next) {
      if (next != null) _present();
    });
    return widget.child;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/game.dart';
import '../../providers/game_provider.dart';
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
      }
      if (mounted) ref.read(gameProvider.notifier).acknowledge(moment);
    }
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingRewardProvider, (_, next) {
      if (next != null) _present();
    });
    return widget.child;
  }
}

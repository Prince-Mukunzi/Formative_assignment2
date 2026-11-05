import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/directory_provider.dart';
import 'wheel_picker.dart';

class TeamWheel extends ConsumerWidget {
  final String? selectedId;
  final ValueChanged<String> onChanged;

  const TeamWheel({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(departmentsProvider);
    final hasTeam = teams.any((team) => team.id == selectedId);
    return WheelPicker<String?>(
      options: [
        if (!hasTeam) const WheelOption(value: null, label: 'No team'),
        for (final team in teams)
          WheelOption(value: team.id, label: team.label, icon: team.icon),
      ],
      selected: hasTeam ? selectedId : null,
      onChanged: (id) {
        if (id != null) onChanged(id);
      },
    );
  }
}

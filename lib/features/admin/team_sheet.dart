import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/department.dart';
import '../../models/report_category.dart';
import '../../providers/directory_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/bare_field.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/shake.dart';
import '../../core/utils/app_haptics.dart';

class TeamSheet extends ConsumerStatefulWidget {
  final Department? team;

  const TeamSheet({super.key, this.team});

  static void show(BuildContext context, [Department? team]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => TeamSheet(team: team),
    );
  }

  @override
  ConsumerState<TeamSheet> createState() => _TeamSheetState();
}

class _TeamSheetState extends ConsumerState<TeamSheet> {
  late final _name = TextEditingController(text: widget.team?.label);
  late final Set<ReportCategory> _categories = {...?widget.team?.categories};
  int _shake = 0;

  void _save() {
    final label = _name.text.trim();
    if (label.isEmpty) {
      AppHaptics.heavyImpact();
      setState(() => _shake++);
      return;
    }
    ref
        .read(departmentsProvider.notifier)
        .save(
          Department(
            id: widget.team?.id ?? const Uuid().v4(),
            label: label,
            categories: _categories,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shake(
            trigger: _shake,
            child: BareField(
              controller: _name,
              hint: 'Team name',
              style: AppTextStyles.heading1,
              autofocus: team == null,
            ),
          ),
          AppSpacing.verticalGapXl,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final category in ReportCategory.values)
                if (category != ReportCategory.all)
                  SizedBox(
                    height: 40,
                    child: CategoryChip(
                      icon: category.icon,
                      label: category.label,
                      isSelected: _categories.contains(category),
                      onTap: () => setState(() {
                        _categories.contains(category)
                            ? _categories.remove(category)
                            : _categories.add(category);
                      }),
                    ),
                  ),
            ],
          ),
          AppSpacing.verticalGapXl,
          SizedBox(
            width: double.infinity,
            child: AppButton(label: 'Save', onTap: _save),
          ),
          if (team != null)
            Center(
              child: Pressable(
                onTap: () {
                  ref.read(departmentsProvider.notifier).remove(team.id);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Text(
                    'Remove team',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.brand,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

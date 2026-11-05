import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/department.dart';
import '../../models/person.dart';
import '../../providers/directory_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/motion/pressable.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  PersonRole _role = PersonRole.student;

  String _meta(Person person) {
    if (person.role == PersonRole.faculty) {
      final id = person.departmentId;
      final team = id == null ? null : ref.watch(departmentsProvider).byId(id);
      return team?.label ?? 'No team';
    }
    final filed = ref
        .watch(reportsProvider)
        .where((r) => r.reportedBy == person.id)
        .length;
    return filed == 1 ? '1 report' : '$filed reports';
  }

  @override
  Widget build(BuildContext context) {
    final people = ref
        .watch(peopleProvider)
        .where((p) => p.role == _role)
        .toList();
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalGapLg,
            Text('People', style: AppTextStyles.heading1),
            AppSpacing.verticalGapXl,
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  CategoryChip(
                    label: 'Students',
                    isSelected: _role == PersonRole.student,
                    onTap: () => setState(() => _role = PersonRole.student),
                  ),
                  AppSpacing.horizontalGapXs,
                  CategoryChip(
                    label: 'Faculty',
                    isSelected: _role == PersonRole.faculty,
                    onTap: () => setState(() => _role = PersonRole.faculty),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapMd,
            for (final person in people)
              Pressable(
                onTap: () => _PersonSheet.show(context, person.id),
                scale: 0.98,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(person.name, style: AppTextStyles.labelMedium),
                            AppSpacing.verticalGapXs,
                            Text(_meta(person), style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      if (person.suspended)
                        Text(
                          'Suspended',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.brand,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.navClearance),
          ],
        ),
      ),
    );
  }
}

class _PersonSheet extends ConsumerWidget {
  final String personId;

  const _PersonSheet({required this.personId});

  static void show(BuildContext context, String personId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => _PersonSheet(personId: personId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref
        .watch(peopleProvider)
        .firstWhere((p) => p.id == personId);
    final people = ref.read(peopleProvider.notifier);
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(person.name, style: AppTextStyles.heading1),
            AppSpacing.verticalGapXl,
            if (person.role == PersonRole.faculty) ...[
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final team in ref.watch(departmentsProvider))
                    SizedBox(
                      height: 40,
                      child: CategoryChip(
                        label: team.label,
                        isSelected: team.id == person.departmentId,
                        onTap: () =>
                            people.moveToDepartment(person.id, team.id),
                      ),
                    ),
                ],
              ),
              AppSpacing.verticalGapXl,
            ],
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: person.suspended ? 'Restore' : 'Suspend',
                isFilled: person.suspended,
                onTap: () => people.setSuspended(
                  person.id,
                  suspended: !person.suspended,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

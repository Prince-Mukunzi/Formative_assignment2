import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/department.dart';
import '../../models/person.dart';
import '../../providers/directory_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/filled_field.dart';
import '../../widgets/team_wheel.dart';

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
            Row(
              children: [
                Expanded(child: Text('People', style: AppTextStyles.heading1)),
                AppButton(
                  label: 'Invite',
                  icon: HugeIcons.strokeRoundedUserAdd01,
                  isFilled: false,
                  onTap: () => _InviteSheet.show(context),
                ),
              ],
            ),
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
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  onTap: () => _PersonSheet.show(context, person.id),
                  child: Row(
                    children: [
                      _Initial(name: person.name),
                      AppSpacing.horizontalGapMd,
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

class _Initial extends StatelessWidget {
  final String name;

  const _Initial({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.navy,
      ),
      child: Text(
        name.characters.first,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textOnPrimary,
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
              TeamWheel(
                selectedId: person.departmentId,
                onChanged: (id) => people.moveToDepartment(person.id, id),
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

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet();

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const _InviteSheet(),
    );
  }

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _email = TextEditingController();
  PersonRole _role = PersonRole.faculty;
  String? _teamId;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim().toLowerCase();
    final teamId = _teamId ?? ref.read(departmentsProvider).firstOrNull?.id;
    if (!email.contains('@')) return setState(() => _error = 'Enter an email.');
    if (_role == PersonRole.faculty && teamId == null) {
      return setState(() => _error = 'Create a team first.');
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(peopleProvider.notifier)
          .invite(
            email: email,
            role: _role,
            departmentId: _role == PersonRole.faculty ? teamId : null,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Invited. Ask them to sign in with $email.')),
      );
    } on Object {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = 'The invite did not save. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Invite', style: AppTextStyles.heading2),
          AppSpacing.verticalGapXl,
          FilledField(
            controller: _email,
            hint: 'Their email',
            icon: HugeIcons.strokeRoundedMail01,
            keyboardType: TextInputType.emailAddress,
          ),
          AppSpacing.verticalGapMd,
          Row(
            children: [
              for (final role in const [PersonRole.faculty, PersonRole.admin])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: CategoryChip(
                    label: role.label,
                    isSelected: _role == role,
                    onTap: () => setState(() => _role = role),
                  ),
                ),
            ],
          ),
          if (_role == PersonRole.faculty) ...[
            AppSpacing.verticalGapMd,
            TeamWheel(
              selectedId: _teamId,
              onChanged: (id) => setState(() => _teamId = id),
            ),
          ],
          if (error != null) ...[
            AppSpacing.verticalGapMd,
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.brand),
            ),
          ],
          AppSpacing.verticalGapXl,
          AppButton(
            label: _sending ? 'Sending' : 'Send invite',
            onTap: _sending ? null : _send,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/directory_provider.dart';
import '../../widgets/bare_field.dart';
import '../../widgets/motion/pressable.dart';

class LocationsSheet extends ConsumerStatefulWidget {
  const LocationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const LocationsSheet(),
    );
  }

  @override
  ConsumerState<LocationsSheet> createState() => _LocationsSheetState();
}

class _LocationsSheetState extends ConsumerState<LocationsSheet> {
  final _name = TextEditingController();

  void _add() {
    ref.read(locationsProvider.notifier).add(_name.text.trim());
    _name.clear();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(locationsProvider);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: Padding(
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
            Text('Locations', style: AppTextStyles.heading1),
            AppSpacing.verticalGapXl,
            Row(
              children: [
                Expanded(
                  child: BareField(
                    controller: _name,
                    hint: 'Add a location',
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
                Pressable(
                  onTap: _add,
                  child: const Icon(
                    HugeIcons.strokeRoundedAdd01,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapMd,
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final location in locations)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              location,
                              style: AppTextStyles.labelMedium,
                            ),
                          ),
                          Pressable(
                            onTap: () => ref
                                .read(locationsProvider.notifier)
                                .remove(location),
                            child: const Icon(
                              HugeIcons.strokeRoundedCancel01,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game.dart';
import '../../models/report_category.dart';
import '../../providers/directory_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/bare_field.dart';
import '../../widgets/motion/kick_controller.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/rolling_number.dart';
import '../../widgets/motion/shake.dart';
import '../../core/utils/app_haptics.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen>
    with SingleTickerProviderStateMixin {
  static const _lastStep = 3;
  static const _pageDuration = Duration(milliseconds: 420);

  final _pages = PageController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _titleFocus = FocusNode();
  final _locationFocus = FocusNode();
  late final _xpKick = KickController(vsync: this, rest: 1);

  int _step = 0;
  ReportCategory? _category;
  String? _presetLocation;
  bool _isOtherLocation = false;
  String _imagePath = '';
  int _shake = 0;
  late int _shownBounty = _bounty;

  String get _location => _isOtherLocation
      ? _locationController.text.trim()
      : _presetLocation ?? '';

  bool get _hasImage => _imagePath.isNotEmpty;

  int get _bounty {
    final detailed =
        _descriptionController.text.trim().length >=
        ReportsNotifier.minDetailLength;
    return XpReason.reportFiled.xp +
        (_hasImage ? XpReason.photoAdded.xp : 0) +
        (detailed ? XpReason.detailAdded.xp : 0);
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_refreshBounty);
  }

  void _refreshBounty() {
    final bounty = _bounty;
    if (bounty == _shownBounty) return;
    if (bounty > _shownBounty) {
      AppHaptics.mediumImpact();
      _xpKick.kick(6);
    }
    setState(() => _shownBounty = bounty);
  }

  Future<void> _goTo(int step) async {
    setState(() => _step = step);
    if (step == 0 || step == _lastStep) FocusScope.of(context).unfocus();
    await _pages.animateToPage(
      step,
      duration: _pageDuration,
      curve: Curves.easeOutQuart,
    );
    if (!mounted || _step != step) return;
    if (step == 1) _titleFocus.requestFocus();
    if (step == 2 && _isOtherLocation) _locationFocus.requestFocus();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      _goTo(_step - 1);
    }
  }

  void _pickCategory(ReportCategory category) {
    AppHaptics.selectionClick();
    setState(() => _category = category);
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted && _step == 0) _goTo(1);
    });
  }

  void _pickLocation(String location) {
    AppHaptics.selectionClick();
    setState(() {
      _presetLocation = location;
      _isOtherLocation = false;
    });
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted && _step == 2) _goTo(3);
    });
  }

  void _pickOtherLocation() {
    AppHaptics.selectionClick();
    setState(() => _isOtherLocation = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _locationFocus.requestFocus();
    });
  }

  void _next() {
    final missing = switch (_step) {
      1 => _titleController.text.trim().isEmpty,
      2 => _location.isEmpty,
      _ => false,
    };
    if (missing) {
      AppHaptics.heavyImpact();
      setState(() => _shake++);
      return;
    }
    if (_step == _lastStep) {
      _submit();
    } else {
      _goTo(_step + 1);
    }
  }

  void _submit() {
    final category = _category;
    if (category == null) return;
    Navigator.of(context).pop();
    ref
        .read(reportsProvider.notifier)
        .create(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _location,
          category: category,
          imageUrl: _imagePath,
        );
  }

  Future<void> _pickImage() async {
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext, ImageSource.camera),
            child: const Text('Take a photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext, ImageSource.gallery),
            child: const Text('Choose from gallery'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );
    if (source == null) return;
    final XFile? file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null || !mounted) return;
    _imagePath = file.path;
    _refreshBounty();
    setState(() {});
  }

  @override
  void dispose() {
    _pages.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _titleFocus.dispose();
    _locationFocus.dispose();
    _xpKick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step(
                    question: 'What kind of issue?',
                    child: _CategoryGrid(
                      selected: _category,
                      onPicked: _pickCategory,
                    ),
                  ),
                  _Step(question: 'What is wrong?', child: _buildDetails()),
                  _Step(
                    question: 'Where is it?',
                    child: _LocationList(
                      locations: ref.watch(locationsProvider),
                      selected: _presetLocation,
                      isOther: _isOtherLocation,
                      onPicked: _pickLocation,
                      onOther: _pickOtherLocation,
                      otherField: Shake(
                        trigger: _step == 2 ? _shake : 0,
                        child: BareField(
                          controller: _locationController,
                          focusNode: _locationFocus,
                          hint: 'Type the place',
                          style: AppTextStyles.heading2,
                        ),
                      ),
                    ),
                  ),
                  _Step(
                    question: 'Add a photo',
                    child: _PhotoTile(path: _imagePath, onTap: _pickImage),
                  ),
                ],
              ),
            ),
            if (_step > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: _step == _lastStep ? 'Submit' : 'Next',
                    onTap: _next,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Row(
        children: [
          Pressable(
            onTap: _back,
            child: const Icon(
              HugeIcons.strokeRoundedArrowLeft01,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.horizontalGapLg,
          Expanded(
            child: _StepBar(step: _step, count: _lastStep + 1),
          ),
          AppSpacing.horizontalGapLg,
          AnimatedBuilder(
            animation: _xpKick,
            builder: (_, child) =>
                Transform.scale(scale: _xpKick.value, child: child),
            child: RollingNumber(
              value: _shownBounty,
              prefix: '+',
              suffix: ' XP',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shake(
          trigger: _step == 1 ? _shake : 0,
          child: BareField(
            controller: _titleController,
            focusNode: _titleFocus,
            hint: 'Broken sink',
            style: AppTextStyles.heading2,
          ),
        ),
        AppSpacing.verticalGapLg,
        BareField(
          controller: _descriptionController,
          hint: 'More detail  +${XpReason.detailAdded.xp} XP',
          style: AppTextStyles.bodyLarge,
          maxLines: 5,
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String question;
  final Widget child;

  const _Step({required this.question, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.xxl),
          child,
        ],
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int step;
  final int count;

  const _StepBar({required this.step, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) AppSpacing.horizontalGapXs,
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              decoration: BoxDecoration(
                color: i <= step ? AppColors.brand : AppColors.cardBorder,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final ReportCategory? selected;
  final ValueChanged<ReportCategory> onPicked;

  const _CategoryGrid({required this.selected, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    final categories = ReportCategory.values
        .where((c) => c != ReportCategory.all)
        .toList();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        for (final category in categories)
          _CategoryTile(
            category: category,
            selected: category == selected,
            onTap: () => onPicked(category),
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ReportCategory category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.textOnPrimary
        : AppColors.textPrimary;
    return Pressable(
      onTap: onTap,
      haptic: false,
      scale: 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(category.icon, size: 26, color: foreground),
            Text(
              category.label,
              style: AppTextStyles.labelLarge.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationList extends StatelessWidget {
  final List<String> locations;
  final String? selected;
  final bool isOther;
  final ValueChanged<String> onPicked;
  final VoidCallback onOther;
  final Widget otherField;

  const _LocationList({
    required this.locations,
    required this.selected,
    required this.isOther,
    required this.onPicked,
    required this.onOther,
    required this.otherField,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final location in locations)
              _LocationPill(
                label: location,
                selected: !isOther && location == selected,
                onTap: () => onPicked(location),
              ),
            _LocationPill(label: 'Other', selected: isOther, onTap: onOther),
          ],
        ),
        if (isOther)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: otherField,
          ),
        AppSpacing.verticalGapLg,
      ],
    );
  }
}

class _LocationPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LocationPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String path;
  final VoidCallback onTap;

  const _PhotoTile({required this.path, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: path.isNotEmpty
              ? Image.file(File(path), fit: BoxFit.cover)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      HugeIcons.strokeRoundedCamera01,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                    AppSpacing.verticalGapSm,
                    Text(
                      '+${XpReason.photoAdded.xp} XP',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

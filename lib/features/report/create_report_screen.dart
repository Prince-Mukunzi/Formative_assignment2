import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/game.dart';
import '../../models/report_category.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/motion/pressable.dart';
import '../../widgets/motion/rolling_number.dart';
import '../../widgets/motion/shake.dart';
import '../../widgets/motion/spring_value.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() =>
      _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  ReportCategory _selectedCategory = ReportCategory.electricity;
  String _imagePath = '';
  int _titleShake = 0;
  int _locationShake = 0;

  bool get _hasImage => _imagePath.isNotEmpty;

  int get _bounty {
    final detailed = _descriptionController.text.trim().length >=
        ReportsNotifier.minDetailLength;
    return XpReason.reportFiled.xp +
        (_hasImage ? XpReason.photoAdded.xp : 0) +
        (detailed ? XpReason.detailAdded.xp : 0);
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() => setState(() {}));
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
    if (file != null && mounted) setState(() => _imagePath = file.path);
  }

  void _submit() {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    if (title.isEmpty || location.isEmpty) {
      HapticFeedback.heavyImpact();
      setState(() {
        if (title.isEmpty) _titleShake++;
        if (location.isEmpty) _locationShake++;
      });
      return;
    }
    Navigator.of(context).pop();
    ref.read(reportsProvider.notifier).create(
          title: title,
          description: _descriptionController.text.trim(),
          location: location,
          category: _selectedCategory,
          imageUrl: _imagePath,
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text('Report an Issue', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalGapLg,
            _buildImagePicker(),
            AppSpacing.verticalGapXl,
            Shake(
              trigger: _titleShake,
              child: _buildField(
                'Title',
                'What is the issue?',
                _titleController,
              ),
            ),
            AppSpacing.verticalGapLg,
            _buildCategorySelector(),
            AppSpacing.verticalGapLg,
            Shake(
              trigger: _locationShake,
              child: _buildField(
                'Location',
                'e.g. Building A, Floor 2',
                _locationController,
              ),
            ),
            AppSpacing.verticalGapLg,
            _buildDescriptionField(),
            AppSpacing.verticalGapXl,
            _buildBountyMeter(),
            AppSpacing.verticalGapLg,
            _buildSubmitButton(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Pressable(
      onTap: _pickImage,
      scale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: _hasImage ? AppColors.accent : AppColors.cardBorder,
            width: _hasImage ? 1.5 : 1,
          ),
        ),
        child: _hasImage
            ? Image.file(File(_imagePath), fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: const Icon(
                      HugeIcons.strokeRoundedCamera01,
                      size: 28,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.verticalGapMd,
                  Text(
                    'Add a photo  +${XpReason.photoAdded.xp} XP',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.verticalGapXs,
                  Text(
                    'Take a photo or choose from gallery',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _buildBountyMeter() {
    final maximum = XpReason.reportFiled.xp +
        XpReason.photoAdded.xp +
        XpReason.detailAdded.xp;
    return Container(
      padding: AppSpacing.cardPaddingSmall,
      decoration: BoxDecoration(
        color: AppColors.rewardLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Filing bounty',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.rewardDeep,
                ),
              ),
              const Spacer(),
              RollingNumber(
                value: _bounty,
                prefix: '+',
                suffix: ' XP',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.rewardDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: SpringValue(
              value: _bounty / maximum,
              spring: AppSprings.bouncy,
              builder: (_, value, _) => LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.surface,
                color: AppColors.reward,
              ),
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Earns +${XpReason.reportApproved.xp} more when approved and '
            '+${XpReason.reportResolved.xp} when fixed.',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.rewardDeep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        AppSpacing.verticalGapSm,
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          style: AppTextStyles.bodyLarge,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildCategorySelector() {
    final categories = ReportCategory.values
        .where((c) => c != ReportCategory.all)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.labelMedium),
        AppSpacing.verticalGapSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Pressable(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 16,
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                    ),
                    AppSpacing.horizontalGapSm,
                    Text(
                      category.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 150.ms);
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: AppTextStyles.labelMedium),
        AppSpacing.verticalGapSm,
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Describe the issue in detail...',
            alignLabelWithHint: true,
          ),
          style: AppTextStyles.bodyLarge,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: 'Submit Report',
        onTap: _submit,
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
}

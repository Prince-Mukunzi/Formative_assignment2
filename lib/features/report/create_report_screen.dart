import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/report_category.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  ReportCategory _selectedCategory = ReportCategory.electricity;
  bool _hasImage = false;

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
            _buildField('Title', 'What is the issue?', _titleController),
            AppSpacing.verticalGapLg,
            _buildCategorySelector(),
            AppSpacing.verticalGapLg,
            _buildField(
              'Location',
              'e.g. Building A, Floor 2',
              _locationController,
            ),
            AppSpacing.verticalGapLg,
            _buildDescriptionField(),
            AppSpacing.verticalGapXxl,
            _buildSubmitButton(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => setState(() => _hasImage = !_hasImage),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _hasImage ? AppColors.accentLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: _hasImage ? AppColors.accent : AppColors.cardBorder,
            width: _hasImage ? 1.5 : 1,
          ),
        ),
        child: _hasImage
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    HugeIcons.strokeRoundedImage02,
                    size: 48,
                    color: AppColors.accent,
                  ),
                  AppSpacing.verticalGapMd,
                  Text(
                    'Image selected',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  AppSpacing.verticalGapXs,
                  Text(
                    'Tap to change',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    'Add a photo',
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
            return GestureDetector(
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
        onTap: () => Navigator.of(context).pop(),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
}

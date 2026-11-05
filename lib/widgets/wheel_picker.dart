import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/app_haptics.dart';

class WheelOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const WheelOption({required this.value, required this.label, this.icon});
}

class WheelPicker<T> extends StatefulWidget {
  final List<WheelOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const WheelPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<WheelPicker<T>> createState() => _WheelPickerState<T>();
}

class _WheelPickerState<T> extends State<WheelPicker<T>> {
  static const _rowHeight = 44.0;
  static const _visibleRows = 5;

  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: _selectedIndex);

  int get _selectedIndex {
    final index = widget.options.indexWhere(
      (option) => option.value == widget.selected,
    );
    return index < 0 ? 0 : index;
  }

  @override
  void didUpdateWidget(covariant WheelPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jumping notifies the rows, which cannot rebuild while this build runs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      if (_controller.position.isScrollingNotifier.value) return;
      if (_controller.selectedItem != _selectedIndex) {
        _controller.jumpToItem(_selectedIndex);
      }
    });
  }

  bool _commit(ScrollEndNotification _) {
    final value = widget.options[_controller.selectedItem].value;
    if (value != widget.selected) widget.onChanged(value);
    return false;
  }

  void _scrollTo(int index) {
    _controller.animateToItem(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _rowHeight * _visibleRows,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: _rowHeight,
            decoration: BoxDecoration(
              gradient: AppColors.navy,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          NotificationListener<ScrollEndNotification>(
            onNotification: _commit,
            child: ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: _rowHeight,
              diameterRatio: 1.6,
              perspective: 0.004,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (_) => AppHaptics.selectionClick(),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.options.length,
                builder: (_, index) => _WheelRow(
                  controller: _controller,
                  index: index,
                  initialIndex: _selectedIndex,
                  rowHeight: _rowHeight,
                  option: widget.options[index],
                  onTap: () => _scrollTo(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelRow extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int index;
  final int initialIndex;
  final double rowHeight;
  final WheelOption<Object?> option;
  final VoidCallback onTap;

  const _WheelRow({
    required this.controller,
    required this.index,
    required this.initialIndex,
    required this.rowHeight,
    required this.option,
    required this.onTap,
  });

  double get _position {
    if (controller.hasClients && controller.position.hasPixels) {
      return controller.offset / rowHeight;
    }
    return initialIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final icon = option.icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, _) {
          final distance = (_position - index).abs();
          final color = Color.lerp(
            AppColors.textPrimary,
            AppColors.textOnPrimary,
            (1 - distance).clamp(0.0, 1.0),
          )!;
          return Opacity(
            opacity: (1.25 - distance * 0.35).clamp(0.15, 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: color),
                  AppSpacing.horizontalGapSm,
                ],
                Flexible(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(color: color),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/utils/validators.dart';

/// Price field with ₦ prefix and numeric keyboard.
class PriceField extends StatelessWidget {
  final TextEditingController controller;
  final bool negotiable;
  final ValueChanged<bool> onNegotiableChanged;

  const PriceField({
    super.key,
    required this.controller,
    required this.negotiable,
    required this.onNegotiableChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: AppTextStyles.inputText(color: context.textPrimaryColor),
          decoration: const InputDecoration(
            labelText: AppStrings.priceField,
            prefixText: '₦ ',
          ),
          validator: Validators.price,
        ),
        const SizedBox(height: 10),
        // Negotiable toggle
        GestureDetector(
          onTap: () => onNegotiableChanged(!negotiable),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: negotiable ? context.primaryColor : Colors.transparent,
                  border: Border.all(
                    color: negotiable
                        ? context.primaryColor
                        : context.dividerColor,
                    width: 1.5,
                  ),
                ),
                child: negotiable
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.negotiableToggle,
                style: AppTextStyles.bodyMedium(color: context.textPrimaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Category selector — opens a bottom sheet with all categories.
class CategorySelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final hasValue = selected != null;

    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: AppDecorations.defaultRadius,
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected ?? AppStrings.selectCategory,
                style: hasValue
                    ? AppTextStyles.bodyLarge(color: context.textPrimaryColor)
                    : AppTextStyles.bodyLarge(
                        color: context.textSecondaryColor.withOpacity(0.6)),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: context.textSecondaryColor, size: 22),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SelectionSheet(
        title: AppStrings.selectCategory,
        options: AppStrings.categoriesWithoutAll,
        selected: selected,
        onSelected: (value) {
          Navigator.pop(context);
          onSelected(value);
        },
      ),
    );
  }
}

/// Condition selector — opens a bottom sheet with all conditions.
class ConditionSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const ConditionSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final hasValue = selected != null;

    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: AppDecorations.defaultRadius,
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected ?? AppStrings.selectCondition,
                style: hasValue
                    ? AppTextStyles.bodyLarge(color: context.textPrimaryColor)
                    : AppTextStyles.bodyLarge(
                        color: context.textSecondaryColor.withOpacity(0.6)),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: context.textSecondaryColor, size: 22),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectionSheet(
        title: AppStrings.selectCondition,
        options: AppStrings.conditions,
        selected: selected,
        onSelected: (value) {
          Navigator.pop(context);
          onSelected(value);
        },
      ),
    );
  }
}

/// Shared bottom sheet for single selection (category or condition).
class _SelectionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _SelectionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final dividerColor = context.dividerColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
          0, 0, 0, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(title,
                style: AppTextStyles.headlineSmall(
                    color: context.textPrimaryColor)),
          ),
          Divider(color: dividerColor, height: 1),
          ...options.map((option) => _OptionTile(
                option: option,
                isSelected: selected == option,
                onTap: () => onSelected(option),
              )),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.primaryColor;
    final textPrimary = context.textPrimaryColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(option,
                  style: AppTextStyles.bodyLarge(color: textPrimary)),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Location display chip — shows auto-detected city/area.
class LocationDisplay extends StatelessWidget {
  final String? city;
  final String? area;
  final bool isLoading;
  final VoidCallback? onRetry;

  const LocationDisplay({
    super.key,
    this.city,
    this.area,
    this.isLoading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final hasLocation = city != null && city!.isNotEmpty;
    final warningColor = context.warningColor;

    final bgColor = hasLocation || isLoading
        ? (isDark ? AppColors.darkSurface : AppColors.surface)
        : (isDark
            ? AppColors.warningDark.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.06));
    final borderColor = hasLocation || isLoading
        ? context.dividerColor
        : warningColor.withOpacity(0.35);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppDecorations.defaultRadius,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            isLoading
                ? Icons.location_searching_rounded
                : hasLocation
                    ? Icons.location_on_outlined
                    : Icons.location_off_outlined,
            size: 18,
            color: isLoading || hasLocation
                ? context.primaryColor
                : warningColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: isLoading
                ? Text('Detecting location...',
                    style: AppTextStyles.bodyMedium(
                        color: context.textSecondaryColor))
                : hasLocation
                    ? Text(
                        area != null && area!.isNotEmpty
                            ? '$area, $city'
                            : city!,
                        style: AppTextStyles.bodyMedium(
                            color: context.textPrimaryColor),
                      )
                    : Text(
                        'Location not detected — item won\'t appear in nearby results',
                        style: AppTextStyles.bodySmall(color: warningColor),
                      ),
          ),
          if (!isLoading && !hasLocation && onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: AppTextStyles.labelSmall(color: context.primaryColor),
              ),
            )
          else if (hasLocation)
            Text(
              AppStrings.locationAuto,
              style: AppTextStyles.labelSmall(
                  color: context.textSecondaryColor),
            ),
        ],
      ),
    );
  }
}

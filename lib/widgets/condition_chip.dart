import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_decorations.dart';

/// Filled accent pill chip for item condition and category.
/// Used on item cards and item detail page.
///
/// Usage:
/// ```dart
/// ConditionChip(label: 'Fairly Used')
/// ConditionChip(label: 'Phones & Tablets', isCategory: true)
/// ```
class ConditionChip extends StatelessWidget {
  final String label;

  const ConditionChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: AppDecorations.filledChip.copyWith(color: bgColor),
      child: Text(
        label,
        style: AppTextStyles.labelMedium(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Popular badge — shown on listings with 10+ saves.
/// Small filled navy pill with a flame icon.
///
/// Usage:
/// ```dart
/// if (item.isPopular) const PopularBadge()
/// ```
class PopularBadge extends StatelessWidget {
  const PopularBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppDecorations.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded,
              size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Popular',
            style: AppTextStyles.labelSmall(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Filter chip used on the home feed for category filtering.
/// Outlined when inactive, filled when active.
///
/// Usage:
/// ```dart
/// FilterChipWidget(
///   label: 'Books',
///   isActive: selectedCategory == 'Books',
///   onTap: () => setCategory('Books'),
/// )
/// ```
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final borderColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: AppDecorations.pillRadius,
          border: Border.all(
            color: isActive ? activeColor : borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            color: isActive
                ? Colors.white
                : isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Sold overlay badge — shown on sold items in feed and my space.
class SoldBadge extends StatelessWidget {
  const SoldBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: AppDecorations.pillRadius,
      ),
      child: Text(
        'Sold',
        style: AppTextStyles.labelMedium(color: Colors.white),
      ),
    );
  }
}

/// Expiry warning chip — shown in My Space when listing expires within 3 days.
class ExpiryWarningChip extends StatelessWidget {
  final String label; // e.g. "Expires in 2 days"

  const ExpiryWarningChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: AppDecorations.pillRadius,
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 11, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.warning),
          ),
        ],
      ),
    );
  }
}

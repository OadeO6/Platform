import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Shows a Platform-styled bottom sheet.
/// Handles the drag handle, optional title, and consistent padding.
///
/// Usage:
/// ```dart
/// PlatformBottomSheet.show(
///   context: context,
///   title: 'Manage Item',
///   child: Column(children: [...]),
/// );
/// ```
class PlatformBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;

  const PlatformBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.padding,
  });

  /// Shows a modal bottom sheet with Platform styling.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlatformBottomSheet(
        title: title,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final handleColor = isDark
        ? AppColors.darkDivider
        : AppColors.divider;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          if (showHandle)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

          // Title
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                title!,
                style: AppTextStyles.headlineSmall(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),

          // Content
          Padding(
            padding: padding ??
                EdgeInsets.fromLTRB(
                  20,
                  title != null ? 16 : 8,
                  20,
                  20,
                ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// A single action row item for use inside PlatformBottomSheet.
/// Icon + label, optional destructive styling.
///
/// Usage:
/// ```dart
/// BottomSheetAction(
///   icon: Icons.edit_outlined,
///   label: 'Edit Item',
///   onTap: () {},
/// )
/// BottomSheetAction.destructive(
///   icon: Icons.delete_outline_rounded,
///   label: 'Delete',
///   onTap: () {},
/// )
/// ```
class BottomSheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const BottomSheetAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  const BottomSheetAction.destructive({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  })  : isDestructive = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive
        ? (isDark ? AppColors.destructiveDark : AppColors.destructive)
        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.bodyLarge(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

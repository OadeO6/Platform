import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Empty state widget used across all screens in Platform.
///
/// Design: large Caveat heading + single icon, minimal.
/// No images — just typography and icon.
///
/// Usage:
/// ```dart
/// EmptyState(
///   icon: Icons.bookmark_outline_rounded,
///   title: 'Nothing saved yet.',
///   subtitle: 'Tap the bookmark on any listing.',
/// )
/// EmptyState(
///   icon: Icons.storefront_outlined,
///   title: 'Your space is empty.',
///   action: PlatformButton(label: 'Create Item', onPressed: () {}),
/// )
/// ```
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final iconColor = isDark
        ? AppColors.darkTextSecondary.withOpacity(0.4)
        : AppColors.textSecondary.withOpacity(0.3);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: iconColor,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.displaySmall(color: textColor),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium(color: secondaryColor),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 28),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

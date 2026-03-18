import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// The standard app bar for Platform screens.
///
/// Features:
/// - Caveat display font title with " —" dash accent at 60% opacity
/// - No elevation, transparent background matches scaffold
/// - Optional actions (icons only, no labels)
/// - Optional leading widget (defaults to back button if navigator can pop)
///
/// Usage:
/// ```dart
/// PlatformAppBar(title: 'My Space')
/// PlatformAppBar(title: 'Notifications', actions: [IconButton(...)])
/// PlatformAppBar.wordmark()  // Shows "Platform" wordmark for home screen
/// ```
class PlatformAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showWordmark;
  final bool showDash;
  final bool centerTitle;
  final VoidCallback? onLeadingTap;

  const PlatformAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.showWordmark = false,
    this.showDash = true,
    this.centerTitle = false,
    this.onLeadingTap,
  });

  /// Home screen variant — shows "Platform" wordmark instead of a screen title
  const PlatformAppBar.wordmark({
    super.key,
    this.actions,
  })  : title = null,
        leading = null,
        showWordmark = true,
        showDash = false,
        centerTitle = false,
        onLeadingTap = null;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: leading ??
          (canPop
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: textColor,
                    size: 20,
                  ),
                  onPressed: onLeadingTap ?? () => Navigator.of(context).pop(),
                )
              : null),
      title: showWordmark
          ? _WordmarkTitle(color: textColor)
          : title != null
              ? _ScreenTitle(
                  title: title!,
                  color: textColor,
                  showDash: showDash,
                )
              : null,
      actions: actions,
    );
  }
}

/// "Platform" wordmark used on the home feed app bar
class _WordmarkTitle extends StatelessWidget {
  final Color color;
  const _WordmarkTitle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Platform',
      style: AppTextStyles.wordmark(color: color),
    );
  }
}

/// Screen title with optional " —" dash accent
class _ScreenTitle extends StatelessWidget {
  final String title;
  final Color color;
  final bool showDash;

  const _ScreenTitle({
    required this.title,
    required this.color,
    required this.showDash,
  });

  @override
  Widget build(BuildContext context) {
    if (!showDash) {
      return Text(
        title,
        style: AppTextStyles.displayMedium(color: color),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: AppTextStyles.displayMedium(color: color),
        ),
        Text(
          ' —',
          style: AppTextStyles.displayMedium(
            color: color.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

/// A slim divider shown at the bottom of the app bar area
/// when the screen has scrollable content below it.
class PlatformAppBarDivider extends StatelessWidget {
  const PlatformAppBarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      color: isDark ? AppColors.darkDivider : AppColors.divider,
    );
  }
}

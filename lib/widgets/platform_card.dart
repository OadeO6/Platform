import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';

/// The standard card container for Platform.
/// Uses the offset sticker shadow (3dp right, 3dp down, no blur) defined in the design system.
///
/// Usage:
/// ```dart
/// PlatformCard(child: Text('Content'))
/// PlatformCard(padding: EdgeInsets.all(12), child: ...)
/// ```
class PlatformCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const PlatformCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.width,
    this.height,
  }) : borderRadius = null;

  const PlatformCard.custom({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = isDark ? AppDecorations.cardDark : AppDecorations.card;
    final resolvedBorderRadius = borderRadius ?? AppDecorations.defaultRadius;

    Widget content = Container(
      width: width,
      height: height,
      decoration: decoration.copyWith(
        borderRadius: resolvedBorderRadius,
      ),
      child: ClipRRect(
        borderRadius: resolvedBorderRadius,
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// A card specifically sized and structured for feed item listings.
/// Shows cover image, title, price, location, and condition chip.
/// The actual content is passed as a child — layout is handled by the screen.
class PlatformItemCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PlatformItemCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isDark ? AppDecorations.cardDark : AppDecorations.card,
        child: ClipRRect(
          borderRadius: AppDecorations.defaultRadius,
          child: child,
        ),
      ),
    );
  }
}

/// A surface container for bottom sheets, modals, and panels.
/// No shadow — just the rounded top corners and surface colour.
class PlatformSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PlatformSurface({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );
  }
}

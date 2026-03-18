import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/theme/app_text_styles.dart';

/// Button variants available in Platform.
enum PlatformButtonVariant { primary, ghost, destructive, whatsapp, outlined }

/// The standard button component for Platform.
///
/// Usage:
/// ```dart
/// PlatformButton(label: 'List Item', onPressed: () {})
/// PlatformButton.ghost(label: 'Cancel', onPressed: () {})
/// PlatformButton.whatsapp(label: 'Contact on WhatsApp', onPressed: () {})
/// PlatformButton.destructive(label: 'Delete', onPressed: () {})
/// ```
class PlatformButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PlatformButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final double height;

  const PlatformButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PlatformButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.height = 52,
  });

  /// Ghost / secondary — transparent background, accent text + optional icon
  const PlatformButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.height = 52,
  }) : variant = PlatformButtonVariant.ghost;

  /// Destructive — red filled, used for delete/dangerous actions
  const PlatformButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.height = 52,
  }) : variant = PlatformButtonVariant.destructive;

  /// WhatsApp — green filled, used exclusively for WhatsApp CTA
  const PlatformButton.whatsapp({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.height = 52,
  }) : variant = PlatformButtonVariant.whatsapp;

  /// Outlined — transparent with border, secondary actions
  const PlatformButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.height = 52,
  }) : variant = PlatformButtonVariant.outlined;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: _buildButton(context, isDark),
    );
  }

  Widget _buildButton(BuildContext context, bool isDark) {
    switch (variant) {
      case PlatformButtonVariant.primary:
        return _FilledButton(
          label: label,
          icon: icon,
          loading: loading,
          onPressed: onPressed,
          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          foregroundColor: Colors.white,
        );

      case PlatformButtonVariant.ghost:
        return _GhostButton(
          label: label,
          icon: icon,
          loading: loading,
          onPressed: onPressed,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        );

      case PlatformButtonVariant.destructive:
        return _FilledButton(
          label: label,
          icon: icon,
          loading: loading,
          onPressed: onPressed,
          backgroundColor: isDark ? AppColors.destructiveDark : AppColors.destructive,
          foregroundColor: Colors.white,
        );

      case PlatformButtonVariant.whatsapp:
        return _FilledButton(
          label: label,
          icon: icon ?? Icons.chat_rounded,
          loading: loading,
          onPressed: onPressed,
          backgroundColor: AppColors.whatsapp,
          foregroundColor: Colors.white,
        );

      case PlatformButtonVariant.outlined:
        return _OutlinedButton(
          label: label,
          icon: icon,
          loading: loading,
          onPressed: onPressed,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        );
    }
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _FilledButton({
    required this.label,
    this.icon,
    required this.loading,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.defaultRadius,
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foregroundColor,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(label, style: AppTextStyles.labelLarge(color: foregroundColor)),
              ],
            ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onPressed;
  final Color color;

  const _GhostButton({
    required this.label,
    this.icon,
    required this.loading,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.defaultRadius,
        ),
      ),
      child: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(label, style: AppTextStyles.labelLarge(color: color)),
              ],
            ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onPressed;
  final Color color;

  const _OutlinedButton({
    required this.label,
    this.icon,
    required this.loading,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.defaultRadius,
        ),
      ),
      child: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(label, style: AppTextStyles.labelLarge(color: color)),
              ],
            ),
    );
  }
}

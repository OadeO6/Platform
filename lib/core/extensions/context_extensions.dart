import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Convenient BuildContext extensions for Platform.
/// Reduces boilerplate when accessing theme, colors, and screen dimensions.
extension ContextExtensions on BuildContext {
  // ── Theme ─────────────────────────────────────────────────────────────────

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ── Dark mode ─────────────────────────────────────────────────────────────

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Colors (theme-aware) ──────────────────────────────────────────────────

  Color get backgroundColor =>
      isDark ? AppColors.darkBackground : AppColors.background;

  Color get surfaceColor =>
      isDark ? AppColors.darkSurface : AppColors.surface;

  Color get primaryColor =>
      isDark ? AppColors.darkPrimary : AppColors.primary;

  Color get primaryTintColor =>
      isDark ? AppColors.darkPrimaryTint : AppColors.primaryTint;

  Color get textPrimaryColor =>
      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Color get textSecondaryColor =>
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

  Color get dividerColor =>
      isDark ? AppColors.darkDivider : AppColors.divider;

  Color get destructiveColor =>
      isDark ? AppColors.destructiveDark : AppColors.destructive;

  Color get successColor =>
      isDark ? AppColors.successDark : AppColors.success;

  Color get warningColor =>
      isDark ? AppColors.warningDark : AppColors.warning;

  // ── Screen dimensions ─────────────────────────────────────────────────────

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomInset => MediaQuery.of(this).viewInsets.bottom;

  // ── Text styles (theme-aware shortcuts) ───────────────────────────────────

  TextStyle displayLarge({Color? color}) =>
      AppTextStyles.displayLarge(color: color ?? textPrimaryColor);

  TextStyle displayMedium({Color? color}) =>
      AppTextStyles.displayMedium(color: color ?? textPrimaryColor);

  TextStyle displaySmall({Color? color}) =>
      AppTextStyles.displaySmall(color: color ?? textPrimaryColor);

  TextStyle bodyLarge({Color? color}) =>
      AppTextStyles.bodyLarge(color: color ?? textPrimaryColor);

  TextStyle bodyMedium({Color? color}) =>
      AppTextStyles.bodyMedium(color: color ?? textSecondaryColor);

  TextStyle bodySmall({Color? color}) =>
      AppTextStyles.bodySmall(color: color ?? textSecondaryColor);

  TextStyle labelLarge({Color? color}) =>
      AppTextStyles.labelLarge(color: color ?? textPrimaryColor);

  // ── Snackbar ──────────────────────────────────────────────────────────────

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? destructiveColor : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable BoxDecoration and InputDecoration definitions for Platform.
/// Never define inline decorations in widgets — reference this class.
class AppDecorations {
  AppDecorations._();

  // ── Border Radius ─────────────────────────────────────────────────────────

  static const BorderRadius defaultRadius = BorderRadius.all(Radius.circular(8));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(100));
  static const BorderRadius circleRadius = BorderRadius.all(Radius.circular(999));

  // ── Card — Light Mode ─────────────────────────────────────────────────────

  /// Standard item card with offset sticker shadow.
  /// Offset: 3dp right, 3dp down. No blur. 10% opacity dark shadow.
  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: defaultRadius,
    border: Border.all(color: AppColors.divider, width: 1),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadow,
        offset: Offset(3, 3),
        blurRadius: 0,
      ),
    ],
  );

  /// Card — Dark Mode variant
  static BoxDecoration cardDark = BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: defaultRadius,
    border: Border.all(color: AppColors.darkDivider, width: 1),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadowDark,
        offset: Offset(3, 3),
        blurRadius: 0,
      ),
    ],
  );

  // ── Bottom Sheet ──────────────────────────────────────────────────────────

  static BoxDecoration bottomSheet = const BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  );

  static BoxDecoration bottomSheetDark = const BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  );

  // ── Input Field ───────────────────────────────────────────────────────────

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? suffix,
    Widget? prefix,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
        prefixIcon: prefix,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.destructive, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.destructive, width: 2),
        ),
      );

  // ── Image Upload Area ─────────────────────────────────────────────────────

  static BoxDecoration imageUploadArea = BoxDecoration(
    color: AppColors.background,
    borderRadius: defaultRadius,
    border: Border.all(
      color: AppColors.divider,
      width: 1.5,
      strokeAlign: BorderSide.strokeAlignInside,
    ),
  );

  // ── Chip / Pill ───────────────────────────────────────────────────────────

  /// Filled accent chip — condition, category on cards and detail page
  static BoxDecoration filledChip = BoxDecoration(
    color: AppColors.primary,
    borderRadius: pillRadius,
  );

  /// Outlined filter chip — inactive state on home feed
  static BoxDecoration outlinedChip = BoxDecoration(
    color: Colors.transparent,
    borderRadius: pillRadius,
    border: Border.all(color: AppColors.divider, width: 1),
  );

  /// Active filter chip — selected state on home feed
  static BoxDecoration activeChip = BoxDecoration(
    color: AppColors.primary,
    borderRadius: pillRadius,
  );
}

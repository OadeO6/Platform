import 'package:flutter/material.dart';

/// All colour tokens for Platform.
/// Never use raw colour values in widgets — always reference this class.
class AppColors {
  AppColors._();

  // ── Light Mode ────────────────────────────────────────────────────────────

  /// Warm off-white app background (with grain texture overlay in UI)
  static const Color background = Color(0xFFFAF9F7);

  /// White surface for cards, bottom sheets, modals
  static const Color surface = Color(0xFFFFFFFF);

  /// Deep navy — primary accent, buttons, active states
  static const Color primary = Color(0xFF1B3A6B);

  /// Light navy tint — chip backgrounds, highlights
  static const Color primaryTint = Color(0xFFE8EEF7);

  /// Near-black for headings and body text
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Mid-grey for meta info, placeholders, inactive elements
  static const Color textSecondary = Color(0xFF6B6B6B);

  /// Warm grey for borders, dividers, separators
  static const Color divider = Color(0xFFE5E3DF);

  /// WhatsApp brand green — used exclusively for the WhatsApp CTA button
  static const Color whatsapp = Color(0xFF25D366);

  /// Red for destructive actions (delete, error states)
  static const Color destructive = Color(0xFFD94F4F);

  /// Green for sold badges, success confirmations
  static const Color success = Color(0xFF2E7D32);

  /// Amber for expiry warnings, location warnings
  static const Color warning = Color(0xFFB45309);

  // ── Dark Mode ─────────────────────────────────────────────────────────────

  static const Color darkBackground = Color(0xFF141414);
  static const Color darkSurface = Color(0xFF1F1F1F);

  /// Lightened primary for legibility on dark backgrounds
  static const Color darkPrimary = Color(0xFF4A7FD4);

  static const Color darkPrimaryTint = Color(0xFF1E2D45);
  static const Color darkTextPrimary = Color(0xFFF0EFED);
  static const Color darkTextSecondary = Color(0xFF9B9B9B);
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color destructiveDark = Color(0xFFEF5350);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warningDark = Color(0xFFFFA726);

  // ── Card shadow ───────────────────────────────────────────────────────────

  /// Offset sticker shadow — light mode
  static const Color cardShadow = Color(0x1A1A1A1A);

  /// Offset sticker shadow — dark mode
  static const Color cardShadowDark = Color(0x33000000);
}

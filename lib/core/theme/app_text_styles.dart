import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Full type scale for Platform.
///
/// Two fonts in use:
/// - Caveat       → display/headings (screen titles, price, onboarding, empty states)
/// - DM Sans      → everything else (body, buttons, labels, forms, meta)
///
/// Never use raw TextStyle in widgets — always reference this class.
class AppTextStyles {
  AppTextStyles._();

  // ── Caveat — Display ──────────────────────────────────────────────────────

  /// 36sp — Price on item detail, onboarding H1
  static TextStyle displayLarge({Color? color}) => GoogleFonts.caveat(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color ?? AppColors.textPrimary,
      );

  /// 28sp — Screen titles (My Space, Saved, Notifications…)
  static TextStyle displayMedium({Color? color}) => GoogleFonts.caveat(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color ?? AppColors.textPrimary,
      );

  /// 22sp — Empty state headings, section labels
  static TextStyle displaySmall({Color? color}) => GoogleFonts.caveat(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  /// 24sp Bold — Platform wordmark in app bar
  static TextStyle wordmark({Color? color}) => GoogleFonts.caveat(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color ?? AppColors.textPrimary,
      );

  // ── DM Sans — Headlines ───────────────────────────────────────────────────

  /// 20sp SemiBold — Item title on detail page
  static TextStyle headlineMedium({Color? color}) => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  /// 18sp SemiBold — Card titles, form section headers
  static TextStyle headlineSmall({Color? color}) => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  // ── DM Sans — Body ────────────────────────────────────────────────────────

  /// 16sp Regular — Descriptions, body content
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.textPrimary,
      );

  /// 14sp Regular — Meta info, secondary content
  static TextStyle bodyMedium({Color? color}) => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color ?? AppColors.textSecondary,
      );

  /// 12sp Regular — Timestamps, captions, fine print
  static TextStyle bodySmall({Color? color}) => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.textSecondary,
      );

  // ── DM Sans — Labels ──────────────────────────────────────────────────────

  /// 14sp Medium — Buttons, active tab labels
  static TextStyle labelLarge({Color? color}) => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  /// 12sp Medium — Chips, pills, small labels
  static TextStyle labelMedium({Color? color}) => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  /// 11sp Regular — Counter labels, fine print
  static TextStyle labelSmall({Color? color}) => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color ?? AppColors.textSecondary,
      );

  // ── DM Sans — Input ───────────────────────────────────────────────────────

  /// 16sp Regular — Text inside input fields
  static TextStyle inputText({Color? color}) => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.textPrimary,
      );

  /// 13sp Medium — Input field labels (above field)
  static TextStyle inputLabel({Color? color}) => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color ?? AppColors.textSecondary,
      );
}

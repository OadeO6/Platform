import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_decorations.dart';

/// ThemeData configuration for Platform.
/// Both light and dark themes are defined here.
class AppTheme {
  AppTheme._();

  // ── Light Theme ───────────────────────────────────────────────────────────

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,

        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.primaryTint,
          onSecondary: AppColors.primary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.destructive,
          onError: Colors.white,
        ),

        // Text theme uses DM Sans as base — Caveat applied manually via AppTextStyles
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          bodyLarge: GoogleFonts.dmSans(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          bodyMedium: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          bodySmall: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),

        // App bar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: GoogleFonts.caveat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),

        // Bottom navigation bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Tab bar
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              color: AppColors.textPrimary,
              width: 2,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.divider,
        ),

        // Elevated button (primary)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: AppDecorations.defaultRadius,
            ),
            elevation: 0,
            textStyle: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Text button (ghost/secondary)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Outlined button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: AppDecorations.defaultRadius,
            ),
            textStyle: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.divider, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.divider, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.destructive, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.destructive, width: 2),
          ),
          labelStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          hintStyle: GoogleFonts.dmSans(
            fontSize: 16,
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.primaryTint,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
          shape: const StadiumBorder(),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // Bottom sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          elevation: 0,
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.defaultRadius,
          ),
          elevation: 0,
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          contentTextStyle: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),

        // Snack bar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.defaultRadius,
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return AppColors.textSecondary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primary;
            return AppColors.divider;
          }),
        ),
      );

  // ── Dark Theme ────────────────────────────────────────────────────────────

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        primaryColor: AppColors.darkPrimary,

        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          onPrimary: Colors.white,
          secondary: AppColors.darkPrimaryTint,
          onSecondary: AppColors.darkPrimary,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          error: AppColors.destructiveDark,
          onError: Colors.white,
        ),

        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          bodyLarge: GoogleFonts.dmSans(
            color: AppColors.darkTextPrimary,
            fontSize: 16,
          ),
          bodyMedium: GoogleFonts.dmSans(
            color: AppColors.darkTextSecondary,
            fontSize: 14,
          ),
          bodySmall: GoogleFonts.dmSans(
            color: AppColors.darkTextSecondary,
            fontSize: 12,
          ),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: GoogleFonts.caveat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.darkTextPrimary,
            size: 24,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.darkPrimary,
          unselectedItemColor: AppColors.darkTextSecondary,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.darkTextPrimary,
          unselectedLabelColor: AppColors.darkTextSecondary,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              color: AppColors.darkTextPrimary,
              width: 2,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.darkDivider,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: AppDecorations.defaultRadius,
            ),
            elevation: 0,
            textStyle: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.darkPrimary,
            textStyle: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.darkDivider, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.darkDivider, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.destructiveDark, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppDecorations.defaultRadius,
            borderSide: const BorderSide(color: AppColors.destructiveDark, width: 2),
          ),
          labelStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextSecondary,
          ),
          hintStyle: GoogleFonts.dmSans(
            fontSize: 16,
            color: AppColors.darkTextSecondary.withOpacity(0.6),
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.darkDivider,
          thickness: 1,
          space: 1,
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          elevation: 0,
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.defaultRadius,
          ),
          elevation: 0,
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
          contentTextStyle: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.darkTextSecondary,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkSurface,
          contentTextStyle: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.darkTextPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.defaultRadius,
          ),
          behavior: SnackBarBehavior.floating,
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return AppColors.darkTextSecondary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.darkPrimary;
            return AppColors.darkDivider;
          }),
        ),
      );
}

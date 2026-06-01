import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary:        AppColors.primary,
      onPrimary:      AppColors.textOnDark,
      primaryContainer: AppColors.primaryLight,
      secondary:      AppColors.accentGold,
      onSecondary:    AppColors.textOnDark,
      surface:        AppColors.surface,
      onSurface:      AppColors.textPrimary,
      error:          AppColors.error,
      onError:        AppColors.textOnDark,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _textTheme,
    appBarTheme: _appBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: _cardTheme,
    chipTheme: _chipTheme,
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
  );

  // ── TEXT THEME ──────────────────────────────────────────────
  static TextTheme get _textTheme => TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 32, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary, letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 26, fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.playfairDisplay(
      fontSize: 22, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontSize: 20, fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 18, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, letterSpacing: 0.4,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: AppColors.textOnDark, letterSpacing: 1.25,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, letterSpacing: 0.5,
    ),
  );

  // ── APP BAR ────────────────────────────────────────────────
  static AppBarTheme get _appBarTheme => AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnDark,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.playfairDisplay(
      fontSize: 20, fontWeight: FontWeight.w700,
      color: AppColors.textOnDark,
    ),
  );

  // ── ELEVATED BUTTON ────────────────────────────────────────
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnDark,
        minimumSize: const Size(88, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          letterSpacing: 1.25,
        ),
      ),
    );

  // ── OUTLINED BUTTON ────────────────────────────────────────
  static OutlinedButtonThemeData get _outlinedButtonTheme =>
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize: const Size(88, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          letterSpacing: 1.25,
        ),
      ),
    );

  // ── TEXT BUTTON ────────────────────────────────────────────
  static TextButtonThemeData get _textButtonTheme =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
        ),
      ),
    );

  // ── INPUT DECORATION ───────────────────────────────────────
  static InputDecorationTheme get _inputDecorationTheme =>
    InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14, color: AppColors.textDisabled,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 12, color: AppColors.error,
      ),
    );

  // ── CARD ───────────────────────────────────────────────────
  static CardThemeData get _cardTheme => const CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    shadowColor: AppColors.shadow,
  );

  // ── CHIP ───────────────────────────────────────────────────
  static ChipThemeData get _chipTheme => ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.primaryLight,
    labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  );

  // ── PREMIUM THEME ──────────────────────────────────────────
  static ThemeData get premiumTheme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.premiumBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentGold,
      onPrimary: AppColors.premiumBg,
      surface: AppColors.premiumSurface,
      onSurface: AppColors.premiumText,
    ),
    cardColor: AppColors.premiumSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.premiumBg,
      foregroundColor: AppColors.premiumText,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: AppColors.accentGold,
      ),
    ),
  );
}

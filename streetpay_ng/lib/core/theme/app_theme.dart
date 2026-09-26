import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm, soft light palette: pastel off-white surfaces, a single vibrant
/// brand accent (leaf green), and clear semantic accent colors for
/// payment/attendance status.
class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF0F8A3C);
  static const Color success = Color(0xFF1DB954);
  static const Color warning = Color(0xFFF5A524);
  static const Color danger = Color(0xFFF23D5C);
  static const Color info = Color(0xFF3A7BFF);
  static const Color background = Color(0xFFFBF6EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFF7EA);
  static const Color textPrimary = Color(0xFF201A14);
  static const Color textSecondary = Color(0xFF7A7268);
  static const Color textTertiary = Color(0xFFB4AB9E);
  static const Color border = Color(0xFFEFE7D8);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1DB954), Color(0xFF3A7BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft, low-opacity card shadow that reads as depth rather than a border.
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF201A14).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppTextStyles {
  AppTextStyles._();
  static TextStyle get displayLarge => GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.8);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static TextStyle get displaySmall => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700);
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700);
  static TextStyle get headlineMedium => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700);
  static TextStyle get headlineSmall => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get labelLarge => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600);
  static TextStyle get labelMedium => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600);
  static TextStyle get labelSmall => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3);
}

class AppTheme {
  AppTheme._();
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: AppTextStyles.headlineSmall,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );
}

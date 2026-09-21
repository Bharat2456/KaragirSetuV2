import 'package:flutter/material.dart';

/// Design direction: warm terracotta / indigo palette evoking Indian
/// textile & pottery craft, large tap targets, minimal on-screen text,
/// heavy use of icons so the app reads clearly even for low-literacy users.
class AppColors {
  static const terracotta = Color(0xFFBF5B3F);
  static const terracottaDark = Color(0xFF8C3F2C);
  static const indigo = Color(0xFF2E4374);
  static const cream = Color(0xFFFBF3E9);
  static const gold = Color(0xFFD9A441);
  static const success = Color(0xFF3E7C4A);
  static const ink = Color(0xFF2A2320);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.terracotta,
        primary: AppColors.terracotta,
        secondary: AppColors.indigo,
        surface: AppColors.cream,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(64),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppColors.indigo, width: 2),
          foregroundColor: AppColors.indigo,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }
}

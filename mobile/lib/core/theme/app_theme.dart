import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.cordilleraOchre,
        onPrimary: Colors.white,
        secondary: AppColors.yaretaPine,
        onSecondary: Colors.white,
        tertiary: AppColors.graniteMuted,
        surface: AppColors.pureWhite,
        onSurface: AppColors.basaltInk,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.alpineChalk,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.basaltInk,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.basaltInk,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.basaltInk),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.glacialBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.alpineChalk,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.glacialBorder),
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.basaltInk,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cordilleraOchre,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.basaltInk,
          side: const BorderSide(color: AppColors.glacialBorder, width: 1.2),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.glacialBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.glacialBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cordilleraOchre, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        labelStyle: const TextStyle(color: AppColors.graniteMuted, fontSize: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      ),
    );
  }
}

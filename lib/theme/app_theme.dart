import 'package:flutter/material.dart';

class AppTheme {
  // ─────────────────────────────────────────────
  // Premium Islamic Dark Color Palette
  // ─────────────────────────────────────────────

  // Screen Variable Fixes
  static const Color darkGreen = Color(0xFF0F5132);
  static const Color green = Color(0xFF176B45);

  static const Color primary = Color(0xFF0F5132);
  static const Color primaryDark = Color(0xFF06130F);
  static const Color primaryLight = Color(0xFF176B45);

  static const Color background = Color(0xFF06130F);
  static const Color backgroundSecondary = Color(0xFF0A1E17);

  static const Color cardColor = Color(0xFF0D251C);
  static const Color cardLight = Color(0xFF123225);

  static const Color gold = Color(0xFFC9A45C);
  static const Color goldLight = Color(0xFFE4C987);

  static const Color textDark = Color(0xFFF2EBDD);
  static const Color textMuted = Color(0xFF9DAEA5);

  static const Color danger = Color(0xFF9B3D35);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primaryLight,
        onPrimary: Colors.white,
        secondary: gold,
        onSecondary: Colors.black,
        surface: cardColor,
        onSurface: textDark,
        error: danger,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textDark,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
            color: gold,
            width: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        labelStyle: const TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF71837A),
        ),
        prefixIconColor: gold,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: gold,
            width: 0.5,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: gold,
            width: 0.5,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: gold,
            width: 1.4,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            54,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      iconTheme: const IconThemeData(
        color: gold,
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF123225),
        thickness: 1,
        space: 1,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: textDark,
        ),
        bodyMedium: TextStyle(
          color: textMuted,
        ),
        bodySmall: TextStyle(
          color: textMuted,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTheme {
  // ─────────────────────────────────────────────
  // Dynamic Theme Controller (থিম পরিবর্তন করার জন্য)
  // ─────────────────────────────────────────────
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.dark);

  // ─────────────────────────────────────────────
  // Premium Islamic Color Palette
  // ─────────────────────────────────────────────
  static const Color darkGreen = Color(0xFF0F5132);
  static const Color green = Color(0xFF176B45);

  static const Color primary = Color(0xFF0F5132);
  static const Color primaryDark = Color(0xFF06130F);
  static const Color primaryLight = Color(0xFF176B45);

  static const Color backgroundDark = Color(0xFF06130F);
  static const Color backgroundSecondaryDark = Color(0xFF0A1E17);

  static const Color cardColorDark = Color(0xFF0D251C);
  static const Color cardLightDark = Color(0xFF123225);

  static const Color gold = Color(0xFFC9A45C);
  static const Color goldLight = Color(0xFFE4C987);

  static const Color textDark = Color(0xFFF2EBDD);
  static const Color textMutedDark = Color(0xFF9DAEA5);

  static const Color danger = Color(0xFF9B3D35);

  // ─────────────────────────────────────────────
  // Legacy Aliases / Backwards Compatibility Getters
  // (Fixes all GitHub build errors across screens)
  // ─────────────────────────────────────────────
  static Color get background => backgroundDark;
  static Color get backgroundSecondary => backgroundSecondaryDark;
  static Color get cardColor => cardColorDark;
  static Color get cardLight => cardLightDark;
  static Color get textMuted => textMutedDark;

  // ─────────────────────────────────────────────
  // 1. Dark Theme
  // ─────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primaryLight,
        onPrimary: Colors.white,
        secondary: gold,
        onSecondary: Colors.black,
        surface: cardColorDark,
        onSurface: textDark,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
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
        color: cardColorDark,
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
        fillColor: cardColorDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        labelStyle: const TextStyle(
          color: textMutedDark,
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
          minimumSize: const Size(double.infinity, 54),
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
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      iconTheme: const IconThemeData(color: gold),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF123225),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: textDark, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textMutedDark),
        bodySmall: TextStyle(color: textMutedDark),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 2. Light Theme
  // ─────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F6F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: darkGreen,
        onPrimary: Colors.white,
        secondary: gold,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
            color: Color(0xFFE0E0E0),
            width: 0.8,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        labelStyle: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIconColor: darkGreen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFFCCCCCC),
            width: 0.8,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFFCCCCCC),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: darkGreen,
            width: 1.4,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
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
          foregroundColor: darkGreen,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      iconTheme: const IconThemeData(color: darkGreen),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
      ),
    );
  }
}

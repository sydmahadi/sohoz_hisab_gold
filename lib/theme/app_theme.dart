
import 'package:flutter/material.dart';

class AppTheme {
  // ─────────────────────────────────────────────
  // Dynamic Theme Controller
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

  // Dark mode
  static const Color backgroundDark = Color(0xFF06130F);
  static const Color backgroundSecondaryDark = Color(0xFF0A1E17);

  static const Color cardColorDark = Color(0xFF0D251C);
  static const Color cardLightDark = Color(0xFF123225);

  // Gold accent
  static const Color gold = Color(0xFFC9A45C);
  static const Color goldLight = Color(0xFFE4C987);

  // Dark text
  static const Color textDark = Color(0xFFF2EBDD);
  static const Color textMutedDark = Color(0xFF9DAEA5);

  // Common
  static const Color danger = Color(0xFF9B3D35);

  // Light mode
  static const Color backgroundLight = Color(0xFFF2F5F3);
  static const Color backgroundSecondaryLight = Color(0xFFE8ECE9);

  static const Color cardColorLight = Colors.white;
  static const Color cardLightLight = Color(0xFFE8ECE9);

  static const Color textLight = Color(0xFF1C2D27);
  static const Color textMutedLight = Color(0xFF5A6E65);

  // ─────────────────────────────────────────────
  // Dynamic Helper Getters
  // ─────────────────────────────────────────────

  static bool get isDark =>
      themeNotifier.value == ThemeMode.dark;

  static Color get background =>
      isDark ? backgroundDark : backgroundLight;

  static Color get backgroundSecondary =>
      isDark ? backgroundSecondaryDark : backgroundSecondaryLight;

  static Color get cardColor =>
      isDark ? cardColorDark : cardColorLight;

  static Color get cardLight =>
      isDark ? cardLightDark : cardLightLight;

  static Color get textMuted =>
      isDark ? textMutedDark : textMutedLight;

  static Color get textPrimary =>
      isDark ? textDark : textLight;

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

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: cardColorDark,
        selectedItemColor: gold,
        unselectedItemColor: textMutedDark,
        elevation: 8,
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
          color: textMutedDark,
        ),
        bodySmall: TextStyle(
          color: textMutedDark,
        ),
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

      scaffoldBackgroundColor: backgroundLight,

      colorScheme: ColorScheme.fromSeed(
        seedColor: darkGreen,
        brightness: Brightness.light,
      ).copyWith(
        primary: darkGreen,
        onPrimary: Colors.white,
        secondary: gold,
        onSecondary: Colors.white,
        surface: cardColorLight,
        onSurface: textLight,
        error: danger,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textLight,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: darkGreen,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColorLight,
        elevation: 2,
        shadowColor: Colors.black12,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
            color: Color(0xFFDDE3E0),
            width: 1,
          ),
        ),
      ),

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: darkGreen,
        unselectedItemColor: textMutedLight,
        elevation: 8,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLightLight,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),

        labelStyle: const TextStyle(
          color: textMutedLight,
          fontWeight: FontWeight.w500,
        ),

        hintStyle: const TextStyle(
          color: textMutedLight,
        ),

        prefixIconColor: darkGreen,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFFCBD5D0),
            width: 1,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFFCBD5D0),
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: darkGreen,
            width: 1.5,
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
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      iconTheme: const IconThemeData(
        color: darkGreen,
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8E5),
        thickness: 1,
        space: 1,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: textLight,
        ),
        bodyMedium: TextStyle(
          color: textLight,
        ),
        bodySmall: TextStyle(
          color: textMutedLight,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ThemeManager {
  static const String defaultTheme = "blue";
  static const String greenTheme = "green";
  static const String purpleTheme = "purple";

  /// ─────────────────────────────────────────────
  /// GET THEME BY NAME
  /// ─────────────────────────────────────────────
  static ThemeData getTheme(String themeName) {
    switch (themeName) {
      case greenTheme:
        return _greenTheme();

      case purpleTheme:
        return _purpleTheme();

      case defaultTheme:
      default:
        return _blueTheme();
    }
  }

  /// ─────────────────────────────────────────────
  /// BLUE THEME (DEFAULT)
  /// #23334C + #D4AF37
  /// ─────────────────────────────────────────────
  static ThemeData _blueTheme() {
    const primary = Color(0xFF23334C);
    const accent = Color(0xFFD4AF37);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: "PTSerif",

      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1E1E1E)),
        bodyMedium: TextStyle(color: Color(0xFF6B6B6B)),
      ),

      dividerColor: const Color(0xFFEAEAEA),
    );
  }

  /// ─────────────────────────────────────────────
  /// GREEN THEME
  /// #415A5B + #D4AF37
  /// ─────────────────────────────────────────────
  static ThemeData _greenTheme() {
    const primary = Color(0xFF415A5B);
    const accent = Color(0xFFD4AF37);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: "PTSerif",

      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// ─────────────────────────────────────────────
  /// PURPLE THEME
  /// #48426D + #8C4A5A
  /// ─────────────────────────────────────────────
  static ThemeData _purpleTheme() {
    const primary = Color(0xFF48426D);
    const accent = Color(0xFFD4AF37);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: "PTSerif",

      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

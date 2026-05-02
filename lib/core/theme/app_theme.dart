import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF5F5F7),
    primaryColor: const Color(0xFF3F51B5),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
      ),
    ),
  );
}////just example u should change it
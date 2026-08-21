import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF5B5FEF);
  static const Color secondary = Color(0xFF7B7FF5);
  static const Color textPrimary = Color(0xFF1B1D2A);
  static const Color textSecondary = Color(0xFF74788A);
  static const Color border = Color(0xFFE7E9F0);
  static const Color success = Color(0xFF33B27F);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: secondary,
          surface: surface,
          onSurface: textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
          borderSide: BorderSide(
            color: border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
          borderSide: BorderSide(
            color: border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
          borderSide: BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

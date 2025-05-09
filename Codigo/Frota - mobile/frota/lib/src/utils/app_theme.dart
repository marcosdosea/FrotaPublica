import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color primaryDarkColor = Color(0xFF004BA7);
  static const Color primaryLightColor = Color(0xFF116AD5);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textColor = Colors.black87;
  static const Color secondaryTextColor = Colors.grey;

  // Tema claro
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF116AD5),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF116AD5),
      primary: const Color(0xFF116AD5),
      secondary: const Color(0xFF0066CC),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF116AD5),
      foregroundColor: Colors.white,
    ),
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF116AD5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF116AD5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

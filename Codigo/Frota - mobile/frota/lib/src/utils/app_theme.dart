import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color primaryDarkColor = Color(0xFF004BA7);
  static const Color primaryLightColor = Color(0xFF116AD5);

  // Cores do tema claro
  static const Color lightBackgroundColor = Color(0xFFD8E6EE);
  static const Color lightCardColor = Colors.white;
  static const Color lightTextColor = Colors.black87;
  static const Color lightSecondaryTextColor = Colors.grey;

  // Cores do tema escuro
  static const Color darkBackgroundColor = Color(0xFF0C0C19);
  static const Color darkCardColor = Color(0xFF0B0C43);
  static const Color darkTextColor = Colors.white;
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0);

  // Tema claro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryLightColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLightColor,
      primary: primaryLightColor,
      secondary: primaryColor,
      brightness: Brightness.light,
      surface: lightCardColor,
      background: lightBackgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLightColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    fontFamily: 'Poppins',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLightColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryLightColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: lightCardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightTextColor),
      bodyMedium: TextStyle(color: lightTextColor),
      bodySmall: TextStyle(color: lightSecondaryTextColor),
      headlineLarge: TextStyle(color: lightTextColor),
      headlineMedium: TextStyle(color: lightTextColor),
      headlineSmall: TextStyle(color: lightTextColor),
      titleLarge: TextStyle(color: lightTextColor),
      titleMedium: TextStyle(color: lightTextColor),
      titleSmall: TextStyle(color: lightTextColor),
    ),
  );

  // Tema escuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryLightColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLightColor,
      primary: primaryLightColor,
      secondary: primaryColor,
      brightness: Brightness.dark,
      surface: darkCardColor,
      background: darkBackgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLightColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    fontFamily: 'Poppins',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLightColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryLightColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: darkCardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
      bodySmall: TextStyle(color: darkSecondaryTextColor),
      headlineLarge: TextStyle(color: darkTextColor),
      headlineMedium: TextStyle(color: darkTextColor),
      headlineSmall: TextStyle(color: darkTextColor),
      titleLarge: TextStyle(color: darkTextColor),
      titleMedium: TextStyle(color: darkTextColor),
      titleSmall: TextStyle(color: darkTextColor),
    ),
  );
}

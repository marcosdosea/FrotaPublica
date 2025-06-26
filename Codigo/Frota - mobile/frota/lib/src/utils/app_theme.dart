import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color primaryDarkColor = Color(0xFF004BA7);
  static const Color primaryLightColor = Color(0xFF116AD5);

  // Gradientes simplificados
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF116AD5),
      Color(0xFF0066CC),
      Color(0xFF004BA7),
    ],
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE3F2FD),
      Color(0xFFBBDEFB),
      Color(0xFF90CAF9),
    ],
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F0F23),
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
    ],
  );

  // Cores do tema claro
  static const Color lightBackgroundColor = Color(0xFFE3F2FD);
  static const Color lightCardColor = Colors.white;
  static const Color lightTextColor = Colors.black87;
  static const Color lightSecondaryTextColor = Colors.grey;

  // Cores do tema escuro
  static const Color darkBackgroundColor = Color(0xFF0F0F23);
  static const Color darkCardColor = Color(0xFF1A1A2E);
  static const Color darkTextColor = Colors.white;
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0);

  // Método para criar card moderno (simplificado)
  static Widget modernCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool isDark = false,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? darkCardColor : lightCardColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

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
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    fontFamily: 'Poppins',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLightColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: primaryLightColor.withOpacity(0.3),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLightColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    fontFamily: 'Poppins',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLightColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: primaryLightColor.withOpacity(0.3),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLightColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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

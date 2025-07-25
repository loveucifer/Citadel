// File: lib/src/utils/app_theme.dart

import 'package:flutter/material.dart';

/// A utility class that holds the theme data for the Citadel app.
class AppTheme {
  // Private constructor to prevent instantiation.
  AppTheme._();

  // --- Color Palette ---
  // A soft, pastel color scheme for a calm and minimalist feel.
  static const Color primaryColor = Color(0xFFB3E5FC); // Light Blue
  static const Color accentColor = Color(0xFFF8BBD0);  // Soft Pink
  static const Color backgroundColor = Color(0xFFFFF9C4); // Pale Yellow/Cream
  static const Color cardColor = Color(0xFFFFFFFF);      // White
  static const Color textColor = Color(0xFF424242);      // Dark Grey
  static const Color subtleTextColor = Color(0xFF757575); // Medium Grey
  static const Color recordButtonColor = Color(0xFFFF8A80); // Pastel Red

  /// The main theme data for the application.
  static final ThemeData softPastelTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Inter', // Assuming 'Inter' font is added to the project later

    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0.5,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),

    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2.0,
      shadowColor: primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: textColor,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(color: subtleTextColor, fontSize: 12),
    ),

    iconTheme: const IconThemeData(
      color: textColor,
    ),

    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: accentColor,
      background: backgroundColor,
    ),
  );
}

import 'package:flutter/material.dart';

class DesignSystem {
  // Cores
  static const Color primary = Color(0xFF2563EB); // Blue
  static const Color secondary = Color(0xFF6B7280); // Gray
  static const Color tertiary = Color(0xFFF9FAFB); // Light
  static const Color background = Color(0xFFF9FAFB); // Fundo das telas
  static const Color surface = Color(0xFFFFFFFF); // Cartões
  
  static const Color success = Color(0xFF15803D); // contraste ≥4,5:1 com texto branco
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Spacing & Sizes
  static const double minTouchTarget = 44.0;
  static const double cardRadius = 12.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  
  // Sombras (leves, sem peso nos cartões)
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4.0,
      offset: const Offset(0, 2),
    ),
  ];

  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: secondary,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: secondary),
      ),
    );
  }
}

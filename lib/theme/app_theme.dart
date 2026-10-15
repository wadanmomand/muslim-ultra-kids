import 'package:flutter/material.dart';

/// Muslim Ultra Kids — Option A "Bright Kids" art direction (locked 2026-10-12).
/// Sky/teal + gold, friendly for ages 5-12. Rounded everything, chunky buttons.
class KidsTheme {
  // Palette
  static const Color skyTop = Color(0xFF7ED6F2);
  static const Color skyBottom = Color(0xFFD8F4FF);
  static const Color teal = Color(0xFF2AB8A6);
  static const Color tealDark = Color(0xFF1E8A7D);
  static const Color gold = Color(0xFFF5B301);
  static const Color goldDark = Color(0xFFD99400);
  static const Color ink = Color(0xFF2D3A4A);
  static const Color cardWhite = Colors.white;
  static const Color starGrey = Color(0xFFDDE7F0);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = base.textTheme.apply(
      bodyColor: ink,
      displayColor: ink,
      fontFamilyFallback: const ['Noto Nastaliq Urdu', 'sans-serif'],
    );
    return base.copyWith(
      scaffoldBackgroundColor: skyBottom,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        primary: teal,
        secondary: gold,
        surface: cardWhite,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ink,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: ink,
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 4,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  /// Sky gradient background used on map/home screens.
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyTop, skyBottom],
  );
}

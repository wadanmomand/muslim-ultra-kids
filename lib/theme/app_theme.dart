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

  // Night palette (dark mode)
  static const Color nightTop = Color(0xFF10294D);
  static const Color nightBottom = Color(0xFF1D3F66);
  static const Color nightCard = Color(0xFF24466E);
  static const Color nightInk = Color(0xFFF4F7FB);

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

  /// Night gradient background for dark mode.
  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [nightTop, nightBottom],
  );

  /// Background gradient for the current theme mode.
  static LinearGradient bgFor(bool isDark) =>
      isDark ? nightGradient : skyGradient;

  /// Primary text color for the current theme mode.
  static Color inkFor(bool isDark) => isDark ? nightInk : ink;

  /// Card color for the current theme mode.
  static Color cardFor(bool isDark) => isDark ? nightCard : cardWhite;

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = base.textTheme.apply(
      bodyColor: nightInk,
      displayColor: nightInk,
      fontFamilyFallback: const ['Noto Nastaliq Urdu', 'sans-serif'],
    );
    return base.copyWith(
      scaffoldBackgroundColor: nightBottom,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        brightness: Brightness.dark,
        primary: teal,
        secondary: gold,
        surface: nightCard,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: nightInk,
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
        color: nightCard,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: nightCard),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.all(teal),
      ),
    );
  }
}

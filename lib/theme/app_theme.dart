import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandBlue = Color(0xFF011956);
  static const Color brandOrange = Color(0xFFE7672C);
  static const Color surface = Color(0xFFF6F7FB);
  static const Color card = Colors.white;
  static const Color ink = Color(0xFF0F172A);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: brandBlue,
    ).copyWith(
      primary: brandBlue,
      secondary: brandOrange,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: brandBlue, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        selectedColor: brandBlue.withOpacity(.08),
        secondarySelectedColor: brandOrange.withOpacity(.18),
        side: BorderSide.none,
        backgroundColor: Colors.blueGrey.shade50,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
        bodyLarge: TextStyle(color: ink),
        bodyMedium: TextStyle(color: ink),
      ),
    );
  }
}

// lib/core/constants/app_themes.dart
import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: Brightness.light,
      primary: const Color(0xFF6C63FF),
      secondary: const Color(0xFF4A43A8),
      tertiary: const Color(0xFF8E85FF),
      surface: Colors.white,
      surfaceVariant: const Color(0xFFF5F5FF),
      onSurface: const Color(0xFF1A1A1A),
      background: const Color(0xFFF8F8FF),
    ),
    textTheme: _textTheme,
    appBarTheme: _appBarTheme,
    cardTheme: _cardTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    filledButtonTheme: _filledButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    chipTheme: _chipTheme,
    dividerTheme: _dividerTheme,
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: Brightness.dark,
      primary: const Color(0xFF6C63FF),
      secondary: const Color(0xFF8E85FF),
      tertiary: const Color(0xFF4A43A8),
      surface: const Color(0xFF1E1E2E),
      surfaceVariant: const Color(0xFF2D2D3D),
      onSurface: Colors.white,
      background: const Color(0xFF121212),
    ),
    textTheme: _textTheme.apply(
      displayColor: Colors.white,
      bodyColor: Colors.white,
    ),
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: const Color(0xFF1E1E2E),
    ),
    cardTheme: _cardTheme.copyWith(
      color: const Color(0xFF2D2D3D),
    ),
    inputDecorationTheme: _inputDecorationTheme.copyWith(
      fillColor: const Color(0xFF2D2D3D),
    ),
  );

  // Shared Theme Components
  static const _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, height: 1.1),
    displayMedium: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, height: 1.15),
    displaySmall: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, height: 1.2),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.25),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.3),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, height: 1.35),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.4),
    titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1.45),
    titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.5),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, height: 1.6),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, height: 1.65),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, height: 1.7),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.55),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.6),
  );

  static const _appBarTheme = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 1,
    surfaceTintColor: Colors.transparent,
  );

  static final _cardTheme = CardTheme(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    surfaceTintColor: Colors.transparent,
  );

  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final _inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  static final _chipTheme = ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    side: BorderSide.none,
  );

  static const _dividerTheme = DividerThemeData(
    thickness: 1,
    space: 1,
  );
  
}

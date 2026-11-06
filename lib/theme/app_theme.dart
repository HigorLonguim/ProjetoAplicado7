import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF10192A);
  static const navyLight = Color(0xFF213045);
  static const border = Color(0xFF3A4C63);
  static const orange = Color(0xFFFF9800);
  static const terracotta = Color(0xFFFF7043);
  static const peach = Color(0xFFFFCC80);
  static const olive = Color(0xFF4CAF50);
  static const forest = Color(0xFF81C784);
  static const mint = Color(0xFFA5D6A7);
  static const cream = Color(0xFFF5F5F5);
  static const ink = Color(0xFFF5F5F5);
  static const textDark = Color(0xFF0D1730);
  static const darkSurface = Color(0xFF213045);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.olive,
          primary: AppColors.orange,
          secondary: AppColors.olive,
          tertiary: AppColors.terracotta,
          surface: AppColors.darkSurface,
          brightness: Brightness.dark,
        ).copyWith(
          onSurface: AppColors.ink,
          onSurfaceVariant: const Color(0xFFD8DEE8),
          outline: AppColors.border,
          outlineVariant: AppColors.border,
          onPrimary: AppColors.textDark,
          onSecondary: AppColors.textDark,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Arial',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.1,
          color: AppColors.ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          letterSpacing: -.6,
          color: AppColors.ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: AppColors.ink),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: AppColors.ink),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.35,
          color: Color(0xFFD8DEE8),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: .18),
        color: AppColors.darkSurface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.peach),
      ),
      dividerTheme: DividerThemeData(color: AppColors.border),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.navy,
        indicatorColor: AppColors.olive.withValues(alpha: .2),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.peach
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Origem's visual language. Legacy aliases keep feature screens compatible
/// while they migrate to the new system.
abstract final class AppColors {
  static const petroleum = Color(0xFF071A1D);
  static const petroleumRaised = Color(0xFF102A2C);
  static const sage = Color(0xFFA8C99A);
  static const deepSage = Color(0xFF294C3B);
  static const apricot = Color(0xFFFF8A4C);
  static const warmYellow = Color(0xFFFFD36A);
  static const mineral = Color(0xFFF3F0E8);
  static const sand = Color(0xFFD9D0C1);
  static const muted = Color(0xFF9FB3AE);
  static const danger = Color(0xFFFF7D68);

  static const navy = petroleum;
  static const navyLight = petroleumRaised;
  static const border = Color(0xFF355052);
  static const electricBlue = sage;
  static const sky = Color(0xFFC7DFC0);
  static const orange = apricot;
  static const terracotta = Color(0xFFE96F43);
  static const peach = warmYellow;
  static const olive = sage;
  static const forest = Color(0xFF79AA76);
  static const mint = Color(0xFFC7DFC0);
  static const cream = mineral;
  static const ink = mineral;
  static const textDark = petroleum;
  static const darkSurface = petroleumRaised;
}

abstract final class AppSpacing {
  static const xs = 6.0;
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 32.0;
  static const xl = 48.0;
  static const xxl = 72.0;
}

abstract final class AppRadius {
  static const control = 16.0;
  static const surface = 28.0;
  static const hero = 40.0;
}

abstract final class AppMotion {
  static const micro = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 360);
  static const reveal = Duration(milliseconds: 500);
  static const curve = Curves.easeOutCubic;
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = const ColorScheme.dark(
      primary: AppColors.apricot,
      onPrimary: AppColors.petroleum,
      secondary: AppColors.sage,
      onSecondary: AppColors.petroleum,
      surface: AppColors.petroleumRaised,
      onSurface: AppColors.mineral,
      error: AppColors.danger,
      outline: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.petroleum,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _OrigemPageTransitionsBuilder(),
          TargetPlatform.iOS: _OrigemPageTransitionsBuilder(),
          TargetPlatform.macOS: _OrigemPageTransitionsBuilder(),
          TargetPlatform.windows: _OrigemPageTransitionsBuilder(),
          TargetPlatform.linux: _OrigemPageTransitionsBuilder(),
        },
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 68,
          height: .94,
          fontWeight: FontWeight.w700,
          letterSpacing: -3.4,
          color: AppColors.mineral,
        ),
        headlineLarge: TextStyle(
          fontSize: 42,
          height: 1,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.8,
          color: AppColors.mineral,
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: AppColors.mineral,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.mineral,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -.2,
          color: AppColors.mineral,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.mineral,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.55,
          color: AppColors.mineral,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.mineral,
        ),
        bodySmall: TextStyle(fontSize: 12, height: 1.4, color: AppColors.muted),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: .1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.petroleum,
        foregroundColor: AppColors.mineral,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.mineral,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.petroleumRaised,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.surface),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          backgroundColor: AppColors.apricot,
          foregroundColor: AppColors.petroleum,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          foregroundColor: AppColors.mineral,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.petroleumRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.apricot, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.sage),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.deepSage,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      focusColor: AppColors.warmYellow.withValues(alpha: .2),
    );
  }
}

class _OrigemPageTransitionsBuilder extends PageTransitionsBuilder {
  const _OrigemPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(.025, .012),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

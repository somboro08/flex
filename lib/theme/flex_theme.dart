import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  FLEX DESIGN TOKENS
// ─────────────────────────────────────────────

class FlexColors {
  // Primary - Orange
  static const primary50  = Color(0xFFFFF3E0);
  static const primary100 = Color(0xFFFFE0B2);
  static const primary200 = Color(0xFFFFCC80);
  static const primary300 = Color(0xFFFFB74D);
  static const primary400 = Color(0xFFFFA726);
  static const primary500 = Color(0xFFFF6B00); // Main brand color
  static const primary600 = Color(0xFFE65100);
  static const primary700 = Color(0xFFBF360C);

  // Neutral - Warm grays
  static const neutral0   = Color(0xFFFFFFFF);
  static const neutral50  = Color(0xFFFAF9F7);
  static const neutral100 = Color(0xFFF2F0EC);
  static const neutral200 = Color(0xFFE5E2DC);
  static const neutral300 = Color(0xFFCCC8BF);
  static const neutral400 = Color(0xFF9E9A92);
  static const neutral500 = Color(0xFF706C65);
  static const neutral600 = Color(0xFF4A4740);
  static const neutral700 = Color(0xFF2E2B25);
  static const neutral800 = Color(0xFF1E1C18);
  static const neutral900 = Color(0xFF12100D);

  // Semantic
  static const success    = Color(0xFF22C55E);
  static const warning    = Color(0xFFF59E0B);
  static const error      = Color(0xFFEF4444);
  static const info       = Color(0xFF3B82F6);

  // Certification badge
  static const certified  = Color(0xFF22C55E);
  static const pending    = Color(0xFFF59E0B);
  static const rejected   = Color(0xFFEF4444);
}

class FlexSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double xxl  = 48.0;
  static const double xxxl = 64.0;
}

class FlexRadius {
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double full = 999.0;
}

// ─────────────────────────────────────────────
//  TEXT STYLES
// ─────────────────────────────────────────────

class FlexTextStyles {
  static const String fontFamily = 'Poppins';

  static const display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}

// ─────────────────────────────────────────────
//  LIGHT THEME
// ─────────────────────────────────────────────

ThemeData flexLightTheme() {
  const seed = FlexColors.primary500;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: FlexTextStyles.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      primary: FlexColors.primary500,
      onPrimary: Colors.white,
      secondary: FlexColors.primary300,
      surface: FlexColors.neutral0,
      background: FlexColors.neutral50,
      error: FlexColors.error,
    ),
    scaffoldBackgroundColor: FlexColors.neutral50,
    appBarTheme: const AppBarTheme(
      backgroundColor: FlexColors.neutral0,
      foregroundColor: FlexColors.neutral800,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: FlexTextStyles.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: FlexColors.neutral800,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FlexColors.primary500,
        foregroundColor: Colors.white,
        textStyle: FlexTextStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FlexRadius.lg),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FlexColors.primary500,
        textStyle: FlexTextStyles.button,
        side: const BorderSide(color: FlexColors.primary500, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FlexRadius.lg),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: FlexColors.primary500,
        textStyle: FlexTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FlexColors.neutral100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FlexRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FlexRadius.md),
        borderSide: const BorderSide(color: FlexColors.neutral200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FlexRadius.md),
        borderSide: const BorderSide(color: FlexColors.primary500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FlexRadius.md),
        borderSide: const BorderSide(color: FlexColors.error),
      ),
      hintStyle: FlexTextStyles.body.copyWith(color: FlexColors.neutral400),
    ),
    cardTheme: CardThemeData(
      color: FlexColors.neutral0,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        side: const BorderSide(color: FlexColors.neutral200, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: FlexColors.neutral100,
      selectedColor: FlexColors.primary100,
      labelStyle: FlexTextStyles.caption,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlexRadius.full),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: FlexColors.neutral0,
      selectedItemColor: FlexColors.primary500,
      unselectedItemColor: FlexColors.neutral400,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: FlexTextStyles.fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: FlexTextStyles.fontFamily,
        fontSize: 11,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: FlexColors.neutral200,
      thickness: 0.5,
    ),
    textTheme: const TextTheme(
      displayLarge: FlexTextStyles.display,
      headlineLarge: FlexTextStyles.h1,
      headlineMedium: FlexTextStyles.h2,
      headlineSmall: FlexTextStyles.h3,
      bodyLarge: FlexTextStyles.bodyLarge,
      bodyMedium: FlexTextStyles.body,
      bodySmall: FlexTextStyles.caption,
      labelLarge: FlexTextStyles.button,
      labelMedium: FlexTextStyles.label,
    ),
  );
}

// ─────────────────────────────────────────────
//  DARK THEME
// ─────────────────────────────────────────────

ThemeData flexDarkTheme() {
  const seed = FlexColors.primary500;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: FlexTextStyles.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      primary: FlexColors.primary400,
      onPrimary: FlexColors.neutral900,
      secondary: FlexColors.primary600,
      surface: FlexColors.neutral800,
      background: FlexColors.neutral900,
      error: FlexColors.error,
    ),
    scaffoldBackgroundColor: FlexColors.neutral900,
    appBarTheme: const AppBarTheme(
      backgroundColor: FlexColors.neutral800,
      foregroundColor: FlexColors.neutral0,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: FlexTextStyles.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: FlexColors.neutral0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FlexColors.primary500,
        foregroundColor: Colors.white,
        textStyle: FlexTextStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FlexRadius.lg),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FlexColors.primary400,
        textStyle: FlexTextStyles.button,
        side: const BorderSide(color: FlexColors.primary400, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FlexRadius.lg),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: FlexColors.primary400,
        textStyle: FlexTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FlexColors.neutral700,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FlexRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FlexRadius.md),
        borderSide: const BorderSide(color: FlexColors.neutral600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FlexRadius.md),
        borderSide: const BorderSide(color: FlexColors.primary400, width: 2),
      ),
      hintStyle: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
    ),
    cardTheme: CardThemeData(
      color: FlexColors.neutral800,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        side: const BorderSide(color: FlexColors.neutral700, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: FlexColors.neutral800,
      selectedItemColor: FlexColors.primary400,
      unselectedItemColor: FlexColors.neutral500,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: FlexColors.neutral700,
      thickness: 0.5,
    ),
    textTheme: const TextTheme(
      displayLarge: FlexTextStyles.display,
      headlineLarge: FlexTextStyles.h1,
      headlineMedium: FlexTextStyles.h2,
      headlineSmall: FlexTextStyles.h3,
      bodyLarge: FlexTextStyles.bodyLarge,
      bodyMedium: FlexTextStyles.body,
      bodySmall: FlexTextStyles.caption,
      labelLarge: FlexTextStyles.button,
      labelMedium: FlexTextStyles.label,
    ),
  );
}

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  static final _purple = Color(AppColors.purple);
  static final _purple2 = Color(AppColors.purple2);
  static final _accent = Color(AppColors.accent);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(AppColors.darkBg),
    colorScheme: ColorScheme.dark(
      primary: _purple,
      secondary: _accent,
      surface: Color(AppColors.darkCard),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(AppColors.textDark),
    ),
    cardColor: Color(AppColors.darkCard),
    cardTheme: CardThemeData(
      color: Color(AppColors.darkCard),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(color: Color(AppColors.darkBorder)),
      ),
    ),
    textTheme: _buildTextTheme(Color(AppColors.textDark), Color(AppColors.mutedDark)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(AppColors.darkBg2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: Color(AppColors.darkBorder)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: Color(AppColors.darkBorder)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: _purple, width: 2),
      ),
      labelStyle: TextStyle(color: Color(AppColors.mutedDark)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _purple2,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(AppColors.darkBg2),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(AppColors.textDark),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Color(AppColors.textDark)),
    ),
    dividerColor: Color(AppColors.darkBorder),
    fontFamily: 'Roboto',
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(AppColors.lightBg),
    colorScheme: ColorScheme.light(
      primary: _purple,
      secondary: _accent,
      surface: Color(AppColors.lightCard),
      onPrimary: Colors.white,
      onSurface: Color(AppColors.textLight),
    ),
    cardColor: Color(AppColors.lightCard),
    cardTheme: CardThemeData(
      color: Color(AppColors.lightCard),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(color: Color(AppColors.lightBorder)),
      ),
    ),
    textTheme: _buildTextTheme(Color(AppColors.textLight), Color(AppColors.mutedLight)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(AppColors.lightBg2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: Color(AppColors.lightBorder)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: Color(AppColors.lightBorder)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: _purple, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _purple2,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(AppColors.lightCard),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(AppColors.textLight),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Color(AppColors.textLight)),
    ),
    dividerColor: Color(AppColors.lightBorder),
    fontFamily: 'Roboto',
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 32),
      displayMedium: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 26),
      titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 18),
      titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 15),
      bodyLarge: TextStyle(color: primary, fontSize: 14),
      bodyMedium: TextStyle(color: secondary, fontSize: 12),
      labelSmall: TextStyle(color: secondary, fontSize: 10, letterSpacing: 0.5),
    );
  }

  static LinearGradient get primaryGradient => LinearGradient(
        colors: [Color(AppColors.purple2), Color(AppColors.accent)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

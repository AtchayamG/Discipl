import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppTheme — Central theme definition for Discipl.AI
///
/// Design language:
///   • Dark-first, luxury fitness aesthetic (Whoop / Oura ring style)
///   • Primary brand color: Electric Lime  #C8F135
///   • Fonts: Poppins (display) + Inter (body)
///   • Change ONE color in AppColors → propagates to entire app
/// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── Shared colors ────────────────────────────────────────────────────────────
  static const Color _lime    = Color(AppColors.lime);
  static const Color _teal    = Color(AppColors.teal);
  static const Color _red     = Color(AppColors.red);
  static const Color _border  = Color(AppColors.border);
  static const Color _border2 = Color(AppColors.border2);

  // ── Dark Theme ───────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,

        // Backgrounds
        scaffoldBackgroundColor: const Color(AppColors.bg),

        // Color scheme
        colorScheme: const ColorScheme.dark(
          primary:    _lime,
          secondary:  _teal,
          error:      _red,
          surface:    Color(AppColors.bg2),
          onPrimary:  Color(AppColors.bg),     // text on lime buttons → dark
          onSecondary: Colors.white,
          onSurface:  Color(AppColors.textPrimary),
          outline:    _border,
        ),

        // Cards
        cardColor: const Color(AppColors.bg2),
        cardTheme: CardThemeData(
          color: const Color(AppColors.bg2),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            side: const BorderSide(color: _border),
          ),
        ),

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(AppColors.bg),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(AppColors.textPrimary),
          ),
          iconTheme: IconThemeData(color: Color(AppColors.textPrimary)),
        ),

        // Divider
        dividerColor: _border,
        dividerTheme: const DividerThemeData(color: _border, thickness: 1),

        // Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(AppColors.bg3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: _border2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: _border2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: _lime, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: _red),
          ),
          labelStyle: const TextStyle(
            fontFamily: AppTypography.bodyFont,
            color: Color(AppColors.textMuted),
          ),
          hintStyle: const TextStyle(
            fontFamily: AppTypography.bodyFont,
            color: Color(AppColors.textMuted2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),

        // Elevated buttons → lime fill
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _lime,
            foregroundColor: const Color(AppColors.bg),
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: const Size(64, 48),
            textStyle: const TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),

        // Outlined buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(AppColors.textPrimary),
            side: const BorderSide(color: _border2),
            minimumSize: const Size(64, 48),
            textStyle: const TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          ),
        ),

        // Text buttons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _lime,
            minimumSize: const Size(48, 44),
            textStyle: const TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Bottom nav bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(AppColors.bg2),
          selectedItemColor: _lime,
          unselectedItemColor: Color(AppColors.textMuted),
          selectedLabelStyle: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: AppTypography.bodyFont,
            fontSize: 10,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Switch / Checkbox
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? const Color(AppColors.bg) : const Color(AppColors.textMuted)),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? _lime : const Color(AppColors.surface)),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? _lime : Colors.transparent),
          checkColor: WidgetStateProperty.all(const Color(AppColors.bg)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: _border2),
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: const Color(AppColors.bg3),
          selectedColor: const Color(AppColors.limeAlpha20),
          labelStyle: const TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            side: const BorderSide(color: _border2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),

        // Progress indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: _lime,
          linearTrackColor: Color(AppColors.surface),
        ),

        // Slider
        sliderTheme: const SliderThemeData(
          activeTrackColor: _lime,
          thumbColor: _lime,
          inactiveTrackColor: Color(AppColors.surface),
        ),

        // Tooltip
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color(AppColors.surface),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: _border2),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.bodyFont,
            fontSize: 11,
            color: Color(AppColors.textPrimary),
          ),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(AppColors.bg2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            side: const BorderSide(color: _border2),
          ),
          titleTextStyle: const TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(AppColors.textPrimary),
          ),
          contentTextStyle: const TextStyle(
            fontFamily: AppTypography.bodyFont,
            fontSize: 13,
            color: Color(AppColors.textMuted),
          ),
        ),

        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(AppColors.surface),
          contentTextStyle: const TextStyle(
            fontFamily: AppTypography.bodyFont,
            fontSize: 13,
            color: Color(AppColors.textPrimary),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // List tiles
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          iconColor: Color(AppColors.textMuted),
          textColor: Color(AppColors.textPrimary),
        ),

        // Text theme
        fontFamily: AppTypography.bodyFont,
        textTheme: _buildTextTheme(
          const Color(AppColors.textPrimary),
          const Color(AppColors.textMuted),
        ),
      );

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme => darkTheme.copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(AppColors.lightBg),
        colorScheme: const ColorScheme.light(
          primary:     Color(AppColors.limeLight),
          secondary:   Color(AppColors.teal),
          error:       Color(AppColors.red),
          surface:     Color(AppColors.lightCard),
          onPrimary:   Colors.white,
          onSurface:   Color(AppColors.textLight),
          outline:     Color(AppColors.lightBorder),
        ),
        cardColor: const Color(AppColors.lightCard),
        cardTheme: CardThemeData(
          color: const Color(AppColors.lightCard),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            side: const BorderSide(color: Color(AppColors.lightBorder)),
          ),
        ),
        dividerColor: const Color(AppColors.lightBorder),
        dividerTheme: const DividerThemeData(color: Color(AppColors.lightBorder), thickness: 1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(AppColors.lightCard),
          elevation: 0, scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 17, fontWeight: FontWeight.w700, color: Color(AppColors.textLight)),
          iconTheme: IconThemeData(color: Color(AppColors.textLight)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(AppColors.lightCard2),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)), borderSide: const BorderSide(color: Color(AppColors.lightBorder))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)), borderSide: const BorderSide(color: Color(AppColors.lightBorder))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)), borderSide: const BorderSide(color: Color(AppColors.limeLight), width: 1.5)),
          hintStyle: const TextStyle(color: Color(AppColors.mutedLight2)),
          labelStyle: const TextStyle(color: Color(AppColors.mutedLight)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.limeLight),
            foregroundColor: Colors.white,
            elevation: 0, shadowColor: Colors.transparent,
            minimumSize: const Size(64, 48),
            textStyle: const TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(AppColors.textLight),
            side: const BorderSide(color: Color(AppColors.lightBorder2)),
            minimumSize: const Size(64, 48),
            textStyle: const TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? Colors.white : const Color(AppColors.mutedLight)),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? const Color(AppColors.limeLight) : const Color(AppColors.lightBg2)),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? const Color(AppColors.limeLight) : Colors.transparent),
          checkColor: WidgetStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: Color(AppColors.lightBorder2)),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(AppColors.lightCard2),
          selectedColor: const Color(AppColors.limeLightBg),
          labelStyle: const TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusXl), side: const BorderSide(color: Color(AppColors.lightBorder))),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(AppColors.limeLight),
          linearTrackColor: Color(AppColors.surfaceLight),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Color(AppColors.limeLight),
          thumbColor: Color(AppColors.limeLight),
          inactiveTrackColor: Color(AppColors.surfaceLight),
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          iconColor: Color(AppColors.mutedLight),
          textColor: Color(AppColors.textLight),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(AppColors.lightCard),
          titleTextStyle: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 17, fontWeight: FontWeight.w700, color: Color(AppColors.textLight)),
          contentTextStyle: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: Color(AppColors.mutedLight)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(AppColors.textLight),
          contentTextStyle: const TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          behavior: SnackBarBehavior.floating,
        ),
        textTheme: _buildTextTheme(const Color(AppColors.textLight), const Color(AppColors.mutedLight)),
      );
  // ── Text theme builder ────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color muted) {
    return TextTheme(
      // display
      displayLarge:  _ts(primary, AppTypography.displayFont, 32, FontWeight.w800),
      displayMedium: _ts(primary, AppTypography.displayFont, 26, FontWeight.w700),
      displaySmall:  _ts(primary, AppTypography.displayFont, 22, FontWeight.w700),
      // headline
      headlineLarge:  _ts(primary, AppTypography.displayFont, 19, FontWeight.w700),
      headlineMedium: _ts(primary, AppTypography.displayFont, 17, FontWeight.w700),
      headlineSmall:  _ts(primary, AppTypography.displayFont, 15, FontWeight.w600),
      // title
      titleLarge:  _ts(primary, AppTypography.displayFont, 15, FontWeight.w700),
      titleMedium: _ts(primary, AppTypography.displayFont, 13, FontWeight.w600),
      titleSmall:  _ts(primary, AppTypography.displayFont, 12, FontWeight.w600),
      // body
      bodyLarge:   _ts(primary, AppTypography.bodyFont, 14, FontWeight.w400),
      bodyMedium:  _ts(muted,   AppTypography.bodyFont, 12, FontWeight.w400),
      bodySmall:   _ts(muted,   AppTypography.bodyFont, 11, FontWeight.w400),
      // label
      labelLarge:  _ts(primary, AppTypography.displayFont, 11, FontWeight.w700,
          letterSpacing: 1.5),
      labelMedium: _ts(muted,   AppTypography.displayFont, 10, FontWeight.w600,
          letterSpacing: 1.2),
      labelSmall:  _ts(muted,   AppTypography.bodyFont,    10, FontWeight.w400,
          letterSpacing: 0.5),
    );
  }

  static TextStyle _ts(
    Color color,
    String family,
    double size,
    FontWeight weight, {
    double letterSpacing = 0,
  }) =>
      TextStyle(
        color: color,
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );

  // ── Convenience getters ───────────────────────────────────────────────────
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(AppColors.lime), Color(AppColors.teal)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get subtleGradient => const LinearGradient(
        colors: [Color(0xFF0E1A0A), Color(0xFF101510)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // kept for backward compat (app_scaffold references this)
  static LinearGradient get primaryGradient_gradient => primaryGradient;
}

// ignore: non_constant_identifier_names
LinearGradient AppTheme_gradient = AppTheme.primaryGradient;

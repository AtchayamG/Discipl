import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TC — Theme Colors
/// Single source of truth for every color used in the UI.
/// Dark-first design; light mode maps every token to a polished equivalent.
/// ─────────────────────────────────────────────────────────────────────────────
class TC {
  final bool isDark;
  const TC._(this.isDark);
  static TC of(BuildContext context) =>
      TC._(Theme.of(context).brightness == Brightness.dark);

  // ── Page / scaffold backgrounds ─────────────────────────────────────────────
  Color get pageBg    => isDark ? const Color(AppColors.bg)       : const Color(AppColors.lightBg);
  Color get pageBg2   => isDark ? const Color(AppColors.bg2)      : const Color(AppColors.lightBg2);

  // ── Card / surface backgrounds ───────────────────────────────────────────────
  Color get cardBg    => isDark ? const Color(AppColors.bg2)      : const Color(AppColors.lightCard);
  Color get cardBg2   => isDark ? const Color(AppColors.bg3)      : const Color(AppColors.lightCard2);
  Color get cardBg3   => isDark ? const Color(AppColors.surface)  : const Color(AppColors.lightBg3);
  Color get surfaceBg => isDark ? const Color(AppColors.surface)  : const Color(AppColors.surfaceLight);
  Color get inputBg   => isDark ? const Color(AppColors.bg3)      : const Color(AppColors.lightCard2);
  Color get modalBg   => isDark ? const Color(AppColors.bg2)      : const Color(AppColors.lightCard);
  Color get chipBg    => isDark ? const Color(AppColors.bg3)      : const Color(AppColors.lightSurface2);
  Color get sectionBg => isDark ? const Color(AppColors.bg3)      : const Color(AppColors.lightBg2);

  // ── Borders ──────────────────────────────────────────────────────────────────
  Color get border    => isDark ? const Color(AppColors.border)   : const Color(AppColors.lightBorder);
  Color get border2   => isDark ? const Color(AppColors.border2)  : const Color(AppColors.lightBorder2);

  // ── Text ─────────────────────────────────────────────────────────────────────
  Color get textPrimary   => isDark ? const Color(AppColors.textPrimary) : const Color(AppColors.textLight);
  Color get textSecondary => isDark ? const Color(AppColors.textMuted)   : const Color(AppColors.textLight2);
  Color get textMuted     => isDark ? const Color(AppColors.textMuted)   : const Color(AppColors.mutedLight);
  Color get textMuted2    => isDark ? const Color(AppColors.textMuted2)  : const Color(AppColors.mutedLight2);
  // On-surface: text that should appear on lime-colored backgrounds
  Color get textOnLime    => isDark ? const Color(AppColors.bg)          : Colors.white;

  // ── Brand / Lime ─────────────────────────────────────────────────────────────
  Color get lime           => isDark ? const Color(AppColors.lime)            : const Color(AppColors.limeLight);
  Color get limeText       => isDark ? const Color(AppColors.lime)            : const Color(AppColors.limeLightText);
  Color get limeBg         => isDark ? const Color(AppColors.limeAlpha12)     : const Color(AppColors.limeLightBg);
  Color get limeBg2        => isDark ? const Color(AppColors.limeAlpha20)     : const Color(0xFFE3F5A0);
  Color get limeBorder     => isDark ? const Color(AppColors.limeAlpha20)     : const Color(AppColors.limeLightBorder);
  Color get limeIcon       => isDark ? const Color(AppColors.lime)            : const Color(AppColors.limeLightDark);

  // ── Semantic accents ─────────────────────────────────────────────────────────
  Color get teal    => isDark ? const Color(AppColors.teal)   : const Color(AppColors.tealLight);
  Color get orange  => isDark ? const Color(AppColors.orange) : const Color(AppColors.orangeLight);
  Color get violet  => isDark ? const Color(AppColors.violet) : const Color(AppColors.violetLight);
  Color get red     => const Color(AppColors.red);

  // Accent: maps a raw vivid accent to its appropriate shade for this theme
  Color accentFor(Color raw) {
    if (!isDark) {
      if (raw == const Color(AppColors.lime))   return const Color(AppColors.limeLightDark);
      if (raw == const Color(AppColors.teal))   return const Color(AppColors.tealLight);
      if (raw == const Color(AppColors.orange)) return const Color(AppColors.orangeLight);
      if (raw == const Color(AppColors.violet)) return const Color(AppColors.violetLight);
    }
    return raw;
  }

  // ── Navigation ───────────────────────────────────────────────────────────────
  Color get navBg    => isDark ? const Color(AppColors.bg2)  : const Color(AppColors.lightCard);
  Color get railBg   => isDark ? const Color(AppColors.bg2)  : const Color(AppColors.lightCard);
  Color get topBarBg => isDark ? const Color(AppColors.bg)   : const Color(AppColors.lightCard);

  // ── Misc ─────────────────────────────────────────────────────────────────────
  Color get divider       => isDark ? const Color(AppColors.border)  : const Color(AppColors.lightBorder);
  Color get progressTrack => isDark ? const Color(AppColors.surface) : const Color(AppColors.lightBg2);
  Color get checkFg       => isDark ? const Color(AppColors.bg)      : Colors.white;
  Color get iconBg        => isDark ? const Color(AppColors.surface) : const Color(AppColors.lightBg2);

  // Bottom sheet handle
  Color get handleColor => isDark ? const Color(AppColors.border2) : const Color(AppColors.lightBorder2);

  // ── Shadow helpers ───────────────────────────────────────────────────────────
  List<BoxShadow> get cardShadow => isDark
      ? []
      : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8,  offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2,  offset: const Offset(0, 1)),
        ];

  List<BoxShadow> get elevatedShadow => isDark
      ? []
      : [
          BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4,  offset: const Offset(0, 1)),
        ];

  List<BoxShadow> get floatingShadow => isDark
      ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8))]
      : [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8,  offset: const Offset(0, 2)),
        ];

  List<BoxShadow> limeShadow(Color accent) => isDark
      ? [BoxShadow(color: accent.withOpacity(0.25), blurRadius: 6)]
      : [BoxShadow(color: accent.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 2))];
}

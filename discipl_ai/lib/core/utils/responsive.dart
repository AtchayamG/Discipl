import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Responsive — layout helpers (logic unchanged, kept for backward compat)
/// ─────────────────────────────────────────────────────────────────────────────
class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppSizes.mobileBreak;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= AppSizes.mobileBreak && w < AppSizes.desktopBreak;
  }

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppSizes.desktopBreak;

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isWide(context)) return desktop;
    if (isTablet(context)) return tablet ?? desktop;
    return mobile;
  }

  static int statGridColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= AppSizes.desktopBreak) return 4;
    if (w >= AppSizes.tabletBreak) return 3;
    if (w >= AppSizes.mobileBreak) return 2;
    return 2;
  }
}

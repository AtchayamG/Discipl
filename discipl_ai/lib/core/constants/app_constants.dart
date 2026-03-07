/// ─────────────────────────────────────────────────────────────────────────────
/// Discipl.AI — App Constants
/// Single source of truth for API endpoints, colors, sizes.
/// Change colors/typography HERE and it propagates to the entire app.
/// ─────────────────────────────────────────────────────────────────────────────

class ApiConstants {
  ApiConstants._();
  // ★ Change 'MOCK' to your real backend URL e.g. 'https://api.discipl.ai/v1'
  static const String baseUrl = 'MOCK';
  static const String dashboard = '/dashboard';
  static const String habits = '/habits';
  static const String workouts = '/workouts';
  static const String progressPhotos = '/progress-photos';
  static const String communityFeed = '/community/feed';
  static const String challenges = '/challenges';
  static const String leaderboard = '/leaderboard';
  static const String aiInsights = '/ai/insights';
  static const String analytics = '/analytics';
  static const String user = '/user/profile';
  static const String signIn  = '/auth/signin';
  static const String signUp  = '/auth/signup';
  static const String signOut = '/auth/signout';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// ─── Brand Color Palette ──────────────────────────────────────────────────────
/// To change the entire app theme: update these hex values.
/// Primary brand:  Lime Green  #C8F135
/// Accent:         Teal        #3DD6C8
/// Warning:        Orange      #FF7A3D
/// Info:           Violet      #9D7FEA
/// Error:          Red         #FF4560
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Dark background layers ──────────────────────────────────────────────────
  static const int bg      = 0xFF07090D; // deepest bg
  static const int bg2     = 0xFF0D1117; // card bg
  static const int bg3     = 0xFF141A22; // elevated card
  static const int surface = 0xFF1C2433; // highest surface

  // ── Border / Divider ────────────────────────────────────────────────────────
  static const int border  = 0x12FFFFFF; // 7% white
  static const int border2 = 0x21FFFFFF; // 13% white

  // ── Brand / Primary ─────────────────────────────────────────────────────────
  static const int lime    = 0xFFC8F135; // electric lime  ← PRIMARY
  static const int limeAlpha12 = 0x1FC8F135;
  static const int limeAlpha20 = 0x33C8F135;
  static const int limeAlpha30 = 0x4DC8F135;

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const int teal    = 0xFF3DD6C8;
  static const int orange  = 0xFFFF7A3D;
  static const int violet  = 0xFF9D7FEA;
  static const int red     = 0xFFFF4560;

  // ── Text ────────────────────────────────────────────────────────────────────
  static const int textPrimary = 0xFFEEF0F4;
  static const int textMuted   = 0xFF8B95A5;
  static const int textMuted2  = 0xFF5A6478;

  // ── Legacy aliases (kept for backward compat with existing screens) ──────────
  static const int darkBg     = bg;
  static const int darkBg2    = bg2;
  static const int darkCard   = bg3;
  static const int darkBorder = border;
  static const int purple     = lime;   // remapped → lime for new theme
  static const int purple2    = lime;
  static const int accent     = teal;
  static const int green      = lime;
  static const int yellow     = orange;
  static const int textDark   = textPrimary;
  static const int mutedDark  = textMuted;
  static const int lightBg    = 0xFFF5F7FA; // page background — cool light grey
  static const int lightBg2   = 0xFFEDF0F5; // secondary bg — slightly deeper
  static const int lightCard  = 0xFFFFFFFF; // card surface — pure white
  static const int lightCard2 = 0xFFF8FAFC; // elevated card — near white
  static const int lightBorder = 0xFFDDE3EC; // subtle border
  static const int lightBorder2 = 0xFFC8D0DC; // stronger border
  static const int textLight  = 0xFF0D1B2A; // primary text — near black
  static const int textLight2 = 0xFF2D3F54; // secondary text — dark slate
  static const int mutedLight = 0xFF64748B; // muted text — slate
  static const int mutedLight2 = 0xFF94A3B8; // dimmer muted
  static const int limeLight  = 0xFF5A8A00; // lime darkened for light bg readability
  static const int limeLightBg = 0xFFEEF9CC; // lime tint bg on light
  static const int limeLightBorder = 0xFFBFE34A; // lime border on light
  static const int surfaceLight = 0xFFEEF2F7; // input / surface
  static const int lightBg3   = 0xFFE8EEF5; // deepest light surface
  static const int lightSurface2 = 0xFFF0F4F8; // chip / subtle surface
  static const int limeLightDark = 0xFF4A7200; // darkest lime for light icons
  static const int limeLightText = 0xFF3D6B00; // lime for text on white
  static const int tealLight  = 0xFF0F8C82; // teal darkened for light
  static const int orangeLight = 0xFFD45A00; // orange darkened for light
  static const int violetLight = 0xFF6B4EC9; // violet darkened for light
}

/// ─── Spacing / Radius ────────────────────────────────────────────────────────
class AppSizes {
  AppSizes._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  static const double railCollapsed = 68.0;
  static const double railExpanded  = 220.0;
  static const double navbarHeight  = 52.0;

  // breakpoints
  static const double mobileBreak  = 600.0;
  static const double tabletBreak  = 900.0;
  static const double desktopBreak = 1200.0;

  // legacy
  static const double sidebarWidth = railExpanded;
}

/// ─── Typography tokens ───────────────────────────────────────────────────────
/// Change font families here → applies everywhere
class AppTypography {
  AppTypography._();
  static const String displayFont = 'Poppins';  // headings, labels, brand
  static const String bodyFont    = 'Inter';    // body text, captions
}

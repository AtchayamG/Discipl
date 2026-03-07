# Discipl.AI — UI Redesign Files

## What changed

| Old (purple design) | New (lime/dark design) |
|---|---|
| `lib/core/constants/app_constants.dart` | `lib/core/constants/app_constants.dart` ✦ |
| `lib/core/utils/app_theme.dart` | `lib/core/theme/app_theme.dart` ✦ |
| `lib/core/utils/responsive.dart` | `lib/core/utils/responsive.dart` (no change) |
| `lib/presentation/widgets/common/app_scaffold.dart` | `lib/presentation/widgets/layout/app_scaffold.dart` ✦ |
| `lib/presentation/widgets/common/common_widgets.dart` | `lib/presentation/widgets/common/common_widgets.dart` ✦ |
| `lib/main.dart` | `lib/main.dart` ✦ |
| `lib/presentation/screens/auth/signin_screen.dart` | `lib/presentation/screens/auth/signin_screen.dart` ✦ |
| `lib/presentation/screens/main_shell.dart` | `lib/presentation/screens/main_shell.dart` ✦ |
| `lib/presentation/screens/dashboard/dashboard_screen.dart` | ✦ |
| `lib/presentation/screens/habits/habits_screen.dart` | ✦ |
| `lib/presentation/screens/workouts/workouts_screen.dart` | ✦ |
| `lib/presentation/screens/community/community_screen.dart` | ✦ |
| `lib/presentation/screens/settings/settings_screen.dart` | ✦ |
| All other screens | Unchanged (copied as-is) |

✦ = redesigned file

## How to apply

### Step 1 — Copy files into your project
Replace each file in your project with the corresponding file from this package.

### Step 2 — Add app_theme.dart alias in old location
If any old file still imports `lib/core/utils/app_theme.dart`, create a redirect:

```dart
// lib/core/utils/app_theme.dart  (stub for backward compat)
export '../theme/app_theme.dart';
```

### Step 3 — Add Poppins + Inter fonts
See `PUBSPEC_PATCH.yaml` — add `google_fonts: ^6.2.1` to dependencies,
then update `main.dart` to call `GoogleFonts.asMap()` or use local font files.

**Quickest approach (google_fonts package):**
```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.2.1
```

Then in `main()`:
```dart
import 'package:google_fonts/google_fonts.dart';
// No other changes needed — AppTypography constants match Google Fonts names
```

### Step 4 — Add app_icon.png
Ensure `assets/images/app_icon.png` exists (your green D logo).
The icon is referenced in: SplashScreen, SignInScreen, AppScaffold.

### Step 5 — Run
```bash
flutter pub get
flutter run
```

---

## Design System — How to Customize

All visual tokens live in **one file**:
`lib/core/constants/app_constants.dart`

### Change primary color (currently Electric Lime)
```dart
// AppColors in app_constants.dart
static const int lime = 0xFFC8F135;  // ← change this hex
```
This propagates to: buttons, active nav, progress rings, pills, streaks — everything.

### Change fonts (currently Poppins + Inter)
```dart
// AppTypography in app_constants.dart
static const String displayFont = 'Poppins';  // headings
static const String bodyFont    = 'Inter';    // body text
```

### Change spacing / radius
```dart
// AppSizes in app_constants.dart
static const double radiusLg = 16.0;  // card corners
```

---

## Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart    ← SINGLE source of truth for all tokens
│   ├── theme/
│   │   └── app_theme.dart        ← ThemeData builder (uses constants)
│   └── utils/
│       └── responsive.dart       ← Layout helpers (unchanged)
├── providers/
│   └── app_provider.dart         ← Business logic (unchanged)
├── core/services/
│   └── api_service.dart          ← API (unchanged)
└── presentation/
    ├── widgets/
    │   ├── layout/
    │   │   └── app_scaffold.dart ← Root layout: rail (web) / bottom nav (mobile)
    │   └── common/
    │       └── common_widgets.dart ← Design system components
    └── screens/
        ├── auth/signin_screen.dart
        ├── main_shell.dart
        ├── dashboard/
        ├── habits/
        ├── workouts/
        ├── community/
        ├── settings/
        └── ... (all other screens)
```

## State management
Provider (unchanged) — AppProvider handles all state.
No new state management layer added.
The UI is purely reactive to AppProvider.

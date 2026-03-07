import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/language_provider.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});
  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _railExpanded = false;
  void _toggleRail() => setState(() => _railExpanded = !_railExpanded);

  @override
  Widget build(BuildContext context) {
    if (Responsive.isWide(context)) {
      return _DesktopLayout(railExpanded: _railExpanded, onToggleRail: _toggleRail, child: widget.child);
    }
    return _MobileLayout(child: widget.child);
  }
}

// ─── Desktop ──────────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final bool railExpanded;
  final VoidCallback onToggleRail;
  final Widget child;
  const _DesktopLayout({required this.railExpanded, required this.onToggleRail, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(children: [
        _TopBar(railExpanded: railExpanded),
        Expanded(child: Row(children: [
          _Rail(expanded: railExpanded, onToggle: onToggleRail),
          Expanded(child: Container(color: Theme.of(context).scaffoldBackgroundColor, child: child)),
        ])),
      ]),
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: _BottomNav(provider: provider),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool railExpanded;
  const _TopBar({required this.railExpanded});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final provider = context.watch<AppProvider>();
    return Container(
      height: AppSizes.navbarHeight,
      decoration: BoxDecoration(
        color: tc.topBarBg,
        border: Border(bottom: BorderSide(color: tc.border)),
        boxShadow: tc.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        SizedBox(
          width: railExpanded ? AppSizes.railExpanded - 16 : AppSizes.railCollapsed - 16,
          child: Row(children: [
            _AppIconBox(size: 28, radius: 7),
            if (railExpanded) ...[
              const SizedBox(width: 10),
              RichText(text: TextSpan(children: [
                TextSpan(text: 'Discipl', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 15, fontWeight: FontWeight.w800, color: tc.textPrimary)),
                TextSpan(text: '.AI', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 15, fontWeight: FontWeight.w800, color: const Color(AppColors.lime))),
              ])),
            ],
          ]),
        ),
        const Spacer(),
        _IconBtn(icon: Icons.notifications_outlined, badge: 3, onTap: () {}),
        const SizedBox(width: 6),
        _IconBtn(icon: Icons.search_rounded, onTap: () {}),
        const SizedBox(width: 6),
        _IconBtn(
          icon: provider.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          onTap: provider.toggleTheme,
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => provider.navigate(9),
          child: _AppIconBox(size: 32, radius: 50, isAvatar: true),
        ),
      ]),
    );
  }
}

// ─── Collapsible rail ─────────────────────────────────────────────────────────
class _Rail extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  const _Rail({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final provider = context.watch<AppProvider>();
    final w = expanded ? AppSizes.railExpanded : AppSizes.railCollapsed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      width: w,
      decoration: BoxDecoration(
        color: tc.railBg,
        border: Border(right: BorderSide(color: tc.border)),
        boxShadow: tc.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        Column(children: [
          const SizedBox(height: 16),
          ..._navItems.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            return _RailItem(item: item, isActive: provider.selectedIndex == idx, expanded: expanded, onTap: () => provider.navigate(idx));
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 16),
            child: Row(children: [
              _AppIconBox(size: 34, radius: 50, isAvatar: true),
              if (expanded) ...[
                const SizedBox(width: 9),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Demo User', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700, color: tc.textPrimary), overflow: TextOverflow.ellipsis),
                  Text('Score: 847', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: tc.textMuted)),
                ])),
              ],
            ]),
          ),
        ]),
        // Toggle button
        Positioned(
          top: 16, right: -13,
          child: GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: tc.cardBg2,
                shape: BoxShape.circle,
                border: Border.all(color: tc.border2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(tc.isDark ? 0.5 : 0.12), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Center(child: Text(expanded ? '‹' : '›', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w800, color: tc.textMuted, height: 1))),
            ),
          ),
        ),
      ]),
    );
  }
}

class _RailItem extends StatelessWidget {
  final _NavItemData item;
  final bool isActive, expanded;
  final VoidCallback onTap;
  const _RailItem({required this.item, required this.isActive, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final limeColor = tc.isDark ? const Color(AppColors.lime) : const Color(AppColors.limeLight);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        margin: const EdgeInsets.symmetric(vertical: 1),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            margin: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: isActive ? tc.limeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Stack(children: [
              Center(child: Icon(item.icon, size: 18, color: isActive ? limeColor : tc.textMuted)),
              if (isActive)
                Positioned(left: 0, top: 10, bottom: 10,
                  child: Container(width: 3, decoration: BoxDecoration(color: limeColor, borderRadius: BorderRadius.circular(2)))),
            ]),
          ),
          if (expanded)
            Expanded(child: Text(item.label, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w600,
              color: isActive ? limeColor : tc.textMuted), overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

// ─── Bottom nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final AppProvider provider;
  const _BottomNav({required this.provider});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final lp = context.watch<LanguageProvider>();
    final limeColor = tc.isDark ? const Color(AppColors.lime) : const Color(AppColors.limeLight);

    // Translated labels for the 5 bottom nav tabs
    final tabLabels = [lp.dashboard, lp.habits, lp.workouts, lp.community, lp.profile];

    return Container(
      decoration: BoxDecoration(
        color: tc.navBg,
        border: Border(top: BorderSide(color: tc.border)),
        boxShadow: tc.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: _mobileNavItems.asMap().entries.map((e) {
              final navPos = e.key;
              final screenIdx = _mobileNavScreenIndex[navPos];
              final item = e.value;
              final isActive = _activeNavTabFor(provider.selectedIndex) == screenIdx;
              final label = navPos < tabLabels.length ? tabLabels[navPos] : item.label;
              return Expanded(
                child: GestureDetector(
                  onTap: () => provider.navigate(screenIdx),
                  behavior: HitTestBehavior.opaque,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(item.icon, size: 22, color: isActive ? limeColor : tc.textMuted),
                    const SizedBox(height: 3),
                    Text(label, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 9, fontWeight: FontWeight.w600,
                      color: isActive ? limeColor : tc.textMuted)),
                    if (isActive)
                      Container(margin: const EdgeInsets.only(top: 3), width: 4, height: 4,
                        decoration: BoxDecoration(color: limeColor, shape: BoxShape.circle)),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Icon button ──────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final int? badge;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: tc.cardBg2,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(color: tc.border),
          boxShadow: tc.cardShadow,
        ),
        child: Stack(children: [
          Center(child: Icon(icon, size: 16, color: tc.textMuted)),
          if (badge != null)
            Positioned(right: 4, top: 4, child: Container(
              width: 14, height: 14,
              decoration: const BoxDecoration(color: Color(AppColors.red), shape: BoxShape.circle),
              child: Center(child: Text('$badge', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, height: 1))),
            )),
        ]),
      ),
    );
  }
}

// ─── App icon box ─────────────────────────────────────────────────────────────
class _AppIconBox extends StatelessWidget {
  final double size, radius;
  final bool isAvatar;
  const _AppIconBox({required this.size, required this.radius, this.isAvatar = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(AppColors.limeAlpha30), width: isAvatar ? 1.5 : 1),
        boxShadow: [BoxShadow(color: const Color(AppColors.lime).withOpacity(0.15), blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover, width: size, height: size,
          errorBuilder: (_, __, ___) => Center(child: Text('D',
            style: TextStyle(fontFamily: AppTypography.displayFont, fontWeight: FontWeight.w900, fontSize: size * 0.5, color: const Color(AppColors.lime))))),
      ),
    );
  }
}

// ─── Nav data ─────────────────────────────────────────────────────────────────
class _NavItemData {
  final String label;
  final IconData icon;
  const _NavItemData(this.label, this.icon);
}

const _navItems = [
  _NavItemData('Dashboard',   Icons.grid_view_rounded),
  _NavItemData('Habits',      Icons.check_circle_outline_rounded),
  _NavItemData('Workouts',    Icons.show_chart_rounded),
  _NavItemData('Photos',      Icons.photo_camera_outlined),
  _NavItemData('Community',   Icons.people_outline_rounded),
  _NavItemData('Challenges',  Icons.emoji_events_outlined),
  _NavItemData('Leaderboard', Icons.leaderboard_rounded),
  _NavItemData('AI Insights', Icons.auto_awesome_outlined),
  _NavItemData('Analytics',   Icons.analytics_outlined),
  _NavItemData('Settings',    Icons.settings_outlined),
];

const _mobileNavItems = [
  _NavItemData('Home',      Icons.grid_view_rounded),
  _NavItemData('Habits',    Icons.check_circle_outline_rounded),
  _NavItemData('Workouts',  Icons.show_chart_rounded),
  _NavItemData('Community', Icons.people_outline_rounded),
  _NavItemData('Profile',   Icons.settings_outlined),
];

const _mobileNavScreenIndex = [0, 1, 2, 4, 9];

int _activeNavTabFor(int screenIdx) {
  if (screenIdx == 10) return 1;
  if (screenIdx == 11) return 2;
  return screenIdx;
}

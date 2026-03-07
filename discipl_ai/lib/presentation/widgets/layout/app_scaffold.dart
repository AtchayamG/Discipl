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
        _SearchBtn(),
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
// Uses SizedBox (not AnimatedContainer with decoration) so width is a hard
// layout constraint — children physically cannot overflow it.
class _Rail extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  const _Rail({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final provider = context.watch<AppProvider>();
    final w = expanded ? AppSizes.railExpanded : AppSizes.railCollapsed;

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      child: SizedBox(
        width: w,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tc.railBg,
            border: Border(right: BorderSide(color: tc.border)),
            boxShadow: tc.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Toggle button ────────────────────────────────────────────
              InkWell(
                onTap: onToggle,
                child: SizedBox(
                  height: 48,
                  width: w,
                  child: Row(children: [
                    if (expanded) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('MENU',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFont,
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: tc.textMuted, letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: const Color(AppColors.lime).withOpacity(0.13),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(AppColors.lime).withOpacity(0.45)),
                        ),
                        child: Icon(
                          expanded
                            ? Icons.keyboard_double_arrow_left_rounded
                            : Icons.keyboard_double_arrow_right_rounded,
                          size: 17,
                          color: const Color(AppColors.lime),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),

              // ── Nav items ───────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _navItems.length,
                  itemBuilder: (_, idx) => _RailItem(
                    item: _navItems[idx],
                    isActive: provider.selectedIndex == idx,
                    expanded: expanded,
                    onTap: () => provider.navigate(idx),
                  ),
                ),
              ),

              // ── Bottom user row ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 0, 13, 16),
                child: Row(children: [
                  _AppIconBox(size: 34, radius: 50, isAvatar: true),
                  if (expanded) ...[
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Demo User',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700, color: tc.textPrimary)),
                        Text('Score: 847',
                          style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: tc.textMuted)),
                      ]),
                    ),
                  ],
                ]),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

// ─── Rail item ────────────────────────────────────────────────────────────────
class _RailItem extends StatelessWidget {
  final _NavItemData item;
  final bool isActive, expanded;
  final VoidCallback onTap;
  const _RailItem({required this.item, required this.isActive, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final lime = tc.isDark ? const Color(AppColors.lime) : const Color(AppColors.limeLight);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Row(children: [
          // Icon box — always 68px total (13 + 42 + 13)
          Container(
            width: 42, height: 42,
            margin: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: isActive ? tc.limeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Stack(children: [
              Center(child: Icon(item.icon, size: 18, color: isActive ? lime : tc.textMuted)),
              if (isActive)
                Positioned(left: 0, top: 10, bottom: 10,
                  child: Container(width: 3,
                    decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(2)))),
            ]),
          ),
          // Label — only when expanded, Expanded widget fills remaining space
          if (expanded)
            Expanded(
              child: Text(item.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13,
                  fontWeight: FontWeight.w600, color: isActive ? lime : tc.textMuted)),
            ),
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
    final lime = tc.isDark ? const Color(AppColors.lime) : const Color(AppColors.limeLight);
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
                    Icon(item.icon, size: 22, color: isActive ? lime : tc.textMuted),
                    const SizedBox(height: 3),
                    Text(label, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 9,
                      fontWeight: FontWeight.w600, color: isActive ? lime : tc.textMuted)),
                    if (isActive)
                      Container(margin: const EdgeInsets.only(top: 3), width: 4, height: 4,
                        decoration: BoxDecoration(color: lime, shape: BoxShape.circle)),
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

// ─── Search button with overlay ──────────────────────────────────────────────
class _SearchBtn extends StatefulWidget {
  const _SearchBtn();
  @override
  State<_SearchBtn> createState() => _SearchBtnState();
}

class _SearchBtnState extends State<_SearchBtn> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;

  static const _pages = [
    {'label': 'Dashboard',   'icon': Icons.grid_view_rounded,          'index': 0},
    {'label': 'Habits',      'icon': Icons.check_circle_outline_rounded,'index': 1},
    {'label': 'Workouts',    'icon': Icons.show_chart_rounded,          'index': 2},
    {'label': 'Photos',      'icon': Icons.photo_camera_outlined,       'index': 3},
    {'label': 'Community',   'icon': Icons.people_outline_rounded,      'index': 4},
    {'label': 'Challenges',  'icon': Icons.emoji_events_outlined,       'index': 5},
    {'label': 'Leaderboard', 'icon': Icons.leaderboard_rounded,         'index': 6},
    {'label': 'AI Insights', 'icon': Icons.auto_awesome_outlined,       'index': 7},
    {'label': 'Analytics',   'icon': Icons.analytics_outlined,          'index': 8},
    {'label': 'Settings',    'icon': Icons.settings_outlined,           'index': 9},
  ];

  String _query = '';

  List<Map<String, Object>> get _results {
    if (_query.trim().isEmpty) return List<Map<String, Object>>.from(_pages);
    final q = _query.toLowerCase();
    return _pages
        .where((p) => (p['label'] as String).toLowerCase().contains(q))
        .map((p) => Map<String, Object>.from(p))
        .toList();
  }

  void _openOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(builder: (ctx) => _SearchOverlay(
      link: _layerLink,
      ctrl: _ctrl,
      focus: _focus,
      results: _results,
      query: _query,
      onQueryChanged: (v) {
        setState(() => _query = v);
        _overlay?.markNeedsBuild();
      },
      onSelect: (idx) {
        _close();
        context.read<AppProvider>().navigate(idx);
      },
      onDismiss: _close,
    ));
    overlay.insert(_overlay!);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _close() {
    _ctrl.clear();
    _query = '';
    _focus.unfocus();
    _removeOverlay();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _removeOverlay();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _openOverlay,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: tc.cardBg2,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: tc.border),
            boxShadow: tc.cardShadow,
          ),
          child: const Center(child: Icon(Icons.search_rounded, size: 16, color: Color(AppColors.textMuted))),
        ),
      ),
    );
  }
}

class _SearchOverlay extends StatelessWidget {
  final LayerLink link;
  final TextEditingController ctrl;
  final FocusNode focus;
  final List<Map<String, Object>> results;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int> onSelect;
  final VoidCallback onDismiss;

  const _SearchOverlay({
    required this.link,
    required this.ctrl,
    required this.focus,
    required this.results,
    required this.query,
    required this.onQueryChanged,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return Stack(children: [
      // Tap-outside to dismiss
      Positioned.fill(
        child: GestureDetector(
          onTap: onDismiss,
          behavior: HitTestBehavior.translucent,
          child: const SizedBox.expand(),
        ),
      ),
      // Search panel anchored below the button
      CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: const Offset(-266, 42), // align right edge, drop below button
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: tc.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tc.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(children: [
                  const Icon(Icons.search_rounded, size: 16, color: Color(AppColors.textMuted)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      focusNode: focus,
                      onChanged: onQueryChanged,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 13, color: tc.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search pages...',
                        hintStyle: TextStyle(color: tc.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onDismiss,
                    child: Icon(Icons.close_rounded, size: 14, color: tc.textMuted),
                  ),
                ]),
              ),
              Divider(height: 1, color: tc.border),
              // Results
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No results for "$query"',
                    style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: tc.textMuted)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final item = results[i];
                      final label = item['label'] as String;
                      final icon  = item['icon']  as IconData;
                      final idx   = item['index'] as int;
                      final isMatch = query.isNotEmpty &&
                          label.toLowerCase().contains(query.toLowerCase());
                      return InkWell(
                        onTap: () => onSelect(idx),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Row(children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: isMatch
                                    ? const Color(AppColors.lime).withOpacity(0.12)
                                    : tc.cardBg2,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isMatch
                                      ? const Color(AppColors.lime).withOpacity(0.35)
                                      : tc.border),
                              ),
                              child: Icon(icon, size: 15,
                                color: isMatch
                                    ? const Color(AppColors.lime)
                                    : tc.textMuted),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(label,
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFont,
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: isMatch ? const Color(AppColors.lime) : tc.textPrimary)),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: tc.textMuted),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 4),
            ]),
          ),
        ),
      ),
    ]);
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
            Positioned(right: 4, top: 4,
              child: Container(
                width: 14, height: 14,
                decoration: const BoxDecoration(color: Color(AppColors.red), shape: BoxShape.circle),
                child: Center(child: Text('$badge',
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, height: 1))),
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
            style: TextStyle(fontFamily: AppTypography.displayFont, fontWeight: FontWeight.w900,
              fontSize: size * 0.5, color: const Color(AppColors.lime))))),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);
    return Scaffold(
      body: SafeArea(
        // Only protect top for status bar.
        // Bottom is handled by padding on each scrollable screen
        // so the system nav bar never overlaps content.
        bottom: false,
        child: Column(children: [
          _Navbar(),
          Expanded(
            child: isWide
                ? Row(children: [
                    _Sidebar(),
                    Expanded(child: child),
                  ])
                : MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    // Add bottom padding equal to system nav bar height
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      child: child,
                    ),
                  ),
          ),
        ]),
      ),
      drawer: isWide ? null : _DrawerSidebar(),
    );
  }
}

// ─── Navbar ──────────────────────────────────────────────────────────────────
class _Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.themeMode == ThemeMode.dark;
    final purple = Color(AppColors.purple);

    return Container(
      height: AppSizes.navbarHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.purple).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        if (!Responsive.isWide(context))
          Builder(
              builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  )),
        // Logo
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme_gradient.createShader(bounds),
          child: const Text(
            'Discipl.ai',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
        ),
        const Spacer(),
        // Nav links (wide only)
        if (Responsive.isWide(context)) ...[
          _NavLink('Dashboard', 0, provider),
          _NavLink('Challenges', 5, provider),
          _NavLink('Analytics', 8, provider),
          _NavLink('Community', 4, provider),
          const SizedBox(width: 16),
        ],
        // Theme toggle
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          color: Color(AppColors.mutedDark),
          onPressed: provider.toggleTheme,
          tooltip: isDark ? 'Light mode' : 'Dark mode',
        ),
        // Notification bell
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Color(AppColors.red),
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(AppColors.darkBg2), width: 2),
                ),
                child: const Center(
                  child: Text('3',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
        // Settings
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => provider.navigate(9),
        ),
        // Avatar
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => provider.navigate(9),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(AppColors.purple), Color(AppColors.accent)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                    (provider.currentUser?['avatarInitials'] as String?) ?? 'U',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class AppTheme_gradient {
  static LinearGradient get gradient => LinearGradient(
        colors: [Color(AppColors.purple), Color(AppColors.accent)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
  static Shader createShader(Rect bounds) =>
      gradient.createShader(bounds);
}

class _NavLink extends StatelessWidget {
  final String label;
  final int index;
  final AppProvider provider;
  const _NavLink(this.label, this.index, this.provider);

  @override
  Widget build(BuildContext context) {
    final active = provider.selectedIndex == index;
    return GestureDetector(
      onTap: () => provider.navigate(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Color(AppColors.purple)
                : Color(AppColors.mutedDark),
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─── Sidebar ─────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(AppColors.darkSidebar)
            : Color(AppColors.lightBg2),
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: _SidebarContent(),
    );
  }
}

class _DrawerSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Color(AppColors.darkSidebar)
          : Color(AppColors.lightBg2),
      child: _SidebarContent(),
    );
  }
}

const _navItems = [
  {'icon': Icons.dashboard_outlined, 'label': 'Dashboard', 'index': 0},
  {'icon': Icons.check_circle_outline, 'label': 'Habits', 'index': 1},
  {'icon': Icons.flash_on_outlined, 'label': 'Workouts', 'index': 2},
  {'icon': Icons.photo_camera_outlined, 'label': 'Progress Photos', 'index': 3},
  {'icon': Icons.people_outline, 'label': 'Community', 'index': 4},
  {'icon': Icons.emoji_events_outlined, 'label': 'Challenges', 'index': 5},
  {'icon': Icons.bar_chart_outlined, 'label': 'Leaderboard', 'index': 6},
  {'icon': Icons.psychology_outlined, 'label': 'AI Insights', 'index': 7},
  {'icon': Icons.analytics_outlined, 'label': 'Analytics', 'index': 8},
  {'icon': Icons.settings_outlined, 'label': 'Settings', 'index': 9},
];

const _sections = [
  {'label': 'Main', 'start': 0, 'end': 3},
  {'label': 'Community', 'start': 4, 'end': 6},
  {'label': 'Insights', 'start': 7, 'end': 9},
];

class _SidebarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final section in _sections) ...[
          _SectionLabel(section['label'] as String),
          const SizedBox(height: 4),
          for (int i = (section['start'] as int);
              i <= (section['end'] as int);
              i++)
            _SidebarItem(
              icon: _navItems[i]['icon'] as IconData,
              label: _navItems[i]['label'] as String,
              index: _navItems[i]['index'] as int,
              selected: provider.selectedIndex == i,
              onTap: () {
                provider.navigate(i);
                if (!Responsive.isWide(context)) {
                  Navigator.of(context).pop();
                }
              },
            ),
          const SizedBox(height: 8),
        ],
        // Streak box
        const SizedBox(height: 8),
        _StreakBox(provider),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 0, 2),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(AppColors.mutedDark),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  const _SidebarItem(
      {required this.icon,
      required this.label,
      required this.index,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [Color(AppColors.purple2), Color(AppColors.purple)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
          color: selected ? null : Colors.transparent,
        ),
        child: Row(children: [
          Icon(icon,
              size: 18,
              color: selected
                  ? Colors.white
                  : Color(AppColors.mutedDark)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Color(AppColors.mutedDark),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StreakBox extends StatelessWidget {
  final AppProvider provider;
  const _StreakBox(this.provider);

  @override
  Widget build(BuildContext context) {
    final user = provider.data['user'] as Map<String, dynamic>?;
    final streak = user?['currentStreak'] ?? 14;

    final userName = (provider.data['user']?['name'] as String? ?? '').split(' ').first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(AppColors.purple2), Color(AppColors.accent)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text('🔥 $streak',
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 2),
        const Text('Day Streak',
            style: TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(userName.isNotEmpty ? 'Keep it up, $userName!' : 'Keep it up!',
            style: const TextStyle(fontSize: 10, color: Colors.white60),
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';
import '../notifications/notifications_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Dashboard Screen — new lime design
/// All data reading from AppProvider is unchanged.
/// ─────────────────────────────────────────────────────────────────────────────
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.isLoading) return const LoadingState();
    if (provider.error != null)
      return ErrorState(message: provider.error!, onRetry: provider.refresh);

    final dash     = provider.data['dashboard'] as Map<String, dynamic>? ?? {};
    final stats    = dash['stats'] as Map<String, dynamic>? ?? {};
    final ds       = dash['disciplineScore'] as Map<String, dynamic>? ?? {};
    final breakdown = ds['breakdown'] as Map<String, dynamic>? ?? {};
    final weekly   = (dash['weeklyActivity'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final habitProgress = (dash['habitProgress'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final lbPreview = (dash['leaderboardPreview'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ────────────────────────────────────────────────────────────
        _GreetingHeader(provider: provider),

        // ── Discipline Score hero ─────────────────────────────────────────────
        _ScoreHero(
          ds: ds,
          stats: stats,
          onViewInsights: () => provider.navigate(7),
        ),

        const SizedBox(height: 14),

        // ── Stat cards ────────────────────────────────────────────────────────
        StatGrid(stats: [
          StatCardData(
            label: 'CURRENT STREAK',
            value: '${stats['currentStreak'] ?? 14}',
            sub: '↑ 2 days vs last week',
            icon: '🔥',
            accentColor: const Color(AppColors.lime),
          ),
          StatCardData(
            label: 'HABITS THIS WEEK',
            value: '${stats['habitsThisWeek'] ?? 87}%',
            sub: '↑ 12% improvement',
            icon: '⚡',
            accentColor: const Color(AppColors.teal),
          ),
          StatCardData(
            label: 'WORKOUTS LOGGED',
            value: '${stats['workoutsLogged'] ?? 5}/${stats['workoutsTarget'] ?? 7}',
            sub: 'On target',
            icon: '💪',
            accentColor: const Color(AppColors.orange),
          ),
          StatCardData(
            label: 'POINTS EARNED',
            value: '${stats['pointsEarned'] ?? 2450}',
            sub: '↑ ${stats['pointsThisWeek'] ?? 340} this week',
            icon: '🏅',
            accentColor: const Color(AppColors.violet),
          ),
        ]),

        const SizedBox(height: 14),

        // ── Activity + AI Insight row ─────────────────────────────────────────
        Responsive.isWide(context)
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _ActivityCard(weekly: weekly)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 300,
                  child: _AIInsightCard(
                    aiPrediction: dash['aiPrediction'] ?? '',
                    provider: provider,
                  ),
                ),
              ])
            : Column(children: [
                _ActivityCard(weekly: weekly),
                const SizedBox(height: 12),
                _AIInsightCard(
                  aiPrediction: dash['aiPrediction'] ?? '',
                  provider: provider,
                ),
              ]),

        const SizedBox(height: 14),

        // ── Habit progress + Leaderboard ─────────────────────────────────────
        Responsive.isWide(context)
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: _HabitProgressCard(
                    habits: habitProgress,
                    provider: provider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LeaderboardCard(
                    lbPreview: lbPreview,
                    provider: provider,
                  ),
                ),
              ])
            : Column(children: [
                _HabitProgressCard(habits: habitProgress, provider: provider),
                const SizedBox(height: 12),
                _LeaderboardCard(lbPreview: lbPreview, provider: provider),
              ]),

        const SizedBox(height: 32),
      ]),
    );
  }
}

// ─── Greeting header ─────────────────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  final AppProvider provider;
  const _GreetingHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    final user = provider.currentUser;
    final name = user?['name'] as String? ?? 'Champ';
    final firstName = name.split(' ').first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Good morning 👋',
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 12,
                color: TC.of(context).textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              firstName,
              style: TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: TC.of(context).textPrimary,
              ),
            ),
          ]),
        ),
        // Streak pill + notification icon
        Row(mainAxisSize: MainAxisSize.min, children: [
          // Notification bell
          Builder(builder: (ctx) {
            final unread = ctx.watch<AppProvider>().unreadCount;
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TC.of(context).cardBg,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: TC.of(context).border),
                ),
                child: Stack(children: [
                  Center(
                    child: Icon(
                      unread > 0
                          ? Icons.notifications_rounded
                          : Icons.notifications_outlined,
                      size: 18,
                      color: unread > 0 ? TC.of(context).lime : TC.of(context).textMuted,
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 5, top: 5,
                      child: Container(
                        width: unread > 9 ? 14 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(AppColors.red),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: unread > 9
                            ? const Center(
                                child: Text('9+',
                                  style: TextStyle(fontSize: 6, fontWeight: FontWeight.w800, color: Colors.white)))
                            : null,
                      ),
                    ),
                ]),
              ),
            );
          }),
          const SizedBox(width: 10),
          // Streak pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TC.of(context).limeBg,
              borderRadius: BorderRadius.circular(AppSizes.xl),
              border: Border.all(color: TC.of(context).limeBorder),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('🔥', style: TextStyle(fontSize: 13)),
              SizedBox(width: 5),
              Text(
                '21 Day Streak',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 11,
                fontWeight: FontWeight.w700,
                color: TC.of(context).lime,
              ),
            ),
          ]),
        ),
        ]), // end Row(notification + streak)
      ]),
    );
  }
}

// ─── Score hero ───────────────────────────────────────────────────────────────
class _ScoreHero extends StatelessWidget {
  final Map<String, dynamic> ds;
  final Map<String, dynamic> stats;
  final VoidCallback onViewInsights;
  const _ScoreHero({
    required this.ds,
    required this.stats,
    required this.onViewInsights,
  });

  @override
  Widget build(BuildContext context) {
    final score = ds['overall'] as int? ?? 847;
    final rank  = ds['rank'] as String? ?? 'Platinum';

    return LimeHeroBanner(
      child: Row(children: [
        ScoreRing(score: score),
        const SizedBox(width: 20),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'DISCIPLINE SCORE',
              style: TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: TC.of(context).lime,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Top 12% of users this week',
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 12,
                color: TC.of(context).textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              DPill('🔥 ${stats['currentStreak'] ?? 21}d Streak'),
              DPill('⭐ $rank', color: const Color(0x1F9D7FEA), textColor: const Color(AppColors.violet)),
              DPill('💧 Hydrated', color: const Color(0x1F3DD6C8), textColor: const Color(AppColors.teal)),
            ]),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onViewInsights,
              child: Text(
                'View AI Insights →',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: TC.of(context).lime,
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Activity card ────────────────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final List<Map<String, dynamic>> weekly;
  const _ActivityCard({required this.weekly});

  @override
  Widget build(BuildContext context) {
    final chartData = weekly.isNotEmpty
        ? weekly
        : [
            {'day': 'Monday', 'value': 65, 'isToday': false},
            {'day': 'Tuesday', 'value': 80, 'isToday': false},
            {'day': 'Wednesday', 'value': 55, 'isToday': false},
            {'day': 'Thursday', 'value': 72, 'isToday': false},
            {'day': 'Friday', 'value': 88, 'isToday': false},
            {'day': 'Saturday', 'value': 30, 'isToday': false},
            {'day': 'Sunday', 'value': 70, 'isToday': true},
          ];

    return DCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader('WEEKLY ACTIVITY'),
        const SizedBox(height: 4),
        WeekBarChart(data: chartData),
      ]),
    );
  }
}

// ─── AI Insight card ──────────────────────────────────────────────────────────
class _AIInsightCard extends StatelessWidget {
  final String aiPrediction;
  final AppProvider provider;
  const _AIInsightCard({required this.aiPrediction, required this.provider});

  @override
  Widget build(BuildContext context) {
    final msg = aiPrediction.isNotEmpty
        ? aiPrediction
        : 'You\'re 3 days away from your longest streak ever! Keep going 🚀';

    return DCard(
      borderColor: const Color(AppColors.limeAlpha20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: TC.of(context).limeBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text('✦', style: TextStyle(fontSize: 14, color: TC.of(context).lime)),
            ),
          ),
          const SizedBox(width: 9),
          Text(
            'AI INSIGHT',
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: TC.of(context).lime,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Text(
          msg,
          style: TextStyle(
            fontFamily: AppTypography.bodyFont,
            fontSize: 13,
            color: TC.of(context).textPrimary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => provider.navigate(7),
          child: Text(
            'More insights →',
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TC.of(context).lime,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Habit progress card ──────────────────────────────────────────────────────
class _HabitProgressCard extends StatefulWidget {
  final List<Map<String, dynamic>> habits;
  final AppProvider provider;
  const _HabitProgressCard({required this.habits, required this.provider});

  @override
  State<_HabitProgressCard> createState() => _HabitProgressCardState();
}

class _HabitProgressCardState extends State<_HabitProgressCard> {
  late List<Map<String, dynamic>> _list;

  @override
  void initState() {
    super.initState();
    _list = widget.habits.isNotEmpty
        ? widget.habits.map((h) => Map<String, dynamic>.from(h)).toList()
        : [
            {'name': 'Water', 'emoji': '💧', 'progress': 0.9, 'completed': true},
            {'name': 'Steps', 'emoji': '🏃', 'progress': 0.85, 'completed': true},
            {'name': 'Sleep', 'emoji': '😴', 'progress': 0.71, 'completed': false},
          ];
  }

  void _toggle(int index) {
    setState(() {
      _list[index]['completed'] = !(_list[index]['completed'] as bool? ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          'TODAY\'S HABITS',
          linkText: 'Manage →',
          onLink: () => widget.provider.navigate(1),
        ),
        ..._list.take(3).toList().asMap().entries.map((entry) {
          final i = entry.key;
          final h = entry.value;
          final prog = (h['progress'] as num? ?? 0).toDouble();
          final done = h['completed'] as bool? ?? false;
          final accent = done
              ? const Color(AppColors.lime)
              : const Color(AppColors.textMuted2);
          return HabitRow(
            emoji: h['emoji'] as String? ?? '⭕',
            name: h['name'] as String? ?? '',
            subtitle: done ? 'Completed' : '${(prog * 100).round()}% done',
            done: done,
            progress: done ? 1.0 : prog,
            accentColor: accent,
            onToggle: () => _toggle(i),
          );
        }),
      ]),
    );
  }
}

// ─── Leaderboard preview card ─────────────────────────────────────────────────
class _LeaderboardCard extends StatelessWidget {
  final List<Map<String, dynamic>> lbPreview;
  final AppProvider provider;
  const _LeaderboardCard({required this.lbPreview, required this.provider});

  @override
  Widget build(BuildContext context) {
    final list = lbPreview.isNotEmpty
        ? lbPreview
        : [
            {'rank': 1, 'name': 'Priya S.', 'score': 1240},
            {'rank': 2, 'name': 'Ramesh K.', 'score': 1185},
            {'rank': 3, 'name': 'Demo User', 'score': 1120, 'isCurrentUser': true},
          ];

    return DCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          'LEADERBOARD',
          linkText: 'Full Board →',
          onLink: () => provider.navigate(6),
        ),
        ...list.take(5).map((e) => LeaderboardRow(
              rank: e['rank'] as int? ?? 0,
              name: e['name'] as String? ?? '',
              score: e['score'] as int? ?? 0,
              isCurrentUser: e['isCurrentUser'] as bool? ?? false,
            )),
      ]),
    );
  }
}

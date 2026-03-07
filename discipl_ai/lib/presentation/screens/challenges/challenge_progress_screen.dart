import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class ChallengeProgressScreen extends StatelessWidget {
  final Map<String, dynamic> challenge;
  const ChallengeProgressScreen({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysCurrent = challenge['daysCurrent'] as int? ?? 14;
    final daysTotal   = challenge['daysTotal']   as int? ?? 30;
    final rank        = challenge['rank']         as int? ?? 7;
    final points      = challenge['points']       as int? ?? 1840;
    final pointsMax   = challenge['pointsMax']    as int? ?? 3000;
    final progress    = (challenge['progress']    as int? ?? 47) / 100.0;
    final milestones  = (challenge['milestones']  as List?)
        ?.cast<Map<String, dynamic>>() ?? [];
    final dailyLog    = (challenge['dailyLog']    as List?)
        ?.cast<Map<String, dynamic>>() ?? [];
    final rules       = (challenge['rules']       as List?)
        ?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: isDark ? Color(AppColors.darkBg) : Color(AppColors.lightBg),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Color(AppColors.purple2),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(AppColors.purple2), Color(AppColors.accent)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                            SizedBox(width: 5),
                            Text('Active', style: TextStyle(color: Colors.white,
                                fontSize: 11, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(challenge['name'] ?? '',
                          style: const TextStyle(fontSize: 20,
                              fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Day $daysCurrent of $daysTotal  ·  ${challenge['participants']} participants',
                          style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 12),
                      // Stats row
                      Row(children: [
                        _HeroStat('$daysCurrent/$daysTotal', 'Day'),
                        const SizedBox(width: 28),
                        _HeroStat('#$rank', 'Rank'),
                        const SizedBox(width: 28),
                        _HeroStat('$points', 'Points'),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16,
                MediaQuery.of(context).padding.bottom + 24),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // ── Progress bar ────────────────────────────────────────
              _Section(title: 'Overall Progress', child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${(progress * 100).round()}% complete',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: Color(AppColors.purple))),
                  Text('$points / $pointsMax pts',
                      style: TextStyle(fontSize: 12, color: Color(AppColors.mutedDark))),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Color(AppColors.darkBorder),
                    valueColor: AlwaysStoppedAnimation(Color(AppColors.purple)),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Day 1', style: TextStyle(fontSize: 10, color: Color(AppColors.mutedDark))),
                  Text('Day $daysTotal', style: TextStyle(fontSize: 10, color: Color(AppColors.mutedDark))),
                ]),
              ])),
              const SizedBox(height: 16),

              // ── Milestones ───────────────────────────────────────────
              _Section(title: 'Milestones', child: Column(
                children: milestones.asMap().entries.map((entry) {
                  final i = entry.key;
                  final m = entry.value;
                  final achieved = m['achieved'] == true;
                  final isCurrent = !achieved &&
                      (i == 0 || (milestones[i - 1]['achieved'] == true));
                  return _MilestoneRow(
                    day: m['day'] as int? ?? 0,
                    label: m['label'] as String? ?? '',
                    pts: m['pts'] as int? ?? 0,
                    achieved: achieved,
                    isCurrent: isCurrent,
                  );
                }).toList(),
              )),
              const SizedBox(height: 16),

              // ── Daily Activity Chart ─────────────────────────────────
              if (dailyLog.isNotEmpty) ...[
                _Section(title: 'Daily Points Earned', child: Column(children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: dailyLog.map((day) {
                        final pts = (day['pts'] as int? ?? 0).toDouble();
                        final done = day['completed'] == true;
                        const maxPts = 150.0;
                        final ratio = (pts / maxPts).clamp(0.0, 1.0);
                        return Expanded(child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                            Text('${day['day']}',
                                style: TextStyle(fontSize: 8,
                                    color: Color(AppColors.mutedDark))),
                            const SizedBox(height: 2),
                            Container(
                              height: 70 * ratio,
                              decoration: BoxDecoration(
                                gradient: done
                                    ? LinearGradient(
                                        colors: [Color(AppColors.purple), Color(AppColors.accent)],
                                        begin: Alignment.topCenter, end: Alignment.bottomCenter)
                                    : null,
                                color: done ? null : Color(AppColors.darkBorder),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ]),
                        ));
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 10, height: 10,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(AppColors.purple), Color(AppColors.accent)]),
                            borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 5),
                    Text('Completed day', style: TextStyle(fontSize: 10, color: Color(AppColors.mutedDark))),
                  ]),
                ])),
                const SizedBox(height: 16),
              ],

              // ── Rank Card ────────────────────────────────────────────
              _Section(title: 'Your Standing', child: Row(children: [
                Expanded(child: _StandingStat(
                    icon: Icons.leaderboard_outlined,
                    label: 'Current Rank',
                    value: '#$rank',
                    color: Color(AppColors.purple))),
                const SizedBox(width: 12),
                Expanded(child: _StandingStat(
                    icon: Icons.star_rounded,
                    label: 'Points',
                    value: '$points',
                    color: Color(AppColors.yellow))),
                const SizedBox(width: 12),
                Expanded(child: _StandingStat(
                    icon: Icons.timer_outlined,
                    label: 'Days Left',
                    value: '${daysTotal - daysCurrent}',
                    color: Color(AppColors.green))),
              ])),
              const SizedBox(height: 16),

              // ── Challenge Rules ───────────────────────────────────────
              if (rules.isNotEmpty)
                _Section(title: 'Challenge Rules', child: Column(
                  children: rules.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: Color(AppColors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r,
                          style: const TextStyle(fontSize: 13))),
                    ]),
                  )).toList(),
                )),
            ])),
          ),
        ],
      ),
    );
  }
}

// ─── Hero stat ─────────────────────────────────────────────────────────────
class _HeroStat extends StatelessWidget {
  final String value, label;
  const _HeroStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(value, style: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
  ]);
}

// ─── Milestone row ─────────────────────────────────────────────────────────
class _MilestoneRow extends StatelessWidget {
  final int day, pts;
  final String label;
  final bool achieved, isCurrent;
  const _MilestoneRow({required this.day, required this.label,
      required this.pts, required this.achieved, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final color = achieved
        ? Color(AppColors.green)
        : isCurrent
            ? Color(AppColors.purple)
            : Color(AppColors.mutedDark);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(child: Icon(
            achieved ? Icons.check_rounded : isCurrent ? Icons.flag_outlined : Icons.lock_outline,
            size: 16, color: color,
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: achieved || isCurrent ? Theme.of(context).textTheme.bodyLarge?.color : Color(AppColors.mutedDark))),
          Text('Day $day', style: TextStyle(fontSize: 11, color: Color(AppColors.mutedDark))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('+$pts pts',
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ─── Standing stat ─────────────────────────────────────────────────────────
class _StandingStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StandingStat({required this.icon, required this.label,
      required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Color(AppColors.darkBg2) : Color(AppColors.lightBg2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 9,
            color: Color(AppColors.mutedDark))),
      ]),
    );
  }
}

// ─── Section card ──────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(AppColors.darkCard) : Color(AppColors.lightCard),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [BoxShadow(
            color: Color(AppColors.purple).withOpacity(0.07), blurRadius: 12)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w700, color: Color(AppColors.mutedDark),
            letterSpacing: 0.3)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

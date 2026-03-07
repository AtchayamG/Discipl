import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

// ─── Challenge Progress Screen ────────────────────────────────────────────────
class ChallengeProgressScreen extends StatelessWidget {
  final Map<String, dynamic> challenge;
  const ChallengeProgressScreen({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final daysCurrent = challenge['daysCurrent'] as int? ?? 14;
    final daysTotal   = challenge['daysTotal']   as int? ?? 30;
    final rank        = challenge['rank']         as int? ?? 7;
    final points      = challenge['points']       as int? ?? 1840;
    final pointsMax   = challenge['pointsMax']    as int? ?? 3000;
    final progress    = (challenge['progress']    as int? ?? 47) / 100.0;
    final milestones  = (challenge['milestones']  as List?)?.cast<Map<String, dynamic>>() ?? _mockMilestones;
    final dailyLog    = (challenge['dailyLog']    as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rules       = (challenge['rules']       as List?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: TC.of(context).pageBg,
      body: CustomScrollView(slivers: [
        // Hero app bar
        SliverAppBar(
          expandedHeight: 220, pinned: true,
          backgroundColor: TC.of(context).cardBg,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: TC.of(context).lime),
            onPressed: () => Navigator.pop(context)),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(color: TC.of(context).cardBg),
              child: Stack(children: [
                // Subtle lime glow
                Positioned(right: -40, top: -40, child: Container(width: 200, height: 200,
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(AppColors.lime).withOpacity(0.08), blurRadius: 80, spreadRadius: 40)]))),
                SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: TC.of(context).limeBorder)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.circle, size: 7, color: TC.of(context).lime),
                        SizedBox(width: 5),
                        Text('Active', style: TextStyle(fontFamily: AppTypography.displayFont, color: TC.of(context).lime, fontSize: 11, fontWeight: FontWeight.w700)),
                      ])),
                    const SizedBox(height: 10),
                    Text(challenge['name'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 20, fontWeight: FontWeight.w800, color: TC.of(context).textPrimary)),
                    const SizedBox(height: 4),
                    Text('Day $daysCurrent of $daysTotal  ·  ${challenge['participants'] ?? 320} participants',
                      style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textMuted)),
                    const SizedBox(height: 14),
                    Row(children: [
                      _HStat('$daysCurrent/$daysTotal', 'Day'),
                      const SizedBox(width: 28),
                      _HStat('#$rank', 'Rank'),
                      const SizedBox(width: 28),
                      _HStat('$points', 'Points'),
                    ]),
                  ]),
                )),
              ]),
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 24),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Progress bar
            _Sec(label: 'OVERALL PROGRESS', child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${(progress * 100).round()}% complete', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w700, color: TC.of(context).lime)),
                Text('$points / $pointsMax pts', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textMuted)),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: TC.of(context).progressTrack, color: TC.of(context).lime)),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Day 1', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted2)),
                Text('Day $daysTotal', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted2)),
              ]),
            ])),
            const SizedBox(height: 12),

            // Your standing
            _Sec(label: 'YOUR STANDING', child: Row(children: [
              Expanded(child: _StatBox(icon: Icons.leaderboard_outlined, label: 'Rank', value: '#$rank', color: TC.of(context).lime)),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(icon: Icons.star_rounded, label: 'Points', value: '$points', color: const Color(AppColors.orange))),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(icon: Icons.timer_outlined, label: 'Days Left', value: '${daysTotal - daysCurrent}', color: const Color(AppColors.teal))),
            ])),
            const SizedBox(height: 12),

            // Milestones
            _Sec(label: 'MILESTONES', child: Column(
              children: milestones.asMap().entries.map((e) {
                final m = e.value;
                final achieved  = m['achieved'] == true;
                final isCurrent = !achieved && (e.key == 0 || milestones[e.key - 1]['achieved'] == true);
                final color = achieved ? const Color(AppColors.lime) : isCurrent ? const Color(AppColors.orange) : const Color(AppColors.textMuted2);
                return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
                  Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color, width: 1.5)),
                    child: Center(child: Icon(achieved ? Icons.check_rounded : isCurrent ? Icons.flag_outlined : Icons.lock_outline, size: 15, color: color))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m['label'] as String? ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w700, color: (achieved || isCurrent) ? TC.of(context).textPrimary : TC.of(context).textMuted2)),
                    Text('Day ${m['day']}', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted2)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('+${m['pts']} pts', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, color: color, fontWeight: FontWeight.w700))),
                ]));
              }).toList(),
            )),
            const SizedBox(height: 12),

            // Daily log chart
            if (dailyLog.isNotEmpty) ...[
              _Sec(label: 'DAILY POINTS EARNED', child: Column(children: [
                const SizedBox(height: 8),
                SizedBox(height: 90, child: Row(crossAxisAlignment: CrossAxisAlignment.end,
                  children: dailyLog.map((day) {
                    final pts = (day['pts'] as int? ?? 0).toDouble();
                    final done = day['completed'] == true;
                    final ratio = (pts / 150).clamp(0.0, 1.0);
                    return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 1.5), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('${day['day']}', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 8, color: TC.of(context).textMuted2)),
                      const SizedBox(height: 2),
                      Container(height: 65 * ratio, decoration: BoxDecoration(
                        color: done ? Color(AppColors.lime) : TC.of(context).surfaceBg,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: done ? [BoxShadow(color: const Color(AppColors.lime).withOpacity(0.2), blurRadius: 4)] : null)),
                    ])));
                  }).toList(),
                )),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: TC.of(context).lime, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 5),
                  Text('Completed day', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted)),
                ]),
              ])),
              const SizedBox(height: 12),
            ],

            // Rules
            if (rules.isNotEmpty)
              _Sec(label: 'CHALLENGE RULES', child: Column(
                children: rules.map((r) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.check_circle_outline, size: 16, color: TC.of(context).lime),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: TC.of(context).textPrimary))),
                ]))).toList(),
              )),
          ])),
        ),
      ]),
    );
  }
}

class _HStat extends StatelessWidget {
  final String value, label;
  const _HStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(value, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 20, fontWeight: FontWeight.w800, color: TC.of(context).lime)),
    Text(label, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted)),
  ]);
}

class _Sec extends StatelessWidget {
  final String label; final Widget child;
  const _Sec({required this.label, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(color: TC.of(context).cardBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, fontWeight: FontWeight.w700, color: TC.of(context).textMuted2, letterSpacing: 1)),
      const SizedBox(height: 12),
      child,
    ]));
}

class _StatBox extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _StatBox({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(height: 5),
      Text(value, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 17, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 9, color: TC.of(context).textMuted2)),
    ]));
}

const _mockMilestones = [
  {'day': 7,  'label': 'First Week',     'pts': 100, 'achieved': true},
  {'day': 14, 'label': 'Halfway There',  'pts': 200, 'achieved': true},
  {'day': 21, 'label': 'Three Weeks',    'pts': 300, 'achieved': false},
  {'day': 30, 'label': 'Challenge Done', 'pts': 500, 'achieved': false},
];

// ─── Join Challenge Screen ────────────────────────────────────────────────────
class JoinChallengeScreen extends StatefulWidget {
  final Map<String, dynamic> challenge;
  const JoinChallengeScreen({super.key, required this.challenge});
  @override State<JoinChallengeScreen> createState() => _JoinChallengeScreenState();
}

class _JoinChallengeScreenState extends State<JoinChallengeScreen> {
  bool _joining = false;
  bool _joined  = false;
  bool _agreed  = false;

  Future<void> _join() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please accept the challenge rules first'), backgroundColor: Color(AppColors.red)));
      return;
    }
    setState(() => _joining = true);
    await Future.delayed(const Duration(milliseconds: 900));
    await context.read<AppProvider>().joinChallenge(widget.challenge['id'] ?? '');
    if (mounted) setState(() { _joining = false; _joined = true; });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final rules      = (c['rules']      as List?)?.cast<String>() ?? [];
    final milestones = (c['milestones'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final isUpcoming = (c['status'] as String? ?? '') == 'upcoming';
    final participants    = c['participants']    as int? ?? 0;
    final maxParticipants = c['maxParticipants'] as int? ?? 300;
    final fillRatio = (participants / maxParticipants).clamp(0.0, 1.0);

    if (_joined) return _SuccessView(challenge: c);

    return Scaffold(
      backgroundColor: TC.of(context).pageBg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200, pinned: true,
          backgroundColor: TC.of(context).cardBg,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: TC.of(context).lime), onPressed: () => Navigator.pop(context)),
          flexibleSpace: FlexibleSpaceBar(background: Container(
            color: TC.of(context).cardBg,
            child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(c['rewardIcon'] ?? '🏆', style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(c['name'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 19, fontWeight: FontWeight.w800, color: TC.of(context).textPrimary))),
                ]),
                const SizedBox(height: 8),
                Text(c['description'] ?? '', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textMuted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Wrap(spacing: 8, children: [
                  _TPill(c['category'] ?? 'General'),
                  _TPill('${c['daysTotal'] ?? 30} days'),
                  if (isUpcoming) _TPill('Starts ${c['startDate'] ?? ''}', color: const Color(AppColors.orange)),
                ]),
              ]),
            )),
          )),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 24),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Reward
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).limeBorder)),
              child: Row(children: [
                Text(c['rewardIcon'] ?? '🏆', style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Reward', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted)),
                  Text(c['reward'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w800, color: TC.of(context).textPrimary)),
                ])),
              ])),
            const SizedBox(height: 12),

            // Stats
            Row(children: [
              Expanded(child: _IStat(icon: Icons.people_outline, label: 'Participants', value: '$participants', color: TC.of(context).lime)),
              const SizedBox(width: 10),
              Expanded(child: _IStat(icon: Icons.calendar_today_rounded, label: 'Duration', value: '${c['daysTotal'] ?? 30}d', color: const Color(AppColors.teal))),
              const SizedBox(width: 10),
              Expanded(child: _IStat(icon: Icons.star_rounded, label: 'Max Pts', value: isUpcoming ? 'TBD' : '${c['pointsMax'] ?? '—'}', color: const Color(AppColors.orange))),
            ]),
            const SizedBox(height: 12),

            // Capacity
            _JCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Spots Filled', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700, color: TC.of(context).textMuted)),
                Text('$participants / $maxParticipants', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, color: TC.of(context).lime, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: fillRatio, minHeight: 7, backgroundColor: TC.of(context).progressTrack, color: fillRatio > 0.8 ? Color(AppColors.red) : Color(AppColors.lime))),
              if (fillRatio > 0.8) ...[
                const SizedBox(height: 6),
                const Row(children: [
                  Icon(Icons.warning_amber_rounded, size: 13, color: Color(AppColors.red)),
                  SizedBox(width: 4),
                  Text('Filling up fast!', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, color: Color(AppColors.red), fontWeight: FontWeight.w600)),
                ]),
              ],
            ])),
            const SizedBox(height: 12),

            // Milestones
            if (milestones.isNotEmpty) ...[
              _JCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Milestones & Rewards', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700, color: TC.of(context).textMuted)),
                const SizedBox(height: 10),
                ...milestones.map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
                  Container(width: 30, height: 30, decoration: BoxDecoration(color: TC.of(context).limeBg, shape: BoxShape.circle, border: Border.all(color: TC.of(context).limeBorder)),
                    child: Center(child: Icon(Icons.flag_outlined, size: 14, color: TC.of(context).lime))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m['label'] as String? ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary)),
                    Text('Day ${m['day']}', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted2)),
                  ])),
                  Text('+${m['pts']} pts', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, color: TC.of(context).lime, fontWeight: FontWeight.w700)),
                ]))),
              ])),
              const SizedBox(height: 12),
            ],

            // Rules
            if (rules.isNotEmpty) ...[
              _JCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Challenge Rules', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700, color: TC.of(context).textMuted)),
                const SizedBox(height: 10),
                ...rules.map((r) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.check_circle_outline, size: 15, color: TC.of(context).lime),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textPrimary))),
                ]))),
              ])),
              const SizedBox(height: 12),
            ],

            // Agreement checkbox
            GestureDetector(
              onTap: () => setState(() => _agreed = !_agreed),
              child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _agreed ? TC.of(context).limeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: _agreed ? const Color(AppColors.lime) : const Color(AppColors.border))),
                child: Row(children: [
                  AnimatedContainer(duration: const Duration(milliseconds: 150), width: 22, height: 22,
                    decoration: BoxDecoration(color: _agreed ? const Color(AppColors.lime) : Colors.transparent, borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _agreed ? const Color(AppColors.lime) : const Color(AppColors.border), width: 2)),
                    child: _agreed ? Icon(Icons.check_rounded, size: 14, color: TC.of(context).checkFg) : null),
                  const SizedBox(width: 10),
                  Expanded(child: Text('I agree to the challenge rules and commit to participating',
                    style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: TC.of(context).textPrimary))),
                ])),
            ),
            const SizedBox(height: 16),

            // Join button
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _agreed ? Color(AppColors.lime) : TC.of(context).surfaceBg,
                  foregroundColor: _agreed ? const Color(AppColors.bg) : const Color(AppColors.textMuted),
                  elevation: 0),
                onPressed: _joining ? null : _join,
                child: _joining
                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: TC.of(context).checkFg))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(isUpcoming ? Icons.notifications_active_outlined : Icons.emoji_events_outlined, size: 19),
                      const SizedBox(width: 8),
                      Text(isUpcoming ? 'Notify Me When Live' : 'Join Challenge',
                        style: const TextStyle(fontFamily: AppTypography.displayFont, fontSize: 15, fontWeight: FontWeight.w700)),
                    ]),
              )),
          ])),
        ),
      ]),
    );
  }
}

class _TPill extends StatelessWidget {
  final String label; final Color? color;
  const _TPill(this.label, {this.color});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, color: color ?? const Color(AppColors.lime), fontWeight: FontWeight.w600)));
}

class _IStat extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _IStat({required this.icon, required this.label, required this.value, required this.color});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Icon(icon, size: 17, color: color),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 9, color: TC.of(context).textMuted2)),
    ]));
}

class _JCard extends StatelessWidget {
  final Widget child;
  const _JCard({required this.child});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: TC.of(context).cardBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).border)),
    child: child);
}

// ─── Success view ─────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final Map<String, dynamic> challenge;
  const _SuccessView({required this.challenge});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: TC.of(context).pageBg,
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100,
          decoration: BoxDecoration(color: TC.of(context).limeBg, shape: BoxShape.circle, border: Border.all(color: TC.of(context).lime, width: 2),
            boxShadow: [BoxShadow(color: const Color(AppColors.lime).withOpacity(0.2), blurRadius: 30, spreadRadius: 5)]),
          child: Center(child: Icon(Icons.emoji_events_rounded, size: 50, color: TC.of(context).lime))),
        const SizedBox(height: 28),
        Text("You're In! 🎉", style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 26, fontWeight: FontWeight.w800, color: TC.of(context).textPrimary)),
        const SizedBox(height: 10),
        Text(challenge['name'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 16, color: TC.of(context).lime, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Stay consistent, complete your daily habits,\nand climb the leaderboard!',
          style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: TC.of(context).textMuted, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 28),
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).limeBorder)),
          child: Row(children: [
            Text(challenge['rewardIcon'] ?? '🏆', style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Goal', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted)),
              Text(challenge['reward'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary)),
            ])),
          ])),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('Start Challenge Now', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 15, fontWeight: FontWeight.w700)))),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Back to Challenges', style: TextStyle(fontFamily: AppTypography.bodyFont, color: TC.of(context).textMuted))),
      ]),
    )),
  );
}

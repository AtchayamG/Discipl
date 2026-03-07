import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

class JoinChallengeScreen extends StatefulWidget {
  final Map<String, dynamic> challenge;
  const JoinChallengeScreen({super.key, required this.challenge});
  @override State<JoinChallengeScreen> createState() => _JoinChallengeScreenState();
}

class _JoinChallengeScreenState extends State<JoinChallengeScreen> {
  bool _joining = false;
  bool _joined  = false;
  bool _agreed  = false;

  Future<void> _joinChallenge() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please accept the challenge rules first'),
        backgroundColor: Color(AppColors.red),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _joining = true);
    await Future.delayed(const Duration(milliseconds: 900));

    await context.read<AppProvider>().joinChallenge(widget.challenge['id'] ?? '');

    if (mounted) {
      setState(() { _joining = false; _joined = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = widget.challenge;
    final rules      = (c['rules']      as List?)?.cast<String>() ?? [];
    final milestones = (c['milestones'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final status     = c['status'] as String? ?? 'open';
    final isUpcoming = status == 'upcoming';
    final participants    = c['participants']    as int? ?? 0;
    final maxParticipants = c['maxParticipants'] as int? ?? 300;
    final fillRatio = (participants / maxParticipants).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark ? Color(AppColors.darkBg) : Color(AppColors.lightBg),
      body: _joined ? _SuccessView(challenge: c) : CustomScrollView(
        slivers: [
          // ── Hero ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
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
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(c['rewardIcon'] ?? '🏆',
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(c['name'] ?? '',
                            style: const TextStyle(fontSize: 19,
                                fontWeight: FontWeight.w800, color: Colors.white))),
                      ]),
                      const SizedBox(height: 8),
                      Text(c['description'] ?? '',
                          style: const TextStyle(fontSize: 12,
                              color: Colors.white70, height: 1.4),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, children: [
                        _TagPill(c['category'] ?? 'General'),
                        _TagPill('${c['daysTotal'] ?? 30} days'),
                        if (isUpcoming)
                          _TagPill('Starts ${c['startDate'] ?? ''}',
                              color: Color(AppColors.yellow)),
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

              // ── Reward card ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(AppColors.yellow).withOpacity(0.15),
                                Color(AppColors.accent).withOpacity(0.08)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(AppColors.yellow).withOpacity(0.3)),
                ),
                child: Row(children: [
                  Text(c['rewardIcon'] ?? '🏆',
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Reward', style: TextStyle(
                        fontSize: 11, color: Color(AppColors.mutedDark),
                        fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(c['reward'] ?? '',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ])),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Stats row ────────────────────────────────────────────
              Row(children: [
                Expanded(child: _InfoStat(
                    icon: Icons.people_outline, label: 'Participants',
                    value: '$participants', color: Color(AppColors.purple))),
                const SizedBox(width: 10),
                Expanded(child: _InfoStat(
                    icon: Icons.calendar_today_rounded, label: 'Duration',
                    value: '${c['daysTotal'] ?? 30}d', color: Color(AppColors.accent))),
                const SizedBox(width: 10),
                Expanded(child: _InfoStat(
                    icon: Icons.star_rounded, label: 'Max Pts',
                    value: isUpcoming ? 'TBD' : '${c['pointsMax'] ?? c['points'] ?? '–'}',
                    color: Color(AppColors.yellow))),
              ]),
              const SizedBox(height: 16),

              // ── Capacity bar ─────────────────────────────────────────
              _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Spots Filled', style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: Color(AppColors.mutedDark))),
                  Text('$participants / $maxParticipants',
                      style: TextStyle(fontSize: 12, color: Color(AppColors.purple),
                          fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: fillRatio,
                    backgroundColor: Theme.of(context).dividerColor,
                    valueColor: AlwaysStoppedAnimation(
                        fillRatio > 0.8 ? Color(AppColors.red) : Color(AppColors.purple)),
                    minHeight: 8,
                  ),
                ),
                if (fillRatio > 0.8) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 14, color: Color(AppColors.red)),
                    const SizedBox(width: 4),
                    Text('Filling up fast!',
                        style: TextStyle(fontSize: 11, color: Color(AppColors.red),
                            fontWeight: FontWeight.w600)),
                  ]),
                ],
              ])),
              const SizedBox(height: 16),

              // ── Milestones ───────────────────────────────────────────
              if (milestones.isNotEmpty) ...[
                _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Milestones & Rewards',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: Color(AppColors.mutedDark))),
                  const SizedBox(height: 12),
                  ...milestones.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Color(AppColors.purple).withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(AppColors.purple).withOpacity(0.4)),
                        ),
                        child: Center(child: Icon(Icons.flag_outlined,
                            size: 15, color: Color(AppColors.purple))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(m['label'] as String? ?? '',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('Day ${m['day']}', style: TextStyle(
                            fontSize: 10, color: Color(AppColors.mutedDark))),
                      ])),
                      Text('+${m['pts']} pts',
                          style: TextStyle(fontSize: 12, color: Color(AppColors.green),
                              fontWeight: FontWeight.w700)),
                    ]),
                  )),
                ])),
                const SizedBox(height: 16),
              ],

              // ── Rules ────────────────────────────────────────────────
              if (rules.isNotEmpty) ...[
                _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Challenge Rules',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: Color(AppColors.mutedDark))),
                  const SizedBox(height: 12),
                  ...rules.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: Color(AppColors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r, style: const TextStyle(fontSize: 13))),
                    ]),
                  )),
                ])),
                const SizedBox(height: 16),
              ],

              // ── Agreement ────────────────────────────────────────────
              GestureDetector(
                onTap: () => setState(() => _agreed = !_agreed),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _agreed
                        ? Color(AppColors.purple).withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _agreed
                            ? Color(AppColors.purple)
                            : Theme.of(context).dividerColor),
                  ),
                  child: Row(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: _agreed ? Color(AppColors.purple) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: _agreed ? Color(AppColors.purple)
                                : Color(AppColors.mutedDark), width: 2),
                      ),
                      child: _agreed
                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'I agree to the challenge rules and commit to participating',
                      style: TextStyle(fontSize: 13,
                          color: _agreed
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Color(AppColors.mutedDark)),
                    )),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              // ── Join button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _agreed
                        ? Color(AppColors.purple)
                        : Color(AppColors.mutedDark).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _joining ? null : _joinChallenge,
                  child: _joining
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(isUpcoming
                              ? Icons.notifications_active_outlined
                              : Icons.emoji_events_outlined,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isUpcoming ? 'Notify Me When Live' : 'Join Challenge',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ]),
                ),
              ),
            ])),
          ),
        ],
      ),
    );
  }
}

// ─── Success screen shown after joining ──────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final Map<String, dynamic> challenge;
  const _SuccessView({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(AppColors.purple2), Color(AppColors.accent)]),
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Icon(Icons.emoji_events_rounded,
                      size: 52, color: Colors.white)),
            ),
            const SizedBox(height: 28),
            const Text("You're In! 🎉",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(challenge['name'] ?? '',
                style: TextStyle(fontSize: 16, color: Color(AppColors.purple),
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Stay consistent, complete your daily habits,\nand climb the leaderboard!',
                style: TextStyle(fontSize: 13, color: Color(AppColors.mutedDark),
                    height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            // Reward reminder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(AppColors.purple).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Color(AppColors.purple).withOpacity(0.25)),
              ),
              child: Row(children: [
                Text(challenge['rewardIcon'] ?? '🏆',
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your Goal', style: TextStyle(
                      fontSize: 11, color: Color(AppColors.mutedDark))),
                  Text(challenge['reward'] ?? '',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ])),
              ]),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Start Challenge Now',
              onTap: () => Navigator.pop(context, true),
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Back to Challenges',
                  style: TextStyle(color: Color(AppColors.mutedDark))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widgets ────────────────────────────────────────────────────────
class _TagPill extends StatelessWidget {
  final String label;
  final Color? color;
  const _TagPill(this.label, {this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: TextStyle(
        fontSize: 11, color: color ?? Colors.white70,
        fontWeight: FontWeight.w600)),
  );
}

class _InfoStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _InfoStat({required this.icon, required this.label,
      required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(AppColors.darkBg2) : Color(AppColors.lightBg2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 9,
            color: Color(AppColors.mutedDark))),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      border: Border.all(color: Theme.of(context).dividerColor),
      boxShadow: [BoxShadow(color: Color(AppColors.purple).withOpacity(0.07), blurRadius: 12)],
    ),
    child: child,
  );
}

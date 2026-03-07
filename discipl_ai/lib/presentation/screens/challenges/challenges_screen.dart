import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';
import '../challenge_detail/challenge_progress_screen.dart';
import '../challenge_detail/join_challenge_screen.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.isLoading) return const LoadingState();

    final challenges = provider.data['challenges'] as Map<String, dynamic>? ?? {};
    final active     = challenges['active'] as Map<String, dynamic>? ?? {};
    final list       = (challenges['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final lb         = (challenges['leaderboard'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final activeChallenge = list.firstWhere((c) => c['status'] == 'active', orElse: () => {});
    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Challenges', subtitle: 'Compete and grow with others'),

        // Active challenge hero
        _ActiveHero(active: active, challenge: activeChallenge),
        const SizedBox(height: 14),

        Responsive.isWide(context)
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 2, child: _ChallengeList(list: list)),
                const SizedBox(width: 12),
                Expanded(child: _LBCard(lb: lb)),
              ])
            : Column(children: [
                _ChallengeList(list: list),
                const SizedBox(height: 12),
                _LBCard(lb: lb),
              ]),
        const SizedBox(height: 32),
      ]),
    );
  }
}

// ─── Active challenge hero ────────────────────────────────────────────────────
class _ActiveHero extends StatelessWidget {
  final Map<String, dynamic> active;
  final Map<String, dynamic> challenge;
  const _ActiveHero({required this.active, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final day       = active['day']        as int? ?? 14;
    final totalDays = active['totalDays']  as int? ?? 30;
    final progress  = day / totalDays;

    return GestureDetector(
      onTap: challenge.isNotEmpty
          ? () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ChallengeProgressScreen(challenge: {
                  ...challenge, 'day': day, 'daysCurrent': day,
                  'rank': active['rank'] ?? 7, 'points': active['points'] ?? 1840,
                })))
          : null,
      child: LimeHeroBanner(
        child: Stack(children: [
          Positioned(right: -10, top: -10, bottom: -10,
            child: Icon(Icons.emoji_events, size: 110, color: const Color(AppColors.lime).withOpacity(0.06))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TC.of(context).limeBorder)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.circle, size: 7, color: TC.of(context).lime),
                  SizedBox(width: 5),
                  Text('Active', style: TextStyle(fontFamily: AppTypography.displayFont, color: TC.of(context).lime, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: TC.of(context).textMuted),
            ]),
            const SizedBox(height: 10),
            Text(active['name'] ?? '30-Day Discipline Challenge', style: TextStyle(
              fontFamily: AppTypography.displayFont, fontSize: 19, fontWeight: FontWeight.w800, color: TC.of(context).textPrimary)),
            const SizedBox(height: 4),
            Text('Day $day of $totalDays  ·  ${active['participants'] ?? 320} participants',
              style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textMuted)),
            const SizedBox(height: 14),
            Row(children: [
              _Stat('$day/$totalDays', 'Day'),
              const SizedBox(width: 24),
              _Stat('#${active['rank'] ?? 7}', 'Rank'),
              const SizedBox(width: 24),
              _Stat('${active['points'] ?? 1840}', 'Points'),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress, minHeight: 6,
                backgroundColor: TC.of(context).progressTrack,
                color: TC.of(context).lime,
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(value, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 20, fontWeight: FontWeight.w800, color: TC.of(context).lime)),
    Text(label, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted)),
  ]);
}

// ─── Challenge list ───────────────────────────────────────────────────────────
class _ChallengeList extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  const _ChallengeList({required this.list});
  @override
  Widget build(BuildContext context) => Column(
    children: list.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _ChallengeCard(challenge: c))).toList());
}

class _ChallengeCard extends StatefulWidget {
  final Map<String, dynamic> challenge;
  const _ChallengeCard({required this.challenge});
  @override State<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<_ChallengeCard> {
  bool _joined = false;

  Color _statusColor(String status) {
    return switch (status) {
      'active'   => const Color(AppColors.lime),
      'upcoming' => const Color(AppColors.orange),
      _          => const Color(AppColors.teal),
    };
  }

  @override
  Widget build(BuildContext context) {
    final c      = widget.challenge;
    final status = c['status'] as String? ?? 'open';
    final isActive   = status == 'active';
    final isUpcoming = status == 'upcoming';
    final color  = _statusColor(status);
    final label  = switch (status) { 'active' => 'Active', 'upcoming' => 'Upcoming', _ => 'Open' };

    return DCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.4)), borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
          if (_joined) DPill('✓ Joined', color: TC.of(context).limeBg, textColor: Color(AppColors.lime)),
        ]),
        const SizedBox(height: 10),
        Text(c['name'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 15, fontWeight: FontWeight.w800, color: TC.of(context).textPrimary)),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.people_outline, size: 13, color: TC.of(context).textMuted),
          const SizedBox(width: 4),
          Text('${c['participants'] ?? 0} participants', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted)),
          const SizedBox(width: 10),
          Icon(Icons.emoji_events_outlined, size: 13, color: TC.of(context).textMuted),
          const SizedBox(width: 4),
          Expanded(child: Text(c['reward'] ?? '', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted), overflow: TextOverflow.ellipsis)),
        ]),

        if (isActive) ...[
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${c['progress'] ?? 0}% complete', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 10, fontWeight: FontWeight.w600, color: TC.of(context).lime)),
            Text('${c['daysLeft'] ?? 0} days left', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
            value: (c['progress'] as int? ?? 0) / 100, minHeight: 5,
            backgroundColor: TC.of(context).progressTrack, color: TC.of(context).lime)),
        ],

        if (isUpcoming) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 13, color: Color(AppColors.orange)),
            const SizedBox(width: 5),
            Text('Starts ${c['startDate'] ?? ''}', style: const TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, color: Color(AppColors.orange), fontWeight: FontWeight.w600)),
          ]),
        ],

        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _joined ? const Color(AppColors.teal) : const Color(AppColors.lime),
              foregroundColor: const Color(AppColors.bg),
              padding: const EdgeInsets.symmetric(vertical: 13),
              elevation: 0,
            ),
            icon: Icon(isActive ? Icons.bar_chart_rounded : _joined ? Icons.check_circle_outline : Icons.emoji_events_outlined, size: 17),
            label: Text(isActive ? 'View Progress' : _joined ? 'Joined ✓' : 'Join Challenge',
              style: const TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w700)),
            onPressed: _joined ? null : isActive
                ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChallengeProgressScreen(challenge: c)))
                : () async {
                    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => JoinChallengeScreen(challenge: c)));
                    if (result == true && mounted) {
                      setState(() => _joined = true);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('🏆 Joined "${c['name']}"!'),
                        backgroundColor: const Color(AppColors.lime)));
                    }
                  },
          ),
        ),
      ]),
    );
  }
}

// ─── Leaderboard card ─────────────────────────────────────────────────────────
class _LBCard extends StatelessWidget {
  final List<Map<String, dynamic>> lb;
  const _LBCard({required this.lb});
  @override
  Widget build(BuildContext context) => DCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('CHALLENGE LEADERBOARD'),
      ...lb.map((e) => LeaderboardRow(
        rank: e['rank'] ?? 0, name: e['name'] ?? '',
        score: e['score'] ?? 0, isCurrentUser: e['isMe'] == true)),
    ]),
  );
}

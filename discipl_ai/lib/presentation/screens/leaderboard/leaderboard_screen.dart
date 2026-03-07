import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.isLoading) return const LoadingState();

    final lb      = provider.data['leaderboard'] as Map<String, dynamic>? ?? {};
    final global  = (lb['global']  as List?)?.cast<Map<String, dynamic>>() ?? [];
    final friends = (lb['friends'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final badges  = (lb['badges']  as List?)?.cast<Map<String, dynamic>>() ?? [];
    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Leaderboard', subtitle: 'How you rank globally and among friends'),

        // Stat cards
        StatGrid(stats: const [
          StatCardData(label: 'GLOBAL RANK',       value: '#247',  sub: 'Top 5%',       icon: '🌍', accentColor: Color(AppColors.lime)),
          StatCardData(label: 'CHALLENGE RANK',    value: '#7',    sub: 'Out of 320',   icon: '🏆', accentColor: Color(AppColors.orange)),
          StatCardData(label: 'DISCIPLINE SCORE',  value: '76',    sub: '+4 this week', icon: '⭐', accentColor: Color(AppColors.teal)),
          StatCardData(label: 'TOTAL POINTS',      value: '12,450',sub: 'All time',     icon: '🏅', accentColor: Color(AppColors.violet)),
        ]),
        const SizedBox(height: 16),

        // Tab filter
        Container(
          decoration: BoxDecoration(color: TC.of(context).cardBg, borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: TC.of(context).border)),
          padding: const EdgeInsets.all(3),
          child: Row(children: ['Global', 'Friends'].asMap().entries.map((e) {
            final isOn = e.key == _tab;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _tab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isOn ? TC.of(context).lime : Colors.transparent,
                  borderRadius: BorderRadius.circular(9)),
                child: Text(e.value, textAlign: TextAlign.center, style: TextStyle(
                  fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700,
                  color: isOn ? const Color(AppColors.bg) : const Color(AppColors.textMuted))),
              ),
            ));
          }).toList()),
        ),
        const SizedBox(height: 14),

        // Rankings
        DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(_tab == 0 ? 'GLOBAL RANKINGS' : 'FRIENDS RANKINGS'),
          ...(_tab == 0 ? global : friends).map((e) => LeaderboardRow(
            rank: e['rank'] ?? 0,
            name: e['name'] ?? '',
            score: e['score'] ?? 0,
            isCurrentUser: e['isMe'] == true,
          )),
        ])),
        const SizedBox(height: 14),

        // Badges
        DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('YOUR BADGES'),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.value(context, mobile: 2, desktop: 3),
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2),
            itemCount: badges.isNotEmpty ? badges.length : _mockBadges.length,
            itemBuilder: (_, i) {
              final b = badges.isNotEmpty ? badges[i] : _mockBadges[i];
              final unlocked = b['unlocked'] == true;
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: unlocked ? TC.of(context).limeBg : TC.of(context).cardBg2,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: unlocked ? const Color(AppColors.limeAlpha20) : const Color(AppColors.border))),
                child: Row(children: [
                  Text(b['icon'] as String? ?? '🏅', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(b['name'] ?? '', style: TextStyle(
                      fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w700,
                      color: unlocked ? const Color(AppColors.lime) : const Color(AppColors.textMuted))),
                    Text(b['desc'] ?? '', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 9, color: TC.of(context).textMuted2)),
                  ])),
                  if (!unlocked) Icon(Icons.lock_outline, size: 13, color: TC.of(context).textMuted2),
                ]),
              );
            },
          ),
        ])),
        const SizedBox(height: 32),
      ]),
    );
  }
}

const _mockBadges = [
  {'name': '21-Day Streak', 'desc': 'Completed', 'icon': '🔥', 'unlocked': true},
  {'name': 'Early Bird',    'desc': 'Completed', 'icon': '🌅', 'unlocked': true},
  {'name': 'Iron Will',     'desc': 'Completed', 'icon': '💪', 'unlocked': true},
  {'name': 'Centurion',     'desc': '100-day streak', 'icon': '⭐', 'unlocked': false},
  {'name': 'Top 1%',        'desc': 'Global leaderboard', 'icon': '🏆', 'unlocked': false},
  {'name': 'Champion',      'desc': 'Win a challenge', 'icon': '👑', 'unlocked': false},
];

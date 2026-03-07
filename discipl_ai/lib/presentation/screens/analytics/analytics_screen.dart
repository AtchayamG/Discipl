import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider     = context.watch<AppProvider>();
    if (provider.isLoading) return const LoadingState();

    final analytics    = provider.data['analytics'] as Map<String, dynamic>? ?? {};
    final scoreTrend   = (analytics['scoreTrend']       as List?)?.cast<Map<String, dynamic>>() ?? _mockTrend;
    final habitCats    = (analytics['habitCategories']  as List?)?.cast<Map<String, dynamic>>() ?? _mockCats;
    final workoutTypes = (analytics['workoutTypes']     as List?)?.cast<Map<String, dynamic>>() ?? _mockWorkouts;
    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Analytics', subtitle: 'Deep dive into your performance data'),

        StatGrid(stats: const [
          StatCardData(label: 'DISCIPLINE SCORE', value: '76',     sub: 'Avg +2 pts/week', icon: '⭐', accentColor: Color(AppColors.lime)),
          StatCardData(label: 'HABITS DONE',       value: '483',   sub: 'Since Jan 1, 2026',icon: '✅', accentColor: Color(AppColors.teal)),
          StatCardData(label: 'TOTAL WORKOUTS',    value: '38',    sub: 'This year',        icon: '💪', accentColor: Color(AppColors.orange)),
          StatCardData(label: 'TOTAL POINTS',      value: '12,450',sub: 'All time',         icon: '🏅', accentColor: Color(AppColors.violet)),
        ]),
        const SizedBox(height: 14),

        // Score trend chart
        DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('9-WEEK DISCIPLINE SCORE TREND'),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: scoreTrend.map((s) {
              final score = s['score'] as int? ?? 0;
              final ratio = ((score - 50) / 50).clamp(0.05, 1.0);
              final isLatest = scoreTrend.last == s;
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('$score', style: TextStyle(
                    fontFamily: AppTypography.displayFont, fontSize: 9, fontWeight: FontWeight.w700,
                    color: isLatest ? TC.of(context).lime : TC.of(context).textMuted2)),
                  const SizedBox(height: 3),
                  Container(
                    height: 90 * ratio,
                    decoration: BoxDecoration(
                      color: isLatest ? const Color(AppColors.lime) : const Color(AppColors.limeAlpha12),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isLatest ? [BoxShadow(color: const Color(AppColors.lime).withOpacity(0.3), blurRadius: 8)] : null),
                  ),
                  const SizedBox(height: 5),
                  Text(s['week'] ?? '', style: TextStyle(
                    fontFamily: AppTypography.bodyFont, fontSize: 9,
                    color: isLatest ? TC.of(context).lime : TC.of(context).textMuted2)),
                ]),
              ));
            }).toList()),
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Week 1: 58 → Week 9: 76   ', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted)),
            Text('↑ +18 points', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w700, color: TC.of(context).lime)),
          ]),
        ])),
        const SizedBox(height: 14),

        // Habit categories + Workout breakdown
        Responsive.isWide(context)
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _HabitCats(cats: habitCats)),
                const SizedBox(width: 12),
                Expanded(child: _WorkoutBreakdown(types: workoutTypes)),
              ])
            : Column(children: [
                _HabitCats(cats: habitCats),
                const SizedBox(height: 12),
                _WorkoutBreakdown(types: workoutTypes),
              ]),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _HabitCats extends StatelessWidget {
  final List<Map<String, dynamic>> cats;
  const _HabitCats({required this.cats});

  static const _colors = [
    Color(AppColors.lime), Color(AppColors.teal), Color(AppColors.orange), Color(AppColors.violet),
  ];

  @override
  Widget build(BuildContext context) => DCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('HABIT COMPLETION BY CATEGORY'),
      ...cats.asMap().entries.map((e) {
        final c = e.value;
        final color = _colors[e.key % _colors.length];
        final val = (c['value'] as int? ?? 0) / 100;
        return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(c['name'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w600, color: TC.of(context).textPrimary)),
            Text('${c['value'] ?? 0}%', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
            value: val, minHeight: 5,
            backgroundColor: TC.of(context).progressTrack,
            color: color)),
        ]));
      }),
    ]),
  );
}

class _WorkoutBreakdown extends StatelessWidget {
  final List<Map<String, dynamic>> types;
  const _WorkoutBreakdown({required this.types});

  static const _colors = [
    Color(AppColors.lime), Color(AppColors.teal), Color(AppColors.orange), Color(AppColors.violet),
  ];

  @override
  Widget build(BuildContext context) {
    final total = types.fold(0, (sum, t) => sum + (t['count'] as int? ?? 0));
    return DCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader('WORKOUT TYPE BREAKDOWN'),
        ...types.asMap().entries.map((e) {
          final t = e.value;
          final color = _colors[e.key % _colors.length];
          final count = t['count'] as int? ?? 0;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(color: TC.of(context).cardBg2, borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: TC.of(context).border)),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(t['type'] ?? '', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textPrimary))),
              Text('$count sessions', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted)),
              const SizedBox(width: 10),
              SizedBox(width: 70, child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
                value: count / (total == 0 ? 1 : total), minHeight: 5,
                backgroundColor: TC.of(context).progressTrack, color: color))),
            ]),
          );
        }),
      ]),
    );
  }
}

const _mockTrend    = [{'week':'W1','score':58},{'week':'W2','score':61},{'week':'W3','score':63},{'week':'W4','score':66},{'week':'W5','score':68},{'week':'W6','score':70},{'week':'W7','score':72},{'week':'W8','score':74},{'week':'W9','score':76}];
const _mockCats     = [{'name':'Fitness','value':92},{'name':'Health','value':84},{'name':'Mindset','value':76},{'name':'Nutrition','value':68}];
const _mockWorkouts = [{'type':'Strength','count':18},{'type':'Cardio','count':10},{'type':'HIIT','count':6},{'type':'Flexibility','count':4}];

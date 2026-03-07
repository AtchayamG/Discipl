import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

class AIInsightsScreen extends StatelessWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<AppProvider>();
    if (provider.isLoading) return const LoadingState();

    final ai         = provider.data['aiInsights'] as Map<String, dynamic>? ?? {};
    final metrics    = (ai['metrics']  as List?)?.cast<Map<String, dynamic>>() ?? _mockMetrics;
    final prediction = ai['prediction'] as Map<String, dynamic>? ?? _mockPrediction;
    final patterns   = (ai['patterns'] as List?)?.cast<Map<String, dynamic>>() ?? _mockPatterns;
    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'AI Insights', subtitle: 'Powered by behavioral analysis'),

        // Weekly report hero
        LimeHeroBanner(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: TC.of(context).limeBorder)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('✦', style: TextStyle(fontSize: 12, color: TC.of(context).lime)),
                SizedBox(width: 5),
                Text('AI WEEKLY REPORT', style: TextStyle(fontFamily: AppTypography.displayFont, color: TC.of(context).lime, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Text(
            ai['weeklyReport'] as String? ?? 'Your discipline score improved by 4 points this week. Morning habits are your strongest pillar — keep it up. Focus on evening consistency to unlock your next level.',
            style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: TC.of(context).textPrimary, height: 1.6)),
        ])),
        const SizedBox(height: 14),

        // Metrics + Prediction
        Responsive.isWide(context)
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _MetricsCard(metrics: metrics)),
                const SizedBox(width: 12),
                Expanded(child: _PredictionCard(prediction: prediction)),
              ])
            : Column(children: [
                _MetricsCard(metrics: metrics),
                const SizedBox(height: 12),
                _PredictionCard(prediction: prediction),
              ]),
        const SizedBox(height: 14),

        // Pattern analysis
        DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('PATTERN ANALYSIS'),
          ...patterns.map((p) => _PatternCard(pattern: p)),
        ])),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final List<Map<String, dynamic>> metrics;
  const _MetricsCard({required this.metrics});

  @override
  Widget build(BuildContext context) => DCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('BEHAVIORAL METRICS'),
      ...metrics.map((m) {
        final trend = m['trend'] ?? 'neutral';
        final color = trend == 'up' ? const Color(AppColors.lime) : trend == 'down' ? const Color(AppColors.red) : const Color(AppColors.orange);
        final arrow = trend == 'up' ? '↑' : trend == 'down' ? '↓' : '→';
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(color: TC.of(context).cardBg2, borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: TC.of(context).border)),
          child: Row(children: [
            Expanded(child: Text(m['label'] ?? '', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textMuted))),
            Text('${m['value'] ?? ''} ', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            Text(arrow, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
          ]),
        );
      }),
    ]),
  );
}

class _PredictionCard extends StatelessWidget {
  final Map<String, dynamic> prediction;
  const _PredictionCard({required this.prediction});

  @override
  Widget build(BuildContext context) => DCard(
    borderColor: const Color(AppColors.limeAlpha20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('FAT LOSS PREDICTION'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TC.of(context).limeBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: TC.of(context).limeBorder)),
        child: Column(children: [
          _Row('Current Weight',       '${prediction['currentWeight']   ?? 77.5} kg'),
          _Row('Goal Weight',          '${prediction['goalWeight']       ?? 72.0} kg'),
          _Row('Projected Completion', prediction['projectedDate']        ?? '~May 15, 2026'),
          _Row('Weekly Rate',          prediction['weeklyRate']           ?? '0.5 kg/week'),
          _Row('Status',               prediction['ahead']                ?? '+2 weeks ahead'),
        ]),
      ),
    ]),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textMuted))),
      Text(value, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700, color: TC.of(context).lime)),
    ]),
  );
}

class _PatternCard extends StatelessWidget {
  final Map<String, dynamic> pattern;
  const _PatternCard({required this.pattern});

  @override
  Widget build(BuildContext context) {
    final isPositive = pattern['type'] == 'positive';
    final color = isPositive ? const Color(AppColors.lime) : const Color(AppColors.orange);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border(left: BorderSide(color: color, width: 3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(isPositive ? '✅ ' : '⚠️ ', style: const TextStyle(fontSize: 14)),
          Expanded(child: Text(pattern['title'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary))),
        ]),
        const SizedBox(height: 5),
        Text(pattern['desc'] ?? '', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textMuted, height: 1.5)),
      ]),
    );
  }
}

const _mockMetrics = [
  {'label': 'Habit Consistency', 'value': '87%', 'trend': 'up'},
  {'label': 'Workout Frequency', 'value': '5/7',  'trend': 'up'},
  {'label': 'Sleep Quality',     'value': '7.2h', 'trend': 'neutral'},
  {'label': 'Nutrition Score',   'value': '72%',  'trend': 'down'},
];
const _mockPrediction = {'currentWeight': 77.5, 'goalWeight': 72.0, 'projectedDate': '~May 15, 2026', 'weeklyRate': '0.5 kg/week', 'ahead': '+2 weeks ahead'};
const _mockPatterns = [
  {'type': 'positive', 'title': 'Morning Consistency',      'desc': 'You complete 94% of morning habits before 8AM. This is your peak performance window.'},
  {'type': 'positive', 'title': 'Weekend Warrior',          'desc': 'Your weekend habit completion is 12% higher than weekdays — a rare and powerful trait.'},
  {'type': 'warning',  'title': 'Evening Slump Detected',   'desc': 'Habit completion drops 38% after 9PM. Consider shifting evening tasks to the afternoon.'},
];

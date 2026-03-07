import 'package:flutter/material.dart';
import 'log_workout_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';
import 'workout_detail_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.isLoading) return const LoadingState();
    if (provider.error != null)
      return ErrorState(message: provider.error!, onRetry: provider.refresh);

    final raw = (provider.data['workouts'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final history = raw.isNotEmpty ? raw : _mockHistory;
    final today = history.isNotEmpty ? history.first : <String, dynamic>{};
    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(
          title: 'Workouts',
          subtitle: 'Log, track, and crush your training goals',
          action: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LogWorkoutScreen())),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Log Workout'),
          ),
        ),

        // Today's plan hero banner
        if (today.isNotEmpty) ...[
          LimeHeroBanner(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'TODAY\'S PLAN',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: TC.of(context).lime,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                today['title'] as String? ?? today['name'] as String? ?? 'Upper Body Power',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: TC.of(context).textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI-generated · ${today['duration'] ?? 45} min · ${(today['exercises'] as List?)?.length ?? today['exerciseCount'] ?? 8} exercises',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 12,
                  color: TC.of(context).textMuted,
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LogWorkoutScreen())),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Start Workout'),
                ),
                const SizedBox(width: 12),
                Row(children: [
                  _StatPill('${(today['exercises'] as List?)?.length ?? today['exerciseCount'] ?? 8}', 'Exercises'),
                  const SizedBox(width: 10),
                  _StatPill('${today['duration'] ?? 45}', 'Minutes'),
                  const SizedBox(width: 10),
                  _StatPill('${today['calories'] ?? 380}', 'Est Kcal'),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
        ],

        // Recent workouts list
        DCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader('RECENT WORKOUTS'),
            ...history.asMap().entries.map((e) {
              final w = e.value;
              return _WorkoutCard(
                workout: w,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutDetailScreen(
                        workout: w,
                        workoutIndex: e.key,
                      ),
                    ),
                  );
                },
              );
            }),
          ]),
        ),

        const SizedBox(height: 32),
      ]),
    );
  }
}

// ─── Stat pill ────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: TC.of(context).lime,
          )),
      Text(label,
          style: TextStyle(
            fontFamily: AppTypography.bodyFont,
            fontSize: 10,
            color: TC.of(context).textMuted2,
          )),
    ]);
  }
}

// ─── Redesigned Workout Card (no numbering) ───────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onTap;
  const _WorkoutCard({required this.workout, required this.onTap});

  Color _typeColor(BuildContext context, String type) {
    final tc = TC.of(context);
    switch (type.toLowerCase()) {
      case 'cardio':
        return tc.teal;
      case 'hiit':
        return tc.orange;
      case 'yoga':
      case 'flexibility':
        return tc.violet;
      default:
        return tc.lime;
    }
  }

  String get _emoji {
    final e = workout['emoji'] as String? ?? workout['icon'] as String?;
    if (e != null && e.isNotEmpty) return e;
    switch (_type.toLowerCase()) {
      case 'cardio': return '🏃';
      case 'yoga': return '🧘';
      case 'cycling': return '🚴';
      case 'hiit': return '⚡';
      case 'swimming': return '🏊';
      default: return '🏋️';
    }
  }

  String get _name =>
      workout['title'] as String? ?? workout['name'] as String? ?? 'Workout';

  String get _type {
    final tags = workout['tags'] as List?;
    if (tags != null && tags.isNotEmpty) return tags.first as String;
    return workout['type'] as String? ?? 'Strength';
  }

  String get _dateLabel =>
      workout['date'] as String? ??
      (workout['meta'] as String?)?.split('·').first.trim() ??
      'Recent';

  String get _durationLabel {
    final d = workout['duration'];
    if (d != null) return '$d min';
    final meta = workout['meta'] as String?;
    if (meta != null) {
      final parts = meta.split('·');
      if (parts.length > 1) return parts[1].trim();
    }
    return '';
  }

  String get _caloriesLabel {
    final c = workout['calories'];
    if (c != null && c != 0) return '$c kcal';
    final meta = workout['meta'] as String?;
    if (meta != null) {
      final parts = meta.split('·');
      if (parts.length > 2) return parts[2].trim();
    }
    return '';
  }

  int get _exerciseCount {
    final exList = workout['exercises'] as List?;
    if (exList != null) return exList.length;
    return workout['exerciseCount'] as int? ?? workout['sets'] as int? ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final type = _type;
    final typeColor = _typeColor(context, type);
    final exerciseCount = _exerciseCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: tc.cardBg2,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: tc.border),
        ),
        child: Row(children: [
          // Emoji icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(_emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 13),

          // Text content
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Name + type badge
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                  child: Text(
                    _name,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFont,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 5),

              // Date · Duration · Calories
              Wrap(spacing: 0, children: [
                _MetaChip(icon: Icons.calendar_today_outlined, label: _dateLabel, tc: tc),
                if (_durationLabel.isNotEmpty) ...[
                  Text('  ·  ', style: TextStyle(fontSize: 11, color: tc.textMuted2)),
                  _MetaChip(icon: Icons.timer_outlined, label: _durationLabel, tc: tc),
                ],
                if (_caloriesLabel.isNotEmpty) ...[
                  Text('  ·  ', style: TextStyle(fontSize: 11, color: tc.textMuted2)),
                  _MetaChip(icon: Icons.local_fire_department_outlined, label: _caloriesLabel, tc: tc, color: tc.orange),
                ],
              ]),
              const SizedBox(height: 6),

              // Exercise count + Completed badge
              Row(children: [
                if (exerciseCount > 0) ...[
                  Icon(Icons.fitness_center_outlined, size: 12, color: tc.textMuted2),
                  const SizedBox(width: 4),
                  Text(
                    '$exerciseCount exercise${exerciseCount == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontFamily: AppTypography.bodyFont,
                        fontSize: 11,
                        color: tc.textMuted2),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: tc.limeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle_outline, size: 11, color: tc.limeText),
                    const SizedBox(width: 3),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: tc.limeText,
                      ),
                    ),
                  ]),
                ),
              ]),
            ]),
          ),

          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: tc.textMuted2, size: 18),
        ]),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final TC tc;
  final Color? color;
  const _MetaChip({required this.icon, required this.label, required this.tc, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? tc.textMuted;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: c),
      const SizedBox(width: 3),
      Text(label,
          style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 11,
              color: tc.textMuted)),
    ]);
  }
}

// ─── Mock fallback data ───────────────────────────────────────────────────────
const _mockHistory = [
  {
    'id': 'mock_1',
    'title': 'Full Body Strength',
    'emoji': '🏋️',
    'type': 'Strength',
    'date': 'Yesterday',
    'duration': 52,
    'calories': 420,
    'exercises': [],
    'notes': '',
  },
  {
    'id': 'mock_2',
    'title': '5K Morning Run',
    'emoji': '🏃',
    'type': 'Cardio',
    'date': '2 days ago',
    'duration': 28,
    'calories': 310,
    'exercises': [],
    'notes': '',
  },
  {
    'id': 'mock_3',
    'title': 'Yoga Flow',
    'emoji': '🧘',
    'type': 'Yoga',
    'date': '3 days ago',
    'duration': 35,
    'calories': 180,
    'exercises': [],
    'notes': '',
  },
  {
    'id': 'mock_4',
    'title': 'Cycling HIIT',
    'emoji': '🚴',
    'type': 'HIIT',
    'date': '4 days ago',
    'duration': 40,
    'calories': 510,
    'exercises': [],
    'notes': '',
  },
];

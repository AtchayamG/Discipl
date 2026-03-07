import 'package:flutter/material.dart';
import '../add_habit/add_habit_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.isLoading) return const LoadingState();
    if (provider.error != null)
      return ErrorState(message: provider.error!, onRetry: provider.refresh);

    final habitList = (provider.data['habits'] as List?)?.cast<Map<String, dynamic>>() ?? _mockHabits;
    final streak = (provider.data['dashboard'] as Map<String, dynamic>?)?['stats']?['currentStreak'] as int? ?? 21;
    final todayDone = habitList.where((h) => h['completedToday'] == true).length;
    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Header
        PageHeader(
          title: 'Habits',
          subtitle: 'Build consistency, one day at a time',
          action: ElevatedButton.icon(
            onPressed: () => _goAddHabit(context, provider),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Habit'),
          ),
        ),

        // Streak hero
        LimeHeroBanner(
          child: Row(children: [
            // Streak ring
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(AppColors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: const Color(AppColors.orange).withOpacity(0.3)),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🔥', style: TextStyle(fontSize: 22)),
                Text(
                  '$streak',
                  style: const TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(AppColors.orange),
                    height: 1,
                  ),
                ),
                Text(
                  'DAYS',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 9,
                    color: TC.of(context).textMuted2,
                    letterSpacing: 1,
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'On a roll! 🎯',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: TC.of(context).textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$todayDone of ${habitList.length} habits done today',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFont,
                    fontSize: 12,
                    color: TC.of(context).textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                // Week dots
                Row(
                  children: ['M','T','W','T','F','S','S'].asMap().entries.map((e) {
                    final done = e.key < 6;
                    final isToday = e.key == 6;
                    return Container(
                      margin: const EdgeInsets.only(right: 5),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: done
                            ? const Color(AppColors.lime)
                            : isToday
                                ? const Color(AppColors.limeAlpha12)
                                : const Color(AppColors.surface),
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(color: TC.of(context).lime, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFont,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: done
                                ? const Color(AppColors.bg)
                                : isToday
                                    ? const Color(AppColors.lime)
                                    : TC.of(context).textMuted2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 14),

        // Habits list
        DCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader('TODAY\'S HABITS'),
            ...habitList.map((h) {
              final done = (h['completedToday'] as bool?) ?? (h['completed'] as bool?) ?? false;
              final streak = h['streak'] as int? ?? 0;
              final pct = (h['weekProgress'] as num? ?? (h['progress'] as num?) ?? (done ? 1.0 : 0.0)).toDouble();
              final color = _accentForHabit(h['category'] as String? ?? '');
              final extracted = _extractEmoji(h['name'] as String? ?? '', h['emoji'] as String?);
              return HabitRow(
                emoji: extracted.$1,
                name: extracted.$2,
                subtitle: done ? '🔥 ${streak}d streak · Completed' : '${(pct * 100).round()}% this week',
                done: done,
                progress: pct,
                accentColor: done ? color : TC.of(context).textMuted2,
                onToggle: () => provider.toggleHabit(h['id'] as String? ?? ''),
              );
            }),
          ]),
        ),

        const SizedBox(height: 32),
      ]),
    );
  }

  void _goAddHabit(BuildContext context, AppProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddHabitScreen()),
    );
  }

  /// Returns (emoji, cleanName).
  /// If a dedicated emoji field exists, use it and return name as-is.
  /// Otherwise peel the leading emoji cluster off the name string.
  (String, String) _extractEmoji(String rawName, String? emojiField) {
    // Dedicated emoji field takes priority
    if (emojiField != null && emojiField.trim().isNotEmpty) {
      return (emojiField.trim(), rawName.trim());
    }

    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return (_emojiForCategory(''), '');

    final runes = trimmed.runes.toList();
    if (runes.isEmpty) return (_emojiForCategory(''), trimmed);

    // Check if first rune is in emoji range
    final first = runes.first;
    final isEmoji = (first >= 0x1F300) ||  // Misc Symbols, Emoticons, etc.
                    (first >= 0x2600 && first <= 0x27BF) || // Misc symbols
                    (first >= 0x2B00 && first <= 0x2BFF);   // Misc symbols extended

    if (!isEmoji) return (_emojiForCategory(''), trimmed);

    // Build the emoji cluster: consume emoji chars + optional variation selector + ZWJ sequences
    int i = 1;
    // Also swallow variation selector U+FE0F and ZWJ U+200D + next char
    while (i < runes.length) {
      final r = runes[i];
      if (r == 0xFE0F || r == 0x200D) {
        i++; // swallow selector/ZWJ and the char after ZWJ
        if (r == 0x200D && i < runes.length) i++;
      } else {
        break;
      }
    }

    final emojiStr = String.fromCharCodes(runes.sublist(0, i));
    // Skip space(s) after emoji
    while (i < runes.length && runes[i] == 0x20) i++;

    final cleanName = String.fromCharCodes(runes.sublist(i)).trim();
    if (cleanName.isEmpty) return (_emojiForCategory(''), trimmed);

    return (emojiStr, cleanName);
  }

  String _emojiForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'fitness':   return '🏃';
      case 'health':    return '💧';
      case 'mindset':   return '🧘';
      case 'nutrition': return '🥗';
      case 'sleep':     return '😴';
      case 'learning':  return '📚';
      default:          return '✨';
    }
  }

  Color _accentForHabit(String cat) {
    switch (cat.toLowerCase()) {
      case 'fitness': return const Color(AppColors.lime);
      case 'health':  return const Color(AppColors.teal);
      case 'mindset': return const Color(AppColors.violet);
      case 'nutrition': return const Color(AppColors.orange);
      default: return const Color(AppColors.lime);
    }
  }
}

const _mockHabits = [
  {'id': '1', 'name': 'Morning Run', 'emoji': '🌅', 'category': 'fitness', 'completedToday': true, 'streak': 21, 'weekProgress': 1.0},
  {'id': '2', 'name': 'Hydration', 'emoji': '💧', 'category': 'health', 'completedToday': true, 'streak': 14, 'weekProgress': 0.8},
  {'id': '3', 'name': 'Meditation', 'emoji': '🧘', 'category': 'mindset', 'completedToday': false, 'streak': 7, 'weekProgress': 0.0},
  {'id': '4', 'name': 'Reading', 'emoji': '📚', 'category': 'mindset', 'completedToday': false, 'streak': 5, 'weekProgress': 0.5},
];

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../widgets/layout/app_scaffold.dart';
import 'dashboard/dashboard_screen.dart';
import 'habits/habits_screen.dart';
import 'workouts/workouts_screen.dart';
import 'photos/photos_screen.dart';
import 'community/community_screen.dart';
import 'challenges/challenges_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'ai_insights/ai_insights_screen.dart';
import 'analytics/analytics_screen.dart';
import 'settings/settings_screen.dart';
import '../../core/constants/app_constants.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Back-button behaviour:
///   • Previous tab in history exists → go back to it
///   • No history + not on Dashboard   → go to Dashboard
///   • On Dashboard (no history)        → show Exit dialog
///
/// AddHabitScreen (was index 10) and LogWorkoutScreen (was index 11)
/// are now pushed via Navigator.push — they handle their own back naturally.
/// ─────────────────────────────────────────────────────────────────────────────
const _screens = [
  DashboardScreen(),   // 0
  HabitsScreen(),      // 1
  WorkoutsScreen(),    // 2
  PhotographsScreen(), // 3
  CommunityScreen(),   // 4
  ChallengesScreen(),  // 5
  LeaderboardScreen(), // 6
  AIInsightsScreen(),  // 7
  AnalyticsScreen(),   // 8
  SettingsScreen(),    // 9
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {

  Future<void> _handleBack() async {
    final provider = context.read<AppProvider>();

    // Go back to previous tab if history exists
    if (provider.navigateBack()) return;

    // No history and already on Dashboard → Exit dialog
    if (provider.selectedIndex == 0) {
      final shouldExit = await _showExitDialog();
      if (shouldExit == true && mounted) SystemNavigator.pop();
      return;
    }

    // No history but not on Dashboard → go to Dashboard
    provider.navigate(0);
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(AppColors.bg2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(AppColors.border)),
            boxShadow: [BoxShadow(
              color: const Color(AppColors.lime).withOpacity(0.08),
              blurRadius: 32, spreadRadius: 2,
            )],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.red).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.exit_to_app_rounded,
                      color: Color(AppColors.red), size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Exit App?', style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: Color(AppColors.textPrimary),
                )),
              ]),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to exit Discipl.AI?',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 14, height: 1.5,
                  color: Color(AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _DialogBtn(
                  label: 'Stay',
                  onTap: () => Navigator.pop(ctx, false),
                  bgColor: const Color(AppColors.surface),
                  borderColor: const Color(AppColors.border),
                  textColor: const Color(AppColors.textMuted),
                )),
                const SizedBox(width: 12),
                Expanded(child: _DialogBtn(
                  label: 'Exit',
                  onTap: () => Navigator.pop(ctx, true),
                  bgColor: const Color(AppColors.red).withOpacity(0.14),
                  borderColor: const Color(AppColors.red).withOpacity(0.45),
                  textColor: const Color(AppColors.red),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: AppScaffold(
        child: IndexedStack(
          index: provider.selectedIndex,
          children: _screens,
        ),
      ),
    );
  }
}

class _DialogBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bgColor, borderColor, textColor;
  const _DialogBtn({required this.label, required this.onTap,
    required this.bgColor, required this.borderColor, required this.textColor});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(
        fontFamily: AppTypography.displayFont,
        fontSize: 14, fontWeight: FontWeight.w700, color: textColor,
      )),
    ),
  );
}

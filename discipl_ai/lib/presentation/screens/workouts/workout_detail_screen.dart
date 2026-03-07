import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../providers/app_provider.dart';

/// Workout Detail Screen — shown when user taps a workout in the list.
/// Supports editing and deleting the workout.
class WorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  final int workoutIndex;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
    required this.workoutIndex,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late Map<String, dynamic> _workout;
  bool _editing = false;

  // Edit controllers
  late TextEditingController _titleCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _caloriesCtrl;
  late String _selectedType;

  final _types = [
    {'label': 'Strength', 'icon': '🏋️'},
    {'label': 'Cardio', 'icon': '🏃'},
    {'label': 'Yoga', 'icon': '🧘'},
    {'label': 'Cycling', 'icon': '🚴'},
    {'label': 'HIIT', 'icon': '⚡'},
    {'label': 'Swimming', 'icon': '🏊'},
  ];

  @override
  void initState() {
    super.initState();
    _workout = Map<String, dynamic>.from(widget.workout);
    _initControllers();
  }

  void _initControllers() {
    _titleCtrl = TextEditingController(
        text: _workout['title'] as String? ?? _workout['name'] as String? ?? '');
    _notesCtrl =
        TextEditingController(text: _workout['notes'] as String? ?? '');
    _durationCtrl = TextEditingController(
        text: (_workout['duration'] ?? '').toString());
    _caloriesCtrl = TextEditingController(
        text: (_workout['calories'] != null && _workout['calories'] != 0)
            ? _workout['calories'].toString()
            : '');
    final tags = _workout['tags'] as List?;
    _selectedType = tags != null && tags.isNotEmpty
        ? tags.first as String
        : _workout['type'] as String? ?? 'Strength';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _durationCtrl.dispose();
    _caloriesCtrl.dispose();
    super.dispose();
  }

  String get _name =>
      _workout['title'] as String? ?? _workout['name'] as String? ?? 'Workout';

  String get _type {
    final tags = _workout['tags'] as List?;
    if (tags != null && tags.isNotEmpty) return tags.first as String;
    return _workout['type'] as String? ?? 'Strength';
  }

  String get _emoji {
    final e = _workout['emoji'] as String? ?? _workout['icon'] as String?;
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

  Color _typeColor(BuildContext context, String type) {
    final tc = TC.of(context);
    switch (type.toLowerCase()) {
      case 'cardio': return tc.teal;
      case 'hiit': return tc.orange;
      case 'yoga':
      case 'flexibility': return tc.violet;
      default: return tc.lime;
    }
  }

  // ── Save edits ──────────────────────────────────────────────────────────────
  Future<void> _saveEdits() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter a workout title'),
        backgroundColor: const Color(AppColors.red),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    final updated = Map<String, dynamic>.from(_workout)
      ..['title'] = _titleCtrl.text.trim()
      ..['name'] = _titleCtrl.text.trim()
      ..['notes'] = _notesCtrl.text.trim()
      ..['duration'] = int.tryParse(_durationCtrl.text) ?? _workout['duration']
      ..['calories'] = int.tryParse(_caloriesCtrl.text) ?? _workout['calories']
      ..['type'] = _selectedType
      ..['tags'] = [_selectedType]
      ..['icon'] = _types.firstWhere(
            (t) => t['label'] == _selectedType,
            orElse: () => {'icon': '🏋️'},
          )['icon']
      ..['emoji'] = _types.firstWhere(
            (t) => t['label'] == _selectedType,
            orElse: () => {'icon': '🏋️'},
          )['icon'];

    final provider = context.read<AppProvider>();
    provider.updateWorkout(widget.workoutIndex, updated);

    setState(() {
      _workout = updated;
      _editing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Workout updated!'),
      backgroundColor: const Color(AppColors.lime),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Delete ──────────────────────────────────────────────────────────────────
  Future<void> _deleteWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: Text('Remove "${_name}" from your history? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: TextStyle(color: const Color(AppColors.red))),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AppProvider>().deleteWorkout(widget.workoutIndex);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final isDark = tc.isDark;
    final type = _editing ? _selectedType : _type;
    final typeColor = _typeColor(context, type);
    final exercises = (_workout['exercises'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return Scaffold(
      backgroundColor: tc.pageBg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(AppColors.bg2) : const Color(AppColors.lightCard),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _editing ? 'Edit Workout' : 'Workout Detail',
          style: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: tc.textPrimary,
          ),
        ),
        actions: [
          if (!_editing) ...[
            IconButton(
              icon: Icon(Icons.edit_outlined, color: tc.lime),
              onPressed: () => setState(() => _editing = true),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: const Color(AppColors.red)),
              onPressed: _deleteWorkout,
              tooltip: 'Delete',
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _editing = false;
                  _initControllers(); // reset
                });
              },
              child: Text('Cancel', style: TextStyle(color: tc.textMuted)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _saveEdits,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.lime),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(AppColors.bg) : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 32 + MediaQuery.of(context).padding.bottom),
        child: _editing ? _buildEditForm(context, tc, typeColor) : _buildDetailView(context, tc, typeColor, exercises),
      ),
    );
  }

  // ── Read-only Detail View ───────────────────────────────────────────────────
  Widget _buildDetailView(BuildContext context, TC tc, Color typeColor, List<Map<String, dynamic>> exercises) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Hero card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: tc.isDark
              ? LinearGradient(
                  colors: [typeColor.withOpacity(0.15), typeColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [typeColor.withOpacity(0.1), typeColor.withOpacity(0.03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: typeColor.withOpacity(0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(_emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  _name,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tc.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _type,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFont,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                    ),
                  ),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 18),
          // Stats row
          Row(children: [
            _StatBox(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: _workout['date'] as String? ?? 'Today',
              tc: tc,
            ),
            const SizedBox(width: 10),
            _StatBox(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: '${_workout['duration'] ?? '--'} min',
              tc: tc,
            ),
            const SizedBox(width: 10),
            _StatBox(
              icon: Icons.local_fire_department_outlined,
              label: 'Calories',
              value: _workout['calories'] != null && _workout['calories'] != 0
                  ? '${_workout['calories']} kcal'
                  : '--',
              tc: tc,
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 20),

      // Exercises section
      if (exercises.isNotEmpty) ...[
        _SectionTitle('Exercises', tc),
        const SizedBox(height: 10),
        ...exercises.map((ex) => _ExerciseTile(exercise: ex, tc: tc)),
        const SizedBox(height: 20),
      ],

      // Notes section
      if ((_workout['notes'] as String? ?? '').isNotEmpty) ...[
        _SectionTitle('Notes', tc),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tc.cardBg2,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: tc.border),
          ),
          child: Text(
            _workout['notes'] as String,
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 13,
              color: tc.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],

      // Delete button
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _deleteWorkout,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Delete Workout'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(AppColors.red),
            side: const BorderSide(color: Color(AppColors.red)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          ),
        ),
      ),
    ]);
  }

  // ── Edit Form ───────────────────────────────────────────────────────────────
  Widget _buildEditForm(BuildContext context, TC tc, Color typeColor) {
    final isDark = tc.isDark;
    final border = tc.border;
    final muted = tc.textMuted;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle('Workout Details', tc),
      const SizedBox(height: 10),

      // Title
      _EditCard(
        tc: tc,
        child: TextField(
          controller: _titleCtrl,
          style: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: tc.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Morning Upper Body',
            hintStyle: TextStyle(color: muted),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      const SizedBox(height: 12),

      // Type picker
      _EditCard(
        tc: tc,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Type', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
            final selected = _selectedType == t['label'];
            return GestureDetector(
              onTap: () => setState(() => _selectedType = t['label']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? const Color(AppColors.lime) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? const Color(AppColors.lime) : border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(t['icon']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(t['label']!,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? (isDark ? const Color(AppColors.bg) : Colors.white)
                            : muted,
                      )),
                ]),
              ),
            );
          }).toList()),
        ]),
      ),
      const SizedBox(height: 12),

      // Duration + Calories
      Row(children: [
        Expanded(
          child: _EditCard(
            tc: tc,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Duration (min)', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary),
                decoration: InputDecoration(
                  hintText: '45',
                  hintStyle: TextStyle(color: muted),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _EditCard(
            tc: tc,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Calories', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _caloriesCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Auto',
                  hintStyle: TextStyle(color: muted),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 12),

      // Notes
      _SectionTitle('Notes (optional)', tc),
      const SizedBox(height: 8),
      _EditCard(
        tc: tc,
        child: TextField(
          controller: _notesCtrl,
          maxLines: 4,
          style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 13,
              color: tc.textPrimary),
          decoration: InputDecoration(
            hintText: 'How did it go? Any PRs today?',
            hintStyle: TextStyle(color: muted),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      const SizedBox(height: 24),

      // Save button
      GestureDetector(
        onTap: _saveEdits,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(AppColors.lime),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Text(
            'Save Changes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(AppColors.bg) : Colors.white,
            ),
          ),
        ),
      ),
    ]);
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  final TC tc;
  const _SectionTitle(this.text, this.tc);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontFamily: AppTypography.displayFont,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: tc.textMuted,
          letterSpacing: 0.5,
        ),
      );
}

class _EditCard extends StatelessWidget {
  final Widget child;
  final TC tc;
  const _EditCard({required this.child, required this.tc});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tc.cardBg2,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: tc.border),
        ),
        child: child,
      );
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final TC tc;
  const _StatBox({required this.icon, required this.label, required this.value, required this.tc});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: tc.cardBg2.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Icon(icon, size: 14, color: tc.textMuted),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 10,
                color: tc.textMuted,
              ),
            ),
          ]),
        ),
      );
}

class _ExerciseTile extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final TC tc;
  const _ExerciseTile({required this.exercise, required this.tc});

  @override
  Widget build(BuildContext context) {
    final sets = (exercise['sets'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final doneSets = sets.where((s) => s['done'] == true).length;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: tc.cardBg2,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: tc.border),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(AppColors.limeAlpha12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              exercise['icon'] as String? ?? '💪',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              exercise['name'] as String? ?? 'Exercise',
              style: TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
              ),
            ),
            if (sets.isNotEmpty)
              Text(
                '$doneSets/${sets.length} sets completed',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 11,
                  color: tc.textMuted,
                ),
              ),
          ]),
        ),
        if (sets.isNotEmpty && doneSets == sets.length)
          Icon(Icons.check_circle, color: const Color(AppColors.lime), size: 18),
      ]),
    );
  }
}

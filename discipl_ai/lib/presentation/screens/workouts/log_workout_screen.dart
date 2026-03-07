import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a logged exercise set
// ─────────────────────────────────────────────────────────────────────────────
class ExerciseSet {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final String icon;
  final String unit;
  List<SetEntry> sets;

  ExerciseSet({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.icon,
    required this.unit,
    required this.sets,
  });
}

class SetEntry {
  String weight;
  String reps;
  bool done;
  SetEntry({this.weight = '', this.reps = '', this.done = false});
}

// ─────────────────────────────────────────────────────────────────────────────
// Log Workout Screen
// ─────────────────────────────────────────────────────────────────────────────
class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedType = 'Strength';
  String _selectedIcon = '💪';
  int _duration = 45;
  int _calories = 0;

  final List<ExerciseSet> _exercises = [];

  final _types = [
    {'label': 'Strength', 'icon': '🏋️'},
    {'label': 'Cardio', 'icon': '🏃'},
    {'label': 'Yoga', 'icon': '🧘'},
    {'label': 'Cycling', 'icon': '🚴'},
    {'label': 'HIIT', 'icon': '⚡'},
    {'label': 'Swimming', 'icon': '🏊'},
  ];

  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _pickExercise() async {
    final provider = context.read<AppProvider>();
    final catalog = (provider.data['exerciseCatalog'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExercisePickerSheet(catalog: catalog),
    );

    if (picked != null) {
      setState(() {
        _exercises.add(ExerciseSet(
          exerciseId: picked['id'] ?? '',
          exerciseName: picked['name'] ?? '',
          category: picked['category'] ?? '',
          icon: picked['icon'] ?? '💪',
          unit: picked['unit'] ?? 'reps',
          sets: [SetEntry(weight: '', reps: '')],
        ));
      });
    }
  }

  void _addSet(int exIdx) {
    setState(() => _exercises[exIdx].sets.add(SetEntry()));
  }

  void _removeSet(int exIdx, int setIdx) {
    setState(() {
      if (_exercises[exIdx].sets.length > 1) {
        _exercises[exIdx].sets.removeAt(setIdx);
      }
    });
  }

  void _removeExercise(int exIdx) {
    setState(() => _exercises.removeAt(exIdx));
  }

  void _toggleSetDone(int exIdx, int setIdx) {
    setState(() {
      _exercises[exIdx].sets[setIdx].done = !_exercises[exIdx].sets[setIdx].done;
    });
  }

  int get _totalSets =>
      _exercises.fold(0, (sum, ex) => sum + ex.sets.length);

  int get _doneSets =>
      _exercises.fold(0, (sum, ex) => sum + ex.sets.where((s) => s.done).length);

  Future<void> _saveWorkout() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a workout title'),
          backgroundColor: Color(AppColors.red),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    // Build workout map with consistent keys
    final tags = <String>[_selectedType];

    final workout = {
      'id': 'w_\${DateTime.now().millisecondsSinceEpoch}',
      'title': _titleCtrl.text.trim(),
      'name': _titleCtrl.text.trim(),
      'emoji': _selectedIcon,
      'icon': _selectedIcon,
      'type': _selectedType,
      'date': 'Today',
      'time': TimeOfDay.now().format(context),
      'tags': tags,
      'duration': _duration,
      'calories': _calories > 0 ? _calories : _estimateCalories(),
      'sets': _totalSets,
      'exerciseCount': _exercises.length,
      'exercises': _exercises.map((ex) => {
        'id': ex.exerciseId,
        'name': ex.exerciseName,
        'icon': ex.icon,
        'sets': ex.sets.map((s) => {
          'weight': s.weight,
          'reps': s.reps,
          'done': s.done,
        }).toList(),
      }).toList(),
      'notes': _notesCtrl.text.trim(),
    };

    await context.read<AppProvider>().addWorkout(workout);

    if (mounted) {
      setState(() => _saving = false);
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Text('✅ ', style: TextStyle(fontSize: 16)),
            Text('Workout logged! +${_estimatePoints()} points earned'),
          ]),
          backgroundColor: Color(AppColors.green),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop(true); // return true = workout saved
    }
  }

  int _estimateCalories() {
    // Simple estimate based on duration and type
    final rates = {'Strength': 6, 'Cardio': 10, 'HIIT': 12, 'Yoga': 3, 'Cycling': 9, 'Swimming': 11};
    return _duration * (rates[_selectedType] ?? 7);
  }

  int _estimatePoints() => 50 + (_exercises.length * 10) + (_doneSets * 2);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Color(AppColors.darkBg) : Color(AppColors.lightBg);
    final cardBg = isDark ? Color(AppColors.darkCard) : Color(AppColors.lightCard);
    final border = isDark ? Color(AppColors.darkBorder) : Color(AppColors.lightBorder);
    final muted = Color(AppColors.mutedDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? Color(AppColors.darkBg2) : Color(AppColors.lightCard),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => _confirmDiscard(context),
        ),
        title: const Text('Log Workout', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (_saving)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(AppColors.purple))),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _saveWorkout,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.lime),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Save',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      )),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        children: [

        // ── Progress bar ──────────────────────────────────────────────────
        if (_totalSets > 0) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$_doneSets / $_totalSets sets done',
                style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
            Text('${((_doneSets / _totalSets) * 100).round()}%',
                style: TextStyle(fontSize: 12, color: Color(AppColors.purple), fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: _totalSets == 0 ? 0 : _doneSets / _totalSets,
            backgroundColor: border,
            valueColor: AlwaysStoppedAnimation(Color(AppColors.purple)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 16),
        ],

        // ── Workout Title ─────────────────────────────────────────────────
        _SectionLabel('Workout Details'),
        const SizedBox(height: 10),
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
          Divider(color: border, height: 20),

          // Type picker
          Text('Type', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
            final selected = _selectedType == t['label'];
            return GestureDetector(
              onTap: () => setState(() {
                _selectedType = t['label']!;
                _selectedIcon = t['icon']!;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? Color(AppColors.purple) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? Color(AppColors.purple) : border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(t['icon']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(t['label']!,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : muted)),
                ]),
              ),
            );
          }).toList()),

          Divider(color: border, height: 24),

          // Duration + Calories
          Row(children: [
            Expanded(child: _NumericField(
              label: 'Duration (min)',
              value: _duration.toString(),
              icon: '⏱',
              onChanged: (v) => setState(() => _duration = int.tryParse(v) ?? _duration),
            )),
            const SizedBox(width: 12),
            Expanded(child: _NumericField(
              label: 'Calories (optional)',
              value: _calories == 0 ? '' : _calories.toString(),
              icon: '🔥',
              hint: 'Auto',
              onChanged: (v) => setState(() => _calories = int.tryParse(v) ?? 0),
            )),
          ]),
        ])),
        const SizedBox(height: 20),

        // ── Exercises ─────────────────────────────────────────────────────
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SectionLabel('Exercises (${_exercises.length})'),
          GestureDetector(
            onTap: _pickExercise,
            child: Row(children: [
              Icon(Icons.add_circle, color: Color(AppColors.purple), size: 18),
              const SizedBox(width: 4),
              Text('Add Exercise',
                  style: TextStyle(fontSize: 12, color: Color(AppColors.purple), fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),

        if (_exercises.isEmpty)
          _EmptyExercises(onTap: _pickExercise),

        for (int exIdx = 0; exIdx < _exercises.length; exIdx++)
          _ExerciseBlock(
            exercise: _exercises[exIdx],
            exIdx: exIdx,
            onAddSet: () => _addSet(exIdx),
            onRemoveSet: (setIdx) => _removeSet(exIdx, setIdx),
            onRemoveExercise: () => _removeExercise(exIdx),
            onToggleSet: (setIdx) => _toggleSetDone(exIdx, setIdx),
            onSetChanged: (setIdx, field, value) {
              setState(() {
                if (field == 'weight') _exercises[exIdx].sets[setIdx].weight = value;
                if (field == 'reps') _exercises[exIdx].sets[setIdx].reps = value;
              });
            },
          ),

        const SizedBox(height: 20),

        // ── Add Exercise Button ───────────────────────────────────────────
        GestureDetector(
          onTap: _pickExercise,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(AppColors.purple), style: BorderStyle.solid),
              color: Color(AppColors.purple).withOpacity(0.06),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.fitness_center, color: Color(AppColors.purple), size: 18),
              const SizedBox(width: 8),
              Text('+ Add Exercise',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(AppColors.purple))),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        // ── Notes ─────────────────────────────────────────────────────────
        _SectionLabel('Notes (optional)'),
        const SizedBox(height: 8),
        _Card(child: TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'How did it go? Any PRs today?',
            hintStyle: TextStyle(color: muted),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        )),
        const SizedBox(height: 32),

        // ── Save Button ───────────────────────────────────────────────────
        GestureDetector(
          onTap: _saving ? null : _saveWorkout,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _saving
                  ? const Color(AppColors.lime).withOpacity(0.5)
                  : const Color(AppColors.lime),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              _saving ? 'Saving...' : 'Save Workout  +${_estimatePoints()} pts',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    if (_titleCtrl.text.isEmpty && _exercises.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard Workout?'),
        content: const Text('Your workout progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Editing')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Discard', style: TextStyle(color: Color(AppColors.red))),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) Navigator.of(context).pop();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exercise Block Widget
// ─────────────────────────────────────────────────────────────────────────────
class _ExerciseBlock extends StatelessWidget {
  final ExerciseSet exercise;
  final int exIdx;
  final VoidCallback onAddSet;
  final Function(int) onRemoveSet;
  final VoidCallback onRemoveExercise;
  final Function(int) onToggleSet;
  final Function(int, String, String) onSetChanged;

  const _ExerciseBlock({
    required this.exercise, required this.exIdx,
    required this.onAddSet, required this.onRemoveSet,
    required this.onRemoveExercise, required this.onToggleSet,
    required this.onSetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? Color(AppColors.darkBorder) : Color(AppColors.lightBorder);
    final muted = Color(AppColors.mutedDark);
    final isCardio = exercise.unit != 'reps';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Color(AppColors.purple).withOpacity(0.08), blurRadius: 12)],
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(AppColors.purple2), Color(AppColors.accent)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(exercise.icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exercise.exerciseName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text(exercise.category,
                  style: TextStyle(fontSize: 11, color: Color(AppColors.purple))),
            ])),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Color(AppColors.red), size: 20),
              onPressed: onRemoveExercise,
            ),
          ]),
        ),

        // Column headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            SizedBox(width: 32, child: Text('SET', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Expanded(child: Text(isCardio ? exercise.unit.toUpperCase() : 'KG',
                style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Expanded(child: Text(isCardio ? 'TIME (min)' : 'REPS',
                style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            SizedBox(width: 36),
          ]),
        ),
        const SizedBox(height: 6),

        // Sets
        for (int setIdx = 0; setIdx < exercise.sets.length; setIdx++)
          _SetRow(
            setNum: setIdx + 1,
            entry: exercise.sets[setIdx],
            isCardio: isCardio,
            onToggle: () => onToggleSet(setIdx),
            onWeightChanged: (v) => onSetChanged(setIdx, 'weight', v),
            onRepsChanged: (v) => onSetChanged(setIdx, 'reps', v),
            onDelete: () => onRemoveSet(setIdx),
          ),

        // Add Set button
        TextButton.icon(
          onPressed: onAddSet,
          icon: Icon(Icons.add, size: 16, color: Color(AppColors.purple)),
          label: Text('Add Set',
              style: TextStyle(fontSize: 12, color: Color(AppColors.purple), fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Set Row
// ─────────────────────────────────────────────────────────────────────────────
class _SetRow extends StatelessWidget {
  final int setNum;
  final SetEntry entry;
  final bool isCardio;
  final VoidCallback onToggle;
  final Function(String) onWeightChanged;
  final Function(String) onRepsChanged;
  final VoidCallback onDelete;

  const _SetRow({
    required this.setNum, required this.entry, required this.isCardio,
    required this.onToggle, required this.onWeightChanged,
    required this.onRepsChanged, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doneBg = Color(AppColors.green).withOpacity(0.08);
    final normalBg = isDark ? Color(AppColors.darkBg2).withOpacity(0.5) : Color(AppColors.lightBg2);

    return GestureDetector(
      onLongPress: onDelete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: entry.done ? doneBg : normalBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: entry.done ? Color(AppColors.green).withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(children: [
          // Set number
          SizedBox(
            width: 32,
            child: Text('$setNum',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: entry.done ? Color(AppColors.green) : Color(AppColors.mutedDark))),
          ),
          const SizedBox(width: 8),
          // Weight/distance field
          Expanded(child: _InlineField(
            value: entry.weight,
            hint: isCardio ? '0' : '0',
            done: entry.done,
            onChanged: onWeightChanged,
          )),
          const SizedBox(width: 8),
          // Reps/time field
          Expanded(child: _InlineField(
            value: entry.reps,
            hint: isCardio ? '0' : '0',
            done: entry.done,
            onChanged: onRepsChanged,
          )),
          const SizedBox(width: 8),
          // Done toggle
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: entry.done ? Color(AppColors.green) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: entry.done ? Color(AppColors.green) : Color(AppColors.mutedDark),
                  width: 1.5,
                ),
              ),
              child: entry.done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ]),
      ),
    );
  }
}

class _InlineField extends StatelessWidget {
  final String value, hint;
  final bool done;
  final Function(String) onChanged;
  const _InlineField({required this.value, required this.hint, required this.done, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      enabled: !done,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: done ? Color(AppColors.green) : Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Color(AppColors.mutedDark)),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(AppColors.purple), width: 1)),
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        isDense: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exercise Picker Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ExercisePickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> catalog;
  const _ExercisePickerSheet({required this.catalog});

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  String _search = '';
  String _filterCat = 'All';

  List<String> get _categories {
    final cats = widget.catalog.map((e) => e['category'] as String).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<Map<String, dynamic>> get _filtered {
    return widget.catalog.where((e) {
      final matchSearch = _search.isEmpty ||
          (e['name'] as String).toLowerCase().contains(_search.toLowerCase());
      final matchCat = _filterCat == 'All' || e['category'] == _filterCat;
      return matchSearch && matchCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? Color(AppColors.darkCard) : Color(AppColors.lightCard),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: Color(AppColors.mutedDark).withOpacity(0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Expanded(child: Text('Add Exercise',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ]),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search exercises...',
              prefixIcon: Icon(Icons.search, color: Color(AppColors.mutedDark)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Category chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _categories.map((cat) {
              final selected = _filterCat == cat;
              return GestureDetector(
                onTap: () => setState(() => _filterCat = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? Color(AppColors.purple) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected ? Color(AppColors.purple) : Color(AppColors.darkBorder)),
                  ),
                  child: Text(cat,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Color(AppColors.mutedDark))),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // Exercise list
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Text('No exercises found',
                  style: TextStyle(color: Color(AppColors.mutedDark))))
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 0, 16,
                      MediaQuery.of(context).padding.bottom + 16),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final ex = _filtered[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      leading: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Color(AppColors.purple).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text(ex['icon'] ?? '💪',
                            style: const TextStyle(fontSize: 20))),
                      ),
                      title: Text(ex['name'] ?? '',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('${ex['category']} · ${ex['unit']}',
                          style: TextStyle(fontSize: 11, color: Color(AppColors.purple))),
                      trailing: Icon(Icons.add_circle_outline, color: Color(AppColors.purple)),
                      onTap: () => Navigator.pop(context, ex),
                    );
                  },
                ),
        ),
      ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: Color(AppColors.mutedDark), letterSpacing: 0.3));
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
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
}

class _NumericField extends StatelessWidget {
  final String label, value, icon;
  final String? hint;
  final Function(String) onChanged;
  const _NumericField({required this.label, required this.value, required this.icon, this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, color: Color(AppColors.mutedDark), fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      TextFormField(
        initialValue: value,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hint ?? '0',
          prefixText: '$icon  ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    ]);
  }
}

class _EmptyExercises extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyExercises({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Color(AppColors.darkBorder), style: BorderStyle.solid),
        ),
        child: Column(children: [
          Icon(Icons.fitness_center, size: 40, color: Color(AppColors.mutedDark)),
          const SizedBox(height: 10),
          Text('No exercises added yet',
              style: TextStyle(fontSize: 13, color: Color(AppColors.mutedDark))),
          const SizedBox(height: 4),
          Text('Tap to add exercises',
              style: TextStyle(fontSize: 11, color: Color(AppColors.purple), fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

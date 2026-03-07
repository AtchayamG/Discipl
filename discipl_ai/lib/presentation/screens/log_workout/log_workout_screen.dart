import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

// ─── Data models (unchanged) ──────────────────────────────────────────────────
class ExerciseSet {
  final String exerciseId, exerciseName, category, icon, unit;
  List<SetEntry> sets;
  ExerciseSet({required this.exerciseId, required this.exerciseName, required this.category, required this.icon, required this.unit, required this.sets});
}

class SetEntry {
  String weight, reps;
  bool done;
  SetEntry({this.weight = '', this.reps = '', this.done = false});
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});
  @override State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _selectedType = 'Strength';
  String _selectedIcon = '🏋️';
  int _duration = 45;
  int _calories = 0;
  final List<ExerciseSet> _exercises = [];
  bool _saving = false;

  final _types = [
    {'label': 'Strength', 'icon': '🏋️'},
    {'label': 'Cardio',   'icon': '🏃'},
    {'label': 'Yoga',     'icon': '🧘'},
    {'label': 'Cycling',  'icon': '🚴'},
    {'label': 'HIIT',     'icon': '⚡'},
    {'label': 'Swimming', 'icon': '🏊'},
  ];

  @override
  void dispose() { _titleCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  int get _totalSets => _exercises.fold(0, (s, ex) => s + ex.sets.length);
  int get _doneSets  => _exercises.fold(0, (s, ex) => s + ex.sets.where((e) => e.done).length);
  int _estimateCalories() => _duration * ({'Strength': 6, 'Cardio': 10, 'HIIT': 12, 'Yoga': 3, 'Cycling': 9, 'Swimming': 11}[_selectedType] ?? 7);
  int _estimatePoints() => 50 + (_exercises.length * 10) + (_doneSets * 2);

  void _pickExercise() async {
    final catalog = (context.read<AppProvider>().data['exerciseCatalog'] as List? ?? []).cast<Map<String, dynamic>>();
    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _ExercisePicker(catalog: catalog));
    if (picked != null) setState(() => _exercises.add(ExerciseSet(
      exerciseId: picked['id'] ?? '', exerciseName: picked['name'] ?? '',
      category: picked['category'] ?? '', icon: picked['icon'] ?? '💪',
      unit: picked['unit'] ?? 'reps', sets: [SetEntry()])));
  }

  Future<void> _saveWorkout() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a workout title'), backgroundColor: Color(AppColors.red)));
      return;
    }
    setState(() => _saving = true);
    final tags = <String>{_selectedType}..addAll(_exercises.map((e) => e.category));
    await context.read<AppProvider>().addWorkout({
      'id': 'w_${DateTime.now().millisecondsSinceEpoch}',
      'title': _titleCtrl.text.trim(), 'icon': _selectedIcon,
      'date': 'Today', 'time': TimeOfDay.now().format(context),
      'tags': tags.toList(), 'duration': _duration,
      'calories': _calories > 0 ? _calories : _estimateCalories(),
      'sets': _totalSets,
      'exercises': _exercises.map((ex) => {'id': ex.exerciseId, 'name': ex.exerciseName, 'icon': ex.icon,
        'sets': ex.sets.map((s) => {'weight': s.weight, 'reps': s.reps, 'done': s.done}).toList()}).toList(),
      'notes': _notesCtrl.text.trim(),
    });
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅ Workout logged! +${_estimatePoints()} points earned'),
        backgroundColor: const Color(AppColors.lime)));
      Navigator.of(context).pop(); // back to Workouts
    }
  }

  Future<void> _confirmDiscard() async {
    if (_titleCtrl.text.isEmpty && _exercises.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Discard Workout?'),
      content: const Text('Your workout progress will be lost.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Editing')),
        TextButton(onPressed: () => Navigator.pop(context, true),
          child: const Text('Discard', style: TextStyle(color: Color(AppColors.red)))),
      ]));
    if (ok == true && mounted) Navigator.of(context).pop(); // back to Workouts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.bg),
      appBar: AppBar(
        backgroundColor: const Color(AppColors.bg2),
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: TC.of(context).textPrimary), onPressed: _confirmDiscard),
        title: Text('Log Workout', style: TextStyle(fontFamily: AppTypography.displayFont, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary)),
        actions: [
          _saving
            ? Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: TC.of(context).lime)))
            : Padding(padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton(onPressed: _saveWorkout, child: const Text('Save'))),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Progress bar
        if (_totalSets > 0) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$_doneSets / $_totalSets sets done', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textMuted)),
            Text('${_totalSets == 0 ? 0 : ((_doneSets / _totalSets) * 100).round()}%',
              style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700, color: TC.of(context).lime)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
            value: _totalSets == 0 ? 0 : _doneSets / _totalSets, minHeight: 5,
            backgroundColor: Color(AppColors.surface), color: TC.of(context).lime)),
          const SizedBox(height: 16),
        ],

        // Workout details card
        const _Label('WORKOUT DETAILS'),
        const SizedBox(height: 8),
        _WCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _titleCtrl,
            style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 16, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary),
            decoration: const InputDecoration(hintText: 'e.g. Morning Upper Body', filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, contentPadding: EdgeInsets.zero)),
          const Divider(color: Color(AppColors.border), height: 20),
          Text('Type', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
            final sel = _selectedType == t['label'];
            return GestureDetector(
              onTap: () => setState(() { _selectedType = t['label']!; _selectedIcon = t['icon']!; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? const Color(AppColors.lime) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? const Color(AppColors.lime) : const Color(AppColors.border))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(t['icon']!, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(t['label']!, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w600,
                    color: sel ? const Color(AppColors.bg) : const Color(AppColors.textMuted))),
                ])));
          }).toList()),
          const Divider(color: Color(AppColors.border), height: 24),
          Row(children: [
            Expanded(child: _NumField(label: 'Duration (min)', value: _duration.toString(), icon: '⏱',
              onChanged: (v) => setState(() => _duration = int.tryParse(v) ?? _duration))),
            const SizedBox(width: 12),
            Expanded(child: _NumField(label: 'Calories (optional)', value: _calories == 0 ? '' : _calories.toString(), icon: '🔥', hint: 'Auto',
              onChanged: (v) => setState(() => _calories = int.tryParse(v) ?? 0))),
          ]),
        ])),
        const SizedBox(height: 20),

        // Exercises
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _Label('EXERCISES (${_exercises.length})'),
          GestureDetector(onTap: _pickExercise, child: Row(children: [
            Icon(Icons.add_circle, color: TC.of(context).lime, size: 17),
            const SizedBox(width: 4),
            Text('Add Exercise', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, color: TC.of(context).lime, fontWeight: FontWeight.w600)),
          ])),
        ]),
        const SizedBox(height: 8),

        if (_exercises.isEmpty) _EmptyEx(onTap: _pickExercise),

        for (int i = 0; i < _exercises.length; i++)
          _ExBlock(
            exercise: _exercises[i], exIdx: i,
            onAddSet:        () => setState(() => _exercises[i].sets.add(SetEntry())),
            onRemoveSet:     (si) => setState(() { if (_exercises[i].sets.length > 1) _exercises[i].sets.removeAt(si); }),
            onRemoveEx:      () => setState(() => _exercises.removeAt(i)),
            onToggle:        (si) => setState(() => _exercises[i].sets[si].done = !_exercises[i].sets[si].done),
            onSetChanged:    (si, f, v) => setState(() { if (f == 'weight') _exercises[i].sets[si].weight = v; else _exercises[i].sets[si].reps = v; }),
          ),

        const SizedBox(height: 12),
        GestureDetector(onTap: _pickExercise, child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: TC.of(context).limeBorder), color: Color(AppColors.limeAlpha12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.fitness_center, color: TC.of(context).lime, size: 17),
            SizedBox(width: 8),
            Text('+ Add Exercise', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w600, color: TC.of(context).lime)),
          ]),
        )),
        const SizedBox(height: 20),

        // Notes
        const _Label('NOTES (OPTIONAL)'),
        const SizedBox(height: 8),
        _WCard(child: TextField(
          controller: _notesCtrl, maxLines: 3,
          style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: TC.of(context).textPrimary),
          decoration: const InputDecoration(hintText: 'How did it go? Any PRs today?', filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, contentPadding: EdgeInsets.zero))),
        const SizedBox(height: 24),

        // Save button
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _saving ? null : _saveWorkout,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: Text(_saving ? 'Saving...' : '✅  Save Workout  +${_estimatePoints()} pts',
            style: const TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w700)))),
        const SizedBox(height: 40),
      ]),
    );
  }
}

// ─── Exercise Block ───────────────────────────────────────────────────────────
class _ExBlock extends StatelessWidget {
  final ExerciseSet exercise;
  final int exIdx;
  final VoidCallback onAddSet, onRemoveEx;
  final Function(int) onRemoveSet, onToggle;
  final Function(int, String, String) onSetChanged;

  const _ExBlock({required this.exercise, required this.exIdx, required this.onAddSet,
    required this.onRemoveSet, required this.onRemoveEx, required this.onToggle, required this.onSetChanged});

  @override
  Widget build(BuildContext context) {
    final isCardio = exercise.unit != 'reps';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: TC.of(context).cardBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).border)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 12, 8, 12), child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: TC.of(context).limeBorder)),
            child: Center(child: Text(exercise.icon, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise.exerciseName, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary)),
            Text(exercise.category, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).lime)),
          ])),
          IconButton(icon: const Icon(Icons.delete_outline, color: Color(AppColors.red), size: 20), onPressed: onRemoveEx),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [
          SizedBox(width: 32, child: Text('SET', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 9, color: TC.of(context).textMuted2, fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          Expanded(child: Text(isCardio ? exercise.unit.toUpperCase() : 'KG',
            style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 9, color: TC.of(context).textMuted2, fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          Expanded(child: Text(isCardio ? 'TIME (min)' : 'REPS',
            style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 9, color: TC.of(context).textMuted2, fontWeight: FontWeight.w700))),
          const SizedBox(width: 44),
        ])),
        const SizedBox(height: 6),
        for (int si = 0; si < exercise.sets.length; si++)
          _SetRow(setNum: si + 1, entry: exercise.sets[si], isCardio: isCardio,
            onToggle: () => onToggle(si),
            onWt: (v) => onSetChanged(si, 'weight', v),
            onReps: (v) => onSetChanged(si, 'reps', v),
            onDelete: () => onRemoveSet(si)),
        TextButton.icon(
          onPressed: onAddSet,
          icon: Icon(Icons.add, size: 15, color: TC.of(context).lime),
          label: Text('Add Set', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, color: TC.of(context).lime, fontWeight: FontWeight.w600))),
        const SizedBox(height: 4),
      ]),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int setNum;
  final SetEntry entry;
  final bool isCardio;
  final VoidCallback onToggle, onDelete;
  final Function(String) onWt, onReps;
  const _SetRow({required this.setNum, required this.entry, required this.isCardio, required this.onToggle, required this.onWt, required this.onReps, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: entry.done ? const Color(AppColors.limeAlpha12) : const Color(AppColors.bg3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: entry.done ? const Color(AppColors.limeAlpha20) : Colors.transparent)),
        child: Row(children: [
          SizedBox(width: 32, child: Text('$setNum', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w700,
            color: entry.done ? const Color(AppColors.lime) : const Color(AppColors.textMuted)))),
          const SizedBox(width: 8),
          Expanded(child: _InlineField(value: entry.weight, done: entry.done, onChanged: onWt)),
          const SizedBox(width: 8),
          Expanded(child: _InlineField(value: entry.reps, done: entry.done, onChanged: onReps)),
          const SizedBox(width: 8),
          GestureDetector(onTap: onToggle, child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: entry.done ? const Color(AppColors.lime) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: entry.done ? const Color(AppColors.lime) : const Color(AppColors.border), width: 1.5)),
            child: entry.done ? const Icon(Icons.check, size: 16, color: Color(AppColors.bg)) : null)),
        ]),
      ),
    );
  }
}

class _InlineField extends StatelessWidget {
  final String value;
  final bool done;
  final Function(String) onChanged;
  const _InlineField({required this.value, required this.done, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value, onChanged: onChanged,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
    enabled: !done, textAlign: TextAlign.center,
    style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w600,
      color: done ? const Color(AppColors.lime) : const Color(AppColors.textPrimary)),
    decoration: InputDecoration(
      hintText: '0', hintStyle: TextStyle(color: TC.of(context).textMuted2),
      filled: false,
      border: InputBorder.none, enabledBorder: InputBorder.none,
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: TC.of(context).lime, width: 1)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), isDense: true));
}

// ─── Exercise Picker ──────────────────────────────────────────────────────────
class _ExercisePicker extends StatefulWidget {
  final List<Map<String, dynamic>> catalog;
  const _ExercisePicker({required this.catalog});
  @override State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  String _search = '';
  String _cat = 'All';

  List<String> get _cats => ['All', ...widget.catalog.map((e) => e['category'] as String).toSet().toList()..sort()];
  List<Map<String, dynamic>> get _filtered => widget.catalog.where((e) {
    final ms = _search.isEmpty || (e['name'] as String).toLowerCase().contains(_search.toLowerCase());
    final mc = _cat == 'All' || e['category'] == _cat;
    return ms && mc;
  }).toList();

  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.85,
    decoration: const BoxDecoration(color: Color(AppColors.bg2), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: Column(children: [
      Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4,
        decoration: BoxDecoration(color: TC.of(context).border2, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 14),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        Expanded(child: Text('Add Exercise', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 17, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary))),
        IconButton(icon: Icon(Icons.close, color: TC.of(context).textMuted), onPressed: () => Navigator.pop(context)),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: TextStyle(fontFamily: AppTypography.bodyFont, color: TC.of(context).textPrimary),
        decoration: InputDecoration(hintText: 'Search exercises...', prefixIcon: Icon(Icons.search_rounded, color: TC.of(context).textMuted, size: 20)))),
      const SizedBox(height: 10),
      SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _cats.map((cat) {
          final sel = _cat == cat;
          return GestureDetector(onTap: () => setState(() => _cat = cat), child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: sel ? const Color(AppColors.lime) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? const Color(AppColors.lime) : const Color(AppColors.border))),
            child: Text(cat, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w600,
              color: sel ? const Color(AppColors.bg) : const Color(AppColors.textMuted)))));
        }).toList())),
      const SizedBox(height: 10),
      Expanded(child: _filtered.isEmpty
        ? Center(child: EmptyState(emoji: '🔍', title: 'No exercises found', subtitle: 'Try a different search'))
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final ex = _filtered[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                leading: Container(width: 42, height: 42,
                  decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(ex['icon'] ?? '💪', style: const TextStyle(fontSize: 20)))),
                title: Text(ex['name'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w600, color: TC.of(context).textPrimary)),
                subtitle: Text('${ex['category']} · ${ex['unit']}', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).lime)),
                trailing: Icon(Icons.add_circle_outline, color: TC.of(context).lime),
                onTap: () => Navigator.pop(context, ex),
              );
            })),
    ]));
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, fontWeight: FontWeight.w700, color: TC.of(context).textMuted2, letterSpacing: 1));
}

class _WCard extends StatelessWidget {
  final Widget child;
  const _WCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: TC.of(context).cardBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).border)),
    child: child);
}

class _NumField extends StatelessWidget {
  final String label, value, icon;
  final String? hint;
  final Function(String) onChanged;
  const _NumField({required this.label, required this.value, required this.icon, this.hint, required this.onChanged});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted2, fontWeight: FontWeight.w500)),
    const SizedBox(height: 4),
    TextFormField(initialValue: value, onChanged: onChanged, keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(fontFamily: AppTypography.displayFont, color: TC.of(context).textPrimary),
      decoration: InputDecoration(hintText: hint ?? '0', prefixText: '$icon  '))]);
}

class _EmptyEx extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyEx({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32), margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: TC.of(context).border)),
    child: Column(children: [
      Icon(Icons.fitness_center, size: 40, color: TC.of(context).textMuted),
      SizedBox(height: 10),
      Text('No exercises added yet', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: TC.of(context).textMuted)),
      SizedBox(height: 4),
      Text('Tap to add exercises', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, color: TC.of(context).lime, fontWeight: FontWeight.w600)),
    ])));
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

// ─── Habit category model ─────────────────────────────────────────────────────
class _HabitTemplate {
  final String name, emoji, category, defaultTime;
  final int defaultPoints;
  const _HabitTemplate({
    required this.name, required this.emoji, required this.category,
    required this.defaultTime, required this.defaultPoints,
  });
}

const _templates = [
  _HabitTemplate(name: 'Drink 3L Water',    emoji: '💧', category: 'Health',    defaultTime: 'Morning',   defaultPoints: 20),
  _HabitTemplate(name: '10,000 Steps',       emoji: '🚶', category: 'Fitness',   defaultTime: 'Anytime',   defaultPoints: 25),
  _HabitTemplate(name: 'Meditate',           emoji: '🧘', category: 'Mindset',   defaultTime: 'Morning',   defaultPoints: 15),
  _HabitTemplate(name: 'Read 20 Minutes',    emoji: '📖', category: 'Learning',  defaultTime: 'Evening',   defaultPoints: 15),
  _HabitTemplate(name: 'No Sugar',           emoji: '🚫', category: 'Nutrition', defaultTime: 'All Day',   defaultPoints: 30),
  _HabitTemplate(name: 'Sleep by 10PM',      emoji: '😴', category: 'Sleep',     defaultTime: 'Night',     defaultPoints: 20),
  _HabitTemplate(name: 'Cold Shower',        emoji: '🚿', category: 'Fitness',   defaultTime: 'Morning',   defaultPoints: 25),
  _HabitTemplate(name: 'Journal',            emoji: '✍️', category: 'Mindset',   defaultTime: 'Evening',   defaultPoints: 10),
  _HabitTemplate(name: 'No Phone Morning',   emoji: '📵', category: 'Mindset',   defaultTime: 'Morning',   defaultPoints: 20),
  _HabitTemplate(name: 'Workout',            emoji: '💪', category: 'Fitness',   defaultTime: 'Morning',   defaultPoints: 30),
  _HabitTemplate(name: 'Healthy Meal',       emoji: '🥗', category: 'Nutrition', defaultTime: 'Lunch',     defaultPoints: 20),
  _HabitTemplate(name: 'Vitamins/Meds',      emoji: '💊', category: 'Health',    defaultTime: 'Morning',   defaultPoints: 10),
];

const _categories = ['All', 'Health', 'Fitness', 'Mindset', 'Nutrition', 'Sleep', 'Learning'];
const _times      = ['Morning', 'Afternoon', 'Evening', 'Night', 'Anytime', 'All Day'];
const _frequencies = ['Daily', 'Weekdays', 'Weekends', '3× Week', '4× Week', 'Custom'];
const _emojis = ['💧','🚶','🧘','📖','🚫','😴','🚿','✍️','📵','💪','🥗','💊','🏃','🎯','📝','🌅','🧠','❤️','🏋️','🎵'];

// ─── Add Habit Screen ─────────────────────────────────────────────────────────
class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});
  @override State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // Form state
  final _nameCtrl = TextEditingController();
  String _selectedEmoji = '🎯';
  String _selectedTime = 'Morning';
  String _selectedFreq = 'Daily';
  String _selectedCategory = 'Health';
  int _targetPoints = 20;
  bool _saving = false;

  // Template filter
  String _filterCat = 'All';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _applyTemplate(_HabitTemplate t) {
    setState(() {
      _nameCtrl.text = t.name;
      _selectedEmoji = t.emoji;
      _selectedTime = t.defaultTime;
      _selectedCategory = t.category;
      _targetPoints = t.defaultPoints;
    });
    _tabs.animateTo(1); // switch to custom tab to review/edit
  }

  Future<void> _saveHabit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter a habit name'),
        backgroundColor: Color(AppColors.red),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _saving = true);
    final habit = {
      'id': 'h_${DateTime.now().millisecondsSinceEpoch}',
      'name': '$_selectedEmoji $name',
      'emoji': _selectedEmoji,
      'frequency': _selectedFreq,
      'time': _selectedTime,
      'category': _selectedCategory,
      'points': _targetPoints,
      'streak': 0,
      'completed': false,
      'isNew': true,
    };

    await context.read<AppProvider>().addHabit(habit);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('Habit "$name" added! 🎉'),
        ]),
        backgroundColor: Color(AppColors.green),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard(context);
      },
      child: Scaffold(
        backgroundColor:
            isDark ? Color(AppColors.darkBg) : Color(AppColors.lightBg),
        appBar: AppBar(
          backgroundColor:
              isDark ? Color(AppColors.darkBg2) : Color(AppColors.lightCard),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmDiscard(context),
          ),
          title: const Text('Add Habit',
              style: TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : GradientButton(label: 'Save', onTap: _saveHabit),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            labelColor: Color(AppColors.purple),
            unselectedLabelColor: Color(AppColors.mutedDark),
            indicatorColor: Color(AppColors.purple),
            indicatorWeight: 2.5,
            tabs: const [
              Tab(icon: Icon(Icons.grid_view_rounded, size: 18), text: 'Templates'),
              Tab(icon: Icon(Icons.edit_outlined, size: 18), text: 'Custom'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _TemplatesTab(
              filterCat: _filterCat,
              onFilterChanged: (c) => setState(() => _filterCat = c),
              onSelect: _applyTemplate,
            ),
            _CustomTab(
              nameCtrl: _nameCtrl,
              selectedEmoji: _selectedEmoji,
              selectedTime: _selectedTime,
              selectedFreq: _selectedFreq,
              selectedCategory: _selectedCategory,
              targetPoints: _targetPoints,
              onEmojiChanged: (e) => setState(() => _selectedEmoji = e),
              onTimeChanged: (t) => setState(() => _selectedTime = t),
              onFreqChanged: (f) => setState(() => _selectedFreq = f),
              onCategoryChanged: (c) => setState(() => _selectedCategory = c),
              onPointsChanged: (p) => setState(() => _targetPoints = p),
              onSave: _saveHabit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    if (_nameCtrl.text.isEmpty) { Navigator.of(context).pop(); return; }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard Habit?'),
        content: const Text('Your changes will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Editing')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Discard', style: TextStyle(color: Color(AppColors.red))),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) Navigator.of(context).pop();
  }
}

// ─── Templates Tab ────────────────────────────────────────────────────────────
class _TemplatesTab extends StatelessWidget {
  final String filterCat;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<_HabitTemplate> onSelect;
  const _TemplatesTab({required this.filterCat, required this.onFilterChanged, required this.onSelect});

  List<_HabitTemplate> get _filtered => filterCat == 'All'
      ? _templates
      : _templates.where((t) => t.category == filterCat).toList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Category filter chips
      SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: _categories.map((cat) {
            final sel = filterCat == cat;
            return GestureDetector(
              onTap: () => onFilterChanged(cat),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: sel ? Color(AppColors.purple) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel ? Color(AppColors.purple) : Color(AppColors.darkBorder)),
                ),
                child: Text(cat,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : Color(AppColors.mutedDark))),
              ),
            );
          }).toList(),
        ),
      ),

      // Template grid
      Expanded(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 4, 16,
              MediaQuery.of(context).padding.bottom + 16),
          itemCount: _filtered.length,
          itemBuilder: (_, i) {
            final t = _filtered[i];
            return _TemplateCard(template: t, onSelect: () => onSelect(t));
          },
        ),
      ),
    ]);
  }
}

class _TemplateCard extends StatelessWidget {
  final _HabitTemplate template;
  final VoidCallback onSelect;
  const _TemplateCard({required this.template, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [BoxShadow(
              color: Color(AppColors.purple).withOpacity(0.06), blurRadius: 10)],
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(AppColors.purple2), Color(AppColors.accent)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(template.emoji,
                style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(template.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Row(children: [
              _Chip(template.category, Color(AppColors.purple)),
              const SizedBox(width: 6),
              _Chip(template.defaultTime, Color(AppColors.mutedDark)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Color(AppColors.green).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('+${template.defaultPoints} pts',
                  style: TextStyle(fontSize: 11, color: Color(AppColors.green),
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 6),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(AppColors.mutedDark)),
          ]),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(label, style: TextStyle(
        fontSize: 10, color: color, fontWeight: FontWeight.w600)),
  );
}

// ─── Custom Tab ───────────────────────────────────────────────────────────────
class _CustomTab extends StatelessWidget {
  final TextEditingController nameCtrl;
  final String selectedEmoji, selectedTime, selectedFreq, selectedCategory;
  final int targetPoints;
  final ValueChanged<String> onEmojiChanged, onTimeChanged, onFreqChanged, onCategoryChanged;
  final ValueChanged<int> onPointsChanged;
  final VoidCallback onSave;

  const _CustomTab({
    required this.nameCtrl, required this.selectedEmoji,
    required this.selectedTime, required this.selectedFreq,
    required this.selectedCategory, required this.targetPoints,
    required this.onEmojiChanged, required this.onTimeChanged,
    required this.onFreqChanged, required this.onCategoryChanged,
    required this.onPointsChanged, required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Color(AppColors.mutedDark);

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16,
          MediaQuery.of(context).padding.bottom + 24),
      children: [

        // ── Preview card ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(AppColors.purple2).withOpacity(0.6),
                         Color(AppColors.accent).withOpacity(0.4)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Text(selectedEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                nameCtrl.text.isEmpty ? 'Your habit name...' : nameCtrl.text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: nameCtrl.text.isEmpty ? Colors.white54 : Colors.white),
              ),
              const SizedBox(height: 2),
              Text('$selectedFreq · $selectedTime · +$targetPoints pts',
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ])),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Name ─────────────────────────────────────────────────────────
        _Label('Habit Name'),
        const SizedBox(height: 6),
        _Card(child: TextField(
          controller: nameCtrl,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'e.g. Drink 3L Water',
            hintStyle: TextStyle(color: muted),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        )),
        const SizedBox(height: 16),

        // ── Emoji picker ─────────────────────────────────────────────────
        _Label('Icon'),
        const SizedBox(height: 8),
        _Card(child: Wrap(
          spacing: 8, runSpacing: 8,
          children: _emojis.map((e) => GestureDetector(
            onTap: () => onEmojiChanged(e),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: e == selectedEmoji
                    ? Color(AppColors.purple).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: e == selectedEmoji
                        ? Color(AppColors.purple)
                        : Colors.transparent,
                    width: 2),
              ),
              child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
            ),
          )).toList(),
        )),
        const SizedBox(height: 16),

        // ── Frequency ────────────────────────────────────────────────────
        _Label('Frequency'),
        const SizedBox(height: 8),
        _OptionRow(
          options: _frequencies,
          selected: selectedFreq,
          onSelect: onFreqChanged,
        ),
        const SizedBox(height: 16),

        // ── Time of day ──────────────────────────────────────────────────
        _Label('Time of Day'),
        const SizedBox(height: 8),
        _OptionRow(
          options: _times,
          selected: selectedTime,
          onSelect: onTimeChanged,
        ),
        const SizedBox(height: 16),

        // ── Category ─────────────────────────────────────────────────────
        _Label('Category'),
        const SizedBox(height: 8),
        _OptionRow(
          options: _categories.where((c) => c != 'All').toList(),
          selected: selectedCategory,
          onSelect: onCategoryChanged,
        ),
        const SizedBox(height: 16),

        // ── Points ───────────────────────────────────────────────────────
        _Label('Points Reward  (+$targetPoints pts per completion)'),
        const SizedBox(height: 8),
        _Card(child: Column(children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Color(AppColors.purple),
              inactiveTrackColor: Color(AppColors.darkBorder),
              thumbColor: Color(AppColors.purple),
              overlayColor: Color(AppColors.purple).withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: targetPoints.toDouble(),
              min: 5, max: 50, divisions: 9,
              onChanged: (v) => onPointsChanged(v.round()),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('5 pts', style: TextStyle(fontSize: 11, color: muted)),
            Text('50 pts', style: TextStyle(fontSize: 11, color: muted)),
          ]),
        ])),
        const SizedBox(height: 28),

        // ── Save button ──────────────────────────────────────────────────
        GradientButton(
          label: '✅  Add Habit  (+$targetPoints pts/day)',
          onTap: onSave,
          width: double.infinity,
        ),
      ],
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: Color(AppColors.mutedDark), letterSpacing: 0.3));
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).dividerColor),
      boxShadow: [BoxShadow(color: Color(AppColors.purple).withOpacity(0.06), blurRadius: 10)],
    ),
    child: child,
  );
}

class _OptionRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _OptionRow({required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: options.map((o) {
      final sel = o == selected;
      return GestureDetector(
        onTap: () => onSelect(o),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? Color(AppColors.purple) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: sel ? Color(AppColors.purple) : Color(AppColors.darkBorder)),
          ),
          child: Text(o, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: sel ? Colors.white : Color(AppColors.mutedDark))),
        ),
      );
    }).toList(),
  );
}

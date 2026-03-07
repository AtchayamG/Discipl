import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────
class _Tpl { final String name, emoji, category, defaultTime; final int pts;
  const _Tpl({required this.name, required this.emoji, required this.category, required this.defaultTime, required this.pts});
}
const _templates = [
  _Tpl(name: 'Drink 3L Water',  emoji: '💧', category: 'Health',    defaultTime: 'Morning', pts: 20),
  _Tpl(name: '10,000 Steps',     emoji: '🚶', category: 'Fitness',   defaultTime: 'Anytime', pts: 25),
  _Tpl(name: 'Meditate',         emoji: '🧘', category: 'Mindset',   defaultTime: 'Morning', pts: 15),
  _Tpl(name: 'Read 20 Minutes',  emoji: '📖', category: 'Learning',  defaultTime: 'Evening', pts: 15),
  _Tpl(name: 'No Sugar',         emoji: '🚫', category: 'Nutrition', defaultTime: 'All Day', pts: 30),
  _Tpl(name: 'Sleep by 10PM',    emoji: '😴', category: 'Sleep',     defaultTime: 'Night',   pts: 20),
  _Tpl(name: 'Cold Shower',      emoji: '🚿', category: 'Fitness',   defaultTime: 'Morning', pts: 25),
  _Tpl(name: 'Journal',          emoji: '✍️', category: 'Mindset',   defaultTime: 'Evening', pts: 10),
  _Tpl(name: 'No Phone Morning', emoji: '📵', category: 'Mindset',   defaultTime: 'Morning', pts: 20),
  _Tpl(name: 'Workout',          emoji: '💪', category: 'Fitness',   defaultTime: 'Morning', pts: 30),
  _Tpl(name: 'Healthy Meal',     emoji: '🥗', category: 'Nutrition', defaultTime: 'Lunch',   pts: 20),
  _Tpl(name: 'Vitamins/Meds',    emoji: '💊', category: 'Health',    defaultTime: 'Morning', pts: 10),
];
const _cats  = ['All', 'Health', 'Fitness', 'Mindset', 'Nutrition', 'Sleep', 'Learning'];
const _times = ['Morning', 'Afternoon', 'Evening', 'Night', 'Anytime', 'All Day'];
const _freqs = ['Daily', 'Weekdays', 'Weekends', '3× Week', '4× Week', 'Custom'];
const _emojis = ['💧','🚶','🧘','📖','🚫','😴','🚿','✍️','📵','💪','🥗','💊','🏃','🎯','📝','🌅','🧠','❤️','🏋️','🎵'];

// ─── Screen ───────────────────────────────────────────────────────────────────
class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});
  @override State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _nameCtrl = TextEditingController();
  String _emoji    = '🎯';
  String _time     = 'Morning';
  String _freq     = 'Daily';
  String _cat      = 'Health';
  String _filterCat = 'All';
  int    _pts      = 20;
  bool   _saving   = false;

  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); _nameCtrl.dispose(); super.dispose(); }

  void _applyTemplate(_Tpl t) {
    setState(() { _nameCtrl.text = t.name; _emoji = t.emoji; _time = t.defaultTime; _cat = t.category; _pts = t.pts; });
    _tabs.animateTo(1);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a habit name'), backgroundColor: Color(AppColors.red)));
      return;
    }
    setState(() => _saving = true);
    await context.read<AppProvider>().addHabit({
      'id': 'h_${DateTime.now().millisecondsSinceEpoch}',
      'name': name, 'emoji': _emoji,
      'frequency': _freq, 'time': _time, 'category': _cat,
      'points': _pts, 'streak': 0, 'completed': false, 'isNew': true,
    });
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎉 "$name" added!'), backgroundColor: const Color(AppColors.lime)));
      Navigator.of(context).pop();
    }
  }

  Future<void> _discard() async {
    if (_nameCtrl.text.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Discard Habit?'), content: const Text('Your changes will be lost.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Editing')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Discard', style: TextStyle(color: Color(AppColors.red)))),
      ]));
    if (ok == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: const Color(AppColors.bg),
      appBar: AppBar(
        backgroundColor: const Color(AppColors.bg2),
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: TC.of(context).textPrimary), onPressed: _discard),
        title: Text('Add Habit', style: TextStyle(fontFamily: AppTypography.displayFont, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12),
            child: _saving
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: TC.of(context).lime))
              : ElevatedButton(onPressed: _save, child: const Text('Save'))),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: const Color(AppColors.lime),
          unselectedLabelColor: const Color(AppColors.textMuted),
          indicatorColor: const Color(AppColors.lime),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontFamily: AppTypography.displayFont, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.grid_view_rounded, size: 17), text: 'Templates'),
            Tab(icon: Icon(Icons.edit_outlined, size: 17), text: 'Custom'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [
        _TemplatesTab(filterCat: _filterCat, onFilter: (c) => setState(() => _filterCat = c), onSelect: _applyTemplate),
        _CustomTab(
          nameCtrl: _nameCtrl, emoji: _emoji, time: _time, freq: _freq, cat: _cat, pts: _pts,
          onEmoji: (e) => setState(() => _emoji = e),
          onTime:  (t) => setState(() => _time  = t),
          onFreq:  (f) => setState(() => _freq  = f),
          onCat:   (c) => setState(() => _cat   = c),
          onPts:   (p) => setState(() => _pts   = p),
          onSave: _save,
        ),
      ]),
    );
}

// ─── Templates Tab ────────────────────────────────────────────────────────────
class _TemplatesTab extends StatelessWidget {
  final String filterCat;
  final ValueChanged<String> onFilter;
  final ValueChanged<_Tpl> onSelect;
  const _TemplatesTab({required this.filterCat, required this.onFilter, required this.onSelect});

  List<_Tpl> get _filtered => filterCat == 'All' ? _templates : _templates.where((t) => t.category == filterCat).toList();

  @override
  Widget build(BuildContext context) => Column(children: [
    SizedBox(height: 48, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: _cats.map((cat) {
        final sel = filterCat == cat;
        return GestureDetector(onTap: () => onFilter(cat), child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: sel ? const Color(AppColors.lime) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? const Color(AppColors.lime) : const Color(AppColors.border))),
          child: Text(cat, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w600,
            color: sel ? const Color(AppColors.bg) : const Color(AppColors.textMuted)))));
      }).toList())),
    Expanded(child: ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.of(context).padding.bottom + 16),
      itemCount: _filtered.length,
      itemBuilder: (_, i) {
        final t = _filtered[i];
        return GestureDetector(onTap: () => onSelect(t), child: Container(
          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: TC.of(context).cardBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).border)),
          child: Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: TC.of(context).limeBorder)),
              child: Center(child: Text(t.emoji, style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.name, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary)),
              const SizedBox(height: 4),
              Row(children: [
                _Chip(t.category, const Color(AppColors.lime)),
                const SizedBox(width: 6),
                _Chip(t.defaultTime, const Color(AppColors.textMuted)),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(6)),
                child: Text('+${t.pts} pts', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, color: TC.of(context).lime, fontWeight: FontWeight.w700))),
              const SizedBox(height: 6),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: TC.of(context).textMuted),
            ]),
          ])));
      })),
  ]);
}

class _Chip extends StatelessWidget {
  final String label; final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
    child: Text(label, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: color, fontWeight: FontWeight.w600)));
}

// ─── Custom Tab ───────────────────────────────────────────────────────────────
class _CustomTab extends StatelessWidget {
  final TextEditingController nameCtrl;
  final String emoji, time, freq, cat;
  final int pts;
  final ValueChanged<String> onEmoji, onTime, onFreq, onCat;
  final ValueChanged<int> onPts;
  final VoidCallback onSave;
  const _CustomTab({required this.nameCtrl, required this.emoji, required this.time, required this.freq, required this.cat, required this.pts, required this.onEmoji, required this.onTime, required this.onFreq, required this.onCat, required this.onPts, required this.onSave});

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 24),
    children: [
      // Preview
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: TC.of(context).limeBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).limeBorder)),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nameCtrl.text.isEmpty ? 'Your habit name...' : nameCtrl.text,
              style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 16, fontWeight: FontWeight.w700,
                color: nameCtrl.text.isEmpty ? const Color(AppColors.textMuted) : const Color(AppColors.textPrimary))),
            Text('$freq · $time · +$pts pts', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted)),
          ])),
        ])),
      const SizedBox(height: 20),

      const _FL('HABIT NAME'), const SizedBox(height: 6),
      _FC(child: TextField(controller: nameCtrl,
        style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 15, fontWeight: FontWeight.w600, color: TC.of(context).textPrimary),
        decoration: const InputDecoration(hintText: 'e.g. Drink 3L Water', filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, contentPadding: EdgeInsets.zero))),
      const SizedBox(height: 16),

      const _FL('ICON'), const SizedBox(height: 8),
      _FC(child: Wrap(spacing: 8, runSpacing: 8, children: _emojis.map((e) => GestureDetector(
        onTap: () => onEmoji(e),
        child: AnimatedContainer(duration: const Duration(milliseconds: 150), width: 40, height: 40,
          decoration: BoxDecoration(
            color: e == emoji ? const Color(AppColors.limeAlpha12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: e == emoji ? const Color(AppColors.lime) : Colors.transparent, width: 2)),
          child: Center(child: Text(e, style: const TextStyle(fontSize: 20)))))).toList())),
      const SizedBox(height: 16),

      const _FL('FREQUENCY'), const SizedBox(height: 8),
      _Opts(options: _freqs, selected: freq, onSelect: onFreq),
      const SizedBox(height: 16),

      const _FL('TIME OF DAY'), const SizedBox(height: 8),
      _Opts(options: _times, selected: time, onSelect: onTime),
      const SizedBox(height: 16),

      const _FL('CATEGORY'), const SizedBox(height: 8),
      _Opts(options: _cats.where((c) => c != 'All').toList(), selected: cat, onSelect: onCat),
      const SizedBox(height: 16),

      _FL('POINTS REWARD  (+$pts pts per completion)'), const SizedBox(height: 8),
      _FC(child: Column(children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: const Color(AppColors.lime), inactiveTrackColor: const Color(AppColors.surface), thumbColor: const Color(AppColors.lime), overlayColor: const Color(AppColors.limeAlpha12), trackHeight: 4),
          child: Slider(value: pts.toDouble(), min: 5, max: 50, divisions: 9, onChanged: (v) => onPts(v.round()))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('5 pts', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted2)),
          Text('50 pts', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted2)),
        ]),
      ])),
      const SizedBox(height: 28),

      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: Text('✅  Add Habit  (+$pts pts/day)', style: const TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w700)))),
    ]);
}

class _FL extends StatelessWidget {
  final String text;
  const _FL(this.text);
  @override Widget build(BuildContext context) => Text(text, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, fontWeight: FontWeight.w700, color: TC.of(context).textMuted2, letterSpacing: 1));
}

class _FC extends StatelessWidget {
  final Widget child;
  const _FC({required this.child});
  @override Widget build(BuildContext context) => Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: TC.of(context).cardBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).border)), child: child);
}

class _Opts extends StatelessWidget {
  final List<String> options; final String selected; final ValueChanged<String> onSelect;
  const _Opts({required this.options, required this.selected, required this.onSelect});
  @override Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8,
    children: options.map((o) {
      final sel = o == selected;
      return GestureDetector(onTap: () => onSelect(o), child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: sel ? const Color(AppColors.lime) : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? const Color(AppColors.lime) : const Color(AppColors.border))),
        child: Text(o, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w600, color: sel ? const Color(AppColors.bg) : const Color(AppColors.textMuted)))));
    }).toList());
}

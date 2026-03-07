// ignore_for_file: depend_on_referenced_packages
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

import 'package:image_picker/image_picker.dart'
    if (dart.library.html) 'package:image_picker/image_picker.dart';

class _PickedPhoto {
  final String? filePath;
  final Uint8List? webBytes;
  final String name;
  _PickedPhoto({this.filePath, this.webBytes, required this.name});
  bool get hasImage => filePath != null || webBytes != null;
  Widget buildImage({double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (webBytes != null) return Image.memory(webBytes!, width: width, height: height, fit: fit);
    return const Center(child: Icon(Icons.image_outlined, size: 40, color: Color(AppColors.textMuted)));
  }
}

class PhotographsScreen extends StatefulWidget {
  const PhotographsScreen({super.key});
  @override State<PhotographsScreen> createState() => _PhotographsScreenState();
}

class _PhotographsScreenState extends State<PhotographsScreen> {
  final List<_PickedPhoto> _localPhotos = [];
  bool _picking = false;

  Future<void> _pickPhoto(ImageSource source) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final photo = _PickedPhoto(webBytes: bytes, filePath: kIsWeb ? null : picked.path, name: picked.name);
      setState(() => _localPhotos.insert(0, photo));
      if (mounted) _showAddDetailsDialog(photo);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not pick image.')));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _showSourcePicker() {
    if (kIsWeb) { _pickPhoto(ImageSource.gallery); return; }
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _SourceSheet(
        onCamera: () { Navigator.pop(context); _pickPhoto(ImageSource.camera); },
        onGallery: () { Navigator.pop(context); _pickPhoto(ImageSource.gallery); },
      ),
    );
  }

  void _showAddDetailsDialog(_PickedPhoto photo) {
    final wCtrl = TextEditingController();
    final nCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Row(children: [
        Icon(Icons.add_photo_alternate_outlined, color: TC.of(context).lime, size: 20),
        const SizedBox(width: 8),
        const Text('Photo Details'),
      ]),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (photo.hasImage) ClipRRect(borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: SizedBox(height: 160, width: double.infinity, child: photo.buildImage(fit: BoxFit.cover))),
        const SizedBox(height: 14),
        TextField(controller: wCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Current Weight (kg)',
            prefixIcon: Icon(Icons.monitor_weight_outlined, size: 18))),
        const SizedBox(height: 10),
        TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Note (optional)',
          prefixIcon: Icon(Icons.notes_rounded, size: 18))),
      ])),
      actions: [
        TextButton(onPressed: () { setState(() => _localPhotos.remove(photo)); Navigator.pop(ctx); }, child: const Text('Cancel')),
        ElevatedButton.icon(
          icon: const Icon(Icons.save_outlined, size: 16), label: const Text('Save'),
          onPressed: () {
            final now = DateTime.now();
            const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            context.read<AppProvider>().addProgressPhoto({
              'id': 'p_${now.millisecondsSinceEpoch}',
              'date': '${m[now.month]} ${now.day}, ${now.year}',
              'weight': double.tryParse(wCtrl.text) ?? 0.0,
              'label': nCtrl.text.isNotEmpty ? nCtrl.text : 'Progress',
              'emoji': '📸', 'badge': wCtrl.text.isNotEmpty ? '${wCtrl.text} kg' : 'New',
              'badgeType': 'lime', 'localIndex': _localPhotos.indexOf(photo),
            });
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Progress photo saved!'), backgroundColor: Color(AppColors.lime)));
          },
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider    = context.watch<AppProvider>();
    if (provider.isLoading) return const LoadingState();
    final dbPhotos    = (provider.data['progressPhotos'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final weightTrend = (provider.data['weightTrend'] as List?)?.cast<Map<String, dynamic>>() ?? _mockWeight;
    final total = dbPhotos.length + _localPhotos.length;
    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(
          title: 'Progress Photos', subtitle: 'Visual transformation tracker',
          action: ElevatedButton.icon(
            onPressed: _picking ? null : _showSourcePicker,
            icon: _picking
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(AppColors.bg)))
              : const Icon(Icons.add_a_photo_outlined, size: 16),
            label: const Text('Upload'),
          ),
        ),

        // Before & After
        DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('BEFORE & AFTER'),
          Row(children: [
            Expanded(child: _Thumb(photo: dbPhotos.isNotEmpty ? dbPhotos.first : {}, local: null, label: 'Start')),
            const SizedBox(width: 12),
            Expanded(child: _Thumb(photo: dbPhotos.isNotEmpty ? dbPhotos.last : {}, local: _localPhotos.isNotEmpty ? _localPhotos.first : null, label: 'Latest')),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: TC.of(context).limeBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: TC.of(context).limeBorder)),
            child: Row(children: [
              Text('✦', style: TextStyle(fontSize: 14, color: TC.of(context).lime)),
              const SizedBox(width: 8),
              Expanded(child: Text('AI Analysis: Visible reduction in waist area. Weight −4.5 kg in 9 weeks. Excellent progress!',
                style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).textMuted, height: 1.4))),
            ]),
          ),
        ])),
        const SizedBox(height: 14),

        // All photos
        DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader('ALL PHOTOS${total > 0 ? ' ($total)' : ''}'),
          if (total == 0) _EmptyPhotos(onUpload: _showSourcePicker),
          if (_localPhotos.isNotEmpty) _photoGrid(context, _localPhotos.length,
            (i) { final d = dbPhotos.where((p) => p['localIndex'] == i).firstOrNull;
              return _LocalCard(photo: _localPhotos[i], data: d, onDelete: () => setState(() => _localPhotos.removeAt(i))); }),
          if (_localPhotos.isNotEmpty && dbPhotos.isNotEmpty) const SizedBox(height: 12),
          if (dbPhotos.isNotEmpty) _photoGrid(context, dbPhotos.length, (i) => _MockCard(photo: dbPhotos[i])),
          if (total > 0) Padding(padding: const EdgeInsets.only(top: 8),
            child: Text(kIsWeb ? 'Tap Upload to add from files' : 'Tap Upload for camera or gallery',
              style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted2))),
        ])),
        const SizedBox(height: 14),

        // Weight trend
        DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('WEIGHT TREND'),
          const SizedBox(height: 10),
          SizedBox(height: 110, child: Row(crossAxisAlignment: CrossAxisAlignment.end,
            children: weightTrend.map((w) {
              final wt = (w['weight'] as num).toDouble();
              final ratio = ((wt - 70) / (84 - 70)).clamp(0.08, 1.0);
              return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('${wt}', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 8, color: TC.of(context).lime, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Container(height: 80 * ratio, decoration: BoxDecoration(
                    color: TC.of(context).lime, borderRadius: BorderRadius.circular(3),
                    boxShadow: [BoxShadow(color: const Color(AppColors.lime).withOpacity(0.2), blurRadius: 4)])),
                  const SizedBox(height: 4),
                  Text(w['week'] ?? '', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 8, color: TC.of(context).textMuted2)),
                ])));
            }).toList(),
          )),
        ])),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _photoGrid(BuildContext context, int count, Widget Function(int) builder) {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.value(context, mobile: 2, desktop: 4),
        crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75),
      itemCount: count, itemBuilder: (_, i) => builder(i));
  }
}

class _SourceSheet extends StatelessWidget {
  final VoidCallback onCamera, onGallery;
  const _SourceSheet({required this.onCamera, required this.onGallery});
  @override
  Widget build(BuildContext context) => SafeArea(child: Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    decoration: BoxDecoration(color: TC.of(context).cardBg,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 36, height: 4, decoration: BoxDecoration(color: TC.of(context).border2, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 20),
      Text('Add Progress Photo', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 16, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary)),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _SrcBtn(icon: Icons.camera_alt_rounded, label: 'Camera', sub: 'Take a photo', onTap: onCamera)),
        const SizedBox(width: 12),
        Expanded(child: _SrcBtn(icon: Icons.photo_library_outlined, label: 'Gallery', sub: 'From library', onTap: onGallery)),
      ]),
      const SizedBox(height: 16),
    ]),
  ));
}

class _SrcBtn extends StatelessWidget {
  final IconData icon; final String label, sub; final VoidCallback onTap;
  const _SrcBtn({required this.icon, required this.label, required this.sub, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(color: TC.of(context).limeBg,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).limeBorder)),
    child: Column(children: [
      Container(width: 50, height: 50, decoration: BoxDecoration(color: TC.of(context).lime, borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: TC.of(context).pageBg, size: 22)),
      const SizedBox(height: 10),
      Text(label, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary)),
      Text(sub, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: TC.of(context).textMuted)),
    ]),
  ));
}

class _LocalCard extends StatelessWidget {
  final _PickedPhoto photo; final Map<String, dynamic>? data; final VoidCallback onDelete;
  const _LocalCard({required this.photo, this.data, required this.onDelete});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).limeBorder)),
    child: Column(children: [
      Expanded(child: Stack(children: [
        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
          child: SizedBox(width: double.infinity, height: double.infinity, child: photo.buildImage(fit: BoxFit.cover))),
        Positioned(top: 6, right: 6, child: GestureDetector(onTap: onDelete,
          child: Container(width: 26, height: 26, decoration: BoxDecoration(color: const Color(AppColors.red).withOpacity(0.9), shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 14)))),
        const Positioned(top: 6, left: 6, child: DPill('NEW')),
      ])),
      Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data?['date'] ?? 'Just now', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w600, color: TC.of(context).textPrimary)),
        if ((data?['weight'] ?? 0.0) != 0.0)
          Text('${data!['weight']} kg', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted)),
      ])),
    ]),
  );
}

class _Thumb extends StatelessWidget {
  final Map<String, dynamic> photo; final _PickedPhoto? local; final String label;
  const _Thumb({required this.photo, required this.local, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(height: 160, decoration: BoxDecoration(color: TC.of(context).cardBg2, borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMd))),
      child: local != null
        ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMd)),
          child: SizedBox(width: double.infinity, height: double.infinity, child: local!.buildImage(fit: BoxFit.cover)))
        : Center(child: Text(photo['emoji'] ?? '🧍', style: const TextStyle(fontSize: 52)))),
    Container(width: double.infinity, padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: TC.of(context).cardBg2, borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppSizes.radiusMd)), border: Border.all(color: TC.of(context).border)),
      child: Column(children: [
        Text(photo['date'] ?? label, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w600, color: TC.of(context).textPrimary)),
        if (photo['weight'] != null) Text('${photo['weight']} kg', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted)),
      ])),
  ]);
}

class _MockCard extends StatelessWidget {
  final Map<String, dynamic> photo;
  const _MockCard({required this.photo});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: TC.of(context).cardBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: TC.of(context).border)),
    child: Column(children: [
      Expanded(child: Container(decoration: BoxDecoration(color: TC.of(context).cardBg2, borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg))),
        child: Center(child: Text(photo['emoji'] ?? '🧍', style: const TextStyle(fontSize: 38))))),
      Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(photo['date'] ?? '', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w600, color: TC.of(context).textPrimary)),
        Text('${photo['weight']} kg · ${photo['label']}', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: TC.of(context).textMuted)),
        const SizedBox(height: 4),
        DPill(photo['badge'] ?? ''),
      ])),
    ]),
  );
}

class _EmptyPhotos extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyPhotos({required this.onUpload});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onUpload, child: Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      border: Border.all(color: TC.of(context).limeBorder), color: Color(AppColors.limeAlpha12)),
    child: Column(children: [
      Icon(Icons.add_a_photo_outlined, size: 44, color: TC.of(context).lime),
      const SizedBox(height: 10),
      Text('Add your first photo', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w600, color: TC.of(context).textPrimary)),
      Text(kIsWeb ? 'Choose from your files' : 'Camera or gallery',
        style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: TC.of(context).lime)),
    ]),
  ));
}

const _mockWeight = [
  {'week': 'W1', 'weight': 83.5}, {'week': 'W2', 'weight': 82.8}, {'week': 'W3', 'weight': 82.1},
  {'week': 'W4', 'weight': 81.4}, {'week': 'W5', 'weight': 80.6}, {'week': 'W6', 'weight': 80.0},
  {'week': 'W7', 'weight': 79.3}, {'week': 'W8', 'weight': 78.8}, {'week': 'W9', 'weight': 78.2},
];

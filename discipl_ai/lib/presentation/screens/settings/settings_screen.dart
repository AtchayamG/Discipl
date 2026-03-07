import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/common/common_widgets.dart';
import '../language/language_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Settings Screen — also serves as Profile hub
/// All signOut / navigation logic unchanged.
/// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _openEditProfile(BuildContext context, String name, String bio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _EditProfileSheet(
        initialName: name,
        initialBio: bio,
        provider: context.read<AppProvider>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser ?? {};
    final userData = provider.data['user'] as Map<String, dynamic>? ?? {};
    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    final name   = userData['name'] as String? ?? user['name'] as String? ?? 'Demo User';
    final bio    = provider.userBio;
    final handle = '@\${name.toLowerCase().replaceAll(' ', '')}';
    final avatarPath = provider.avatarImagePath;
    final score  = userData['disciplineScore'] as int? ?? 847;
    final streak = userData['currentStreak'] as int? ?? 21;
    final points = userData['totalPoints'] as int? ?? 1240;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Cover banner
            Builder(builder: (ctx) {
              final tc = TC.of(ctx);
              return Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMd)),
                  gradient: LinearGradient(
                    colors: tc.isDark
                        ? [const Color(0xFF0c1a06), const Color(0xFF0E0E1A)]
                        : [const Color(AppColors.limeLightBg), const Color(AppColors.surfaceLight)],
                  ),
                ),
                child: CustomPaint(painter: _HatchPainter(isDark: tc.isDark)),
              );
            }),
            // Avatar + Edit button row (avatar overhangs cover via negative margin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with negative top margin to overlap the cover
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: TC.of(context).cardBg, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(AppColors.lime).withOpacity(0.3),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: ClipOval(
                          child: _AvatarImage(
                            avatarPath: avatarPath,
                            name: name,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Edit button — right side, vertically centred with avatar
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: ElevatedButton.icon(
                      onPressed: () => _openEditProfile(context, name, bio),
                      icon: const Icon(Icons.edit_outlined, size: 13),
                      label: const Text('Edit Profile', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.lime),
                        foregroundColor: const Color(AppColors.bg),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: TC.of(context).textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$handle · Member since Jan 2024',
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 12,
                color: TC.of(context).textMuted,
              ),
            ),
            if (bio.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                bio,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 12,
                  color: TC.of(context).textMuted,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Stats row
            Row(children: [
              _ProfileStat('$score', 'Score', color: TC.of(context).lime),
              const SizedBox(width: 24),
              _ProfileStat('$streak', 'Streak'),
              const SizedBox(width: 24),
              _ProfileStat('142', 'Followers'),
              const SizedBox(width: 24),
              _ProfileStat('89', 'Following'),
              const SizedBox(width: 24),
              _ProfileStat('$points', 'Points', color: const Color(AppColors.orange)),
            ]),
          ]),
        ),

        const SizedBox(height: 14),

        // ── Quick feature links ───────────────────────────────────────────────
        _FeatureSection(provider: provider),

        const SizedBox(height: 14),

        // ── Settings ─────────────────────────────────────────────────────────
        Builder(builder: (ctx) {
          final lp = ctx.watch<LanguageProvider>();
          return DCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader(lp.settings.toUpperCase()),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                iconBg: const Color(AppColors.limeAlpha12),
                label: lp.notifications,
                trailing: 'On',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.lock_outline_rounded,
                iconBg: const Color(0x1F3DD6C8),
                iconColor: const Color(AppColors.teal),
                label: lp.privacy,
                trailing: 'Public',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.palette_outlined,
                iconBg: const Color(0x1F9D7FEA),
                iconColor: const Color(AppColors.violet),
                label: lp.appearance,
                trailing: provider.themeMode == ThemeMode.dark ? 'Dark' : 'Light',
                onTap: provider.toggleTheme,
              ),
              _SettingsItem(
                icon: Icons.language_rounded,
                iconBg: const Color(0x1FFF7A3D),
                iconColor: const Color(AppColors.orange),
                label: lp.language,
                trailing: lp.current.nativeName,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguageScreen()),
                ),
              ),
            ]),
          );
        }),

        const SizedBox(height: 14),

        // ── Sign out ──────────────────────────────────────────────────────────
        GestureDetector(
          onTap: () => _confirmSignOut(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(AppColors.red).withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: const Color(AppColors.red).withOpacity(0.18)),
            ),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(AppColors.red).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded, size: 15, color: Color(AppColors.red)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(AppColors.red),
                  ),
                ),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 32),
      ]),
    );
  }

  void _confirmSignOut(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Color(AppColors.red))),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  const _ProfileStat(this.value, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        value,
        style: TextStyle(
          fontFamily: AppTypography.displayFont,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: color ?? TC.of(context).textPrimary,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.bodyFont,
          fontSize: 9,
          color: TC.of(context).textMuted2,
        ),
      ),
    ]);
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color? iconColor;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    this.iconColor,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: TC.of(context).cardBg2,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: TC.of(context).border),
        ),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: iconColor ?? const Color(AppColors.lime)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TC.of(context).textPrimary,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 11,
                color: TC.of(context).textMuted,
              ),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 16, color: TC.of(context).textMuted),
        ]),
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  final AppProvider provider;
  const _FeatureSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('📷', 'Progress Photos', '4 photos', const Color(AppColors.limeAlpha12), const Color(AppColors.lime), 3),
      ('⭐', 'Challenges', '1 active', const Color(0x1F3DD6C8), const Color(AppColors.teal), 5),
      ('🏆', 'Leaderboard', '#7 Global', const Color(0x1FFF7A3D), const Color(AppColors.orange), 6),
      ('✦', 'AI Insights', '3 new', const Color(0x1F9D7FEA), const Color(AppColors.violet), 7),
      ('📊', 'Analytics', 'Week view', const Color(0x1F3B82F6), const Color(0xFF3B82F6), 8),
    ];

    return DCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader('FEATURES'),
        ...items.map((item) => GestureDetector(
          onTap: () => provider.navigate(item.$6),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: TC.of(context).cardBg2,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: TC.of(context).border),
            ),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.$4,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(item.$1, style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.$2,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TC.of(context).textPrimary,
                  ),
                ),
              ),
              Text(
                item.$3,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 11,
                  color: TC.of(context).textMuted,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 16, color: TC.of(context).textMuted),
            ]),
          ),
        )),
      ]),
    );
  }
}

// ─── Hatch pattern painter for cover ─────────────────────────────────────────
class _HatchPainter extends CustomPainter {
  final bool isDark;
  const _HatchPainter({this.isDark = true});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(AppColors.lime).withOpacity(0.03) : const Color(AppColors.limeLight).withOpacity(0.05)
      ..strokeWidth = 1;
    const step = 16.0;
    for (double i = -size.height; i < size.width + size.height; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// _AvatarImage — shows picked file, or falls back to app icon / initials
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarImage extends StatelessWidget {
  final String? avatarPath;
  final String name;
  final double size;
  const _AvatarImage({required this.avatarPath, required this.name, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);

    // 1 — user picked a file
    if (avatarPath != null && !kIsWeb) {
      final file = File(avatarPath!);
      if (file.existsSync()) {
        return Image.file(file, width: size, height: size, fit: BoxFit.cover);
      }
    }

    // 2 — default app icon
    return Image.asset(
      'assets/images/app_icon.png',
      width: size, height: size, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.black,
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'D',
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: size * 0.38,
              fontWeight: FontWeight.w800,
              color: tc.lime,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EditProfileSheet — fully working edit profile bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialBio;
  final AppProvider provider;
  const _EditProfileSheet({
    required this.initialName,
    required this.initialBio,
    required this.provider,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  String? _pickedImagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _bioCtrl  = TextEditingController(text: widget.initialBio);
    _pickedImagePath = widget.provider.avatarImagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // ── Pick image from camera or gallery ──────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked != null) {
        setState(() => _pickedImagePath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: const Color(AppColors.red),
          ),
        );
      }
    }
  }

  // ── Show camera / gallery choice ───────────────────────────────────────────
  void _showImageSourcePicker() {
    final tc = TC.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,          // lets us control bottom padding
      builder: (ctx) {
        // Account for system nav bar (gesture bar / 3-button nav)
        final bottomPad = MediaQuery.of(ctx).padding.bottom;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: tc.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tc.border),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: tc.border2, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Change Profile Photo',
                style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 15, fontWeight: FontWeight.w700, color: tc.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            _SourceTile(
              icon: Icons.camera_alt_rounded,
              label: 'Take Photo',
              color: tc.lime,
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              color: tc.lime,
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            if (_pickedImagePath != null)
              _SourceTile(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                color: const Color(AppColors.red),
                onTap: () { Navigator.pop(context); setState(() => _pickedImagePath = null); },
              ),
            // Push content above system nav bar
            SizedBox(height: 16 + bottomPad),
          ]),
        );
      },
    );
  }

  // ── Save profile ───────────────────────────────────────────────────────────
  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty'), backgroundColor: Color(AppColors.red)),
      );
      return;
    }

    setState(() => _saving = true);

    await widget.provider.updateProfile({
      'name': name,
      'bio': _bioCtrl.text.trim(),
      'avatarImagePath': _pickedImagePath ?? '',
    });

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Profile updated!',
            style: TextStyle(fontFamily: AppTypography.displayFont, fontWeight: FontWeight.w600)),
          backgroundColor: const Color(AppColors.limeLight),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom; // home bar / nav bar

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: tc.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: tc.border),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: tc.border2, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),

          // Title bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(
                child: Text('Edit Profile',
                  style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 17, fontWeight: FontWeight.w700, color: tc.textPrimary)),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: tc.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),

          Divider(color: tc.border, height: 1),
          const SizedBox(height: 20),

          // ── Avatar picker ─────────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _showImageSourcePicker,
              child: Stack(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(color: tc.limeBorder, width: 2.5),
                    boxShadow: [BoxShadow(color: tc.lime.withOpacity(0.2), blurRadius: 12)],
                  ),
                  child: ClipOval(
                    child: _pickedImagePath != null && !kIsWeb && File(_pickedImagePath!).existsSync()
                        ? Image.file(File(_pickedImagePath!), fit: BoxFit.cover)
                        : Image.asset('assets/images/app_icon.png', fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'D',
                                style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 32, fontWeight: FontWeight.w800, color: tc.lime),
                              ),
                            ),
                          ),
                  ),
                ),
                // Camera badge
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: tc.lime,
                      shape: BoxShape.circle,
                      border: Border.all(color: tc.cardBg, width: 2),
                    ),
                    child: Icon(Icons.camera_alt_rounded, size: 13, color: tc.checkFg),
                  ),
                ),
              ]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton(
              onPressed: _showImageSourcePicker,
              child: Text('Change Photo',
                style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w600, color: tc.lime)),
            ),
          ),

          // ── Fields ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Name field
              Text('DISPLAY NAME',
                style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, fontWeight: FontWeight.w700, color: tc.textMuted2, letterSpacing: 1)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: tc.cardBg2,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: tc.border),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w600, color: tc.textPrimary),
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none, enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero, isDense: false),
                ),
              ),
              const SizedBox(height: 14),

              // Bio field
              Text('BIO',
                style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, fontWeight: FontWeight.w700, color: tc.textMuted2, letterSpacing: 1)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: tc.cardBg2,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: tc.border),
                ),
                child: TextField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  maxLength: 120,
                  style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: tc.textPrimary),
                  decoration: InputDecoration(
                    filled: false,
                    border: InputBorder.none, enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero, isDense: false,
                    counterStyle: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 10, color: tc.textMuted2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save button — extra bottom padding for home bar / nav gestures
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _saving
                      ? SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: tc.checkFg))
                      : const Text('Save Changes',
                          style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
              // Safe bottom gap so button clears device nav bar / home indicator
              SizedBox(height: bottomPadding > 0 ? bottomPadding : 8),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Image source tile ────────────────────────────────────────────────────────
class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SourceTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: tc.cardBg2,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: tc.border),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Text(label,
            style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 14, fontWeight: FontWeight.w600, color: tc.textPrimary)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, size: 18, color: tc.textMuted2),
        ]),
      ),
    );
  }
}

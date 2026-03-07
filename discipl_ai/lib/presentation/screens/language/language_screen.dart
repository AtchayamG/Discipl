import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../providers/language_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Language Selection Screen
// ─────────────────────────────────────────────────────────────────────────────
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _pendingCode; // tracks selection before confirm

  @override
  void initState() {
    super.initState();
    _pendingCode = context.read<LanguageProvider>().current.code;
  }

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final langProvider = context.watch<LanguageProvider>();
    final selected = _pendingCode ?? langProvider.current.code;

    return Scaffold(
      backgroundColor: tc.pageBg,
      appBar: AppBar(
        backgroundColor: tc.topBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: tc.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          langProvider.selectLanguage,
          style: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: tc.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: tc.border),
        ),
      ),
      body: Column(
        children: [
          // ── Header description ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: tc.topBarBg,
              border: Border(bottom: BorderSide(color: tc.border)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: tc.limeBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: tc.limeBorder),
                  ),
                  child: Icon(Icons.language_rounded, size: 18, color: tc.limeIcon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    langProvider.chooseLanguageSubtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFont,
                      fontSize: 13,
                      color: tc.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ]),
            ]),
          ),

          // ── Language list ───────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: AppLanguage.all.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final lang = AppLanguage.all[i];
                final isSelected = lang.code == selected;
                final isCurrent = lang.code == langProvider.current.code;

                return _LanguageTile(
                  lang: lang,
                  isSelected: isSelected,
                  isCurrent: isCurrent,
                  onTap: () => setState(() => _pendingCode = lang.code),
                );
              },
            ),
          ),

          // ── Apply button ────────────────────────────────────────────────
          _ApplyBar(
            pendingCode: _pendingCode,
            currentCode: langProvider.current.code,
            onApply: () async {
              if (_pendingCode != null && _pendingCode != langProvider.current.code) {
                final lang = AppLanguage.fromCode(_pendingCode!);
                await context.read<LanguageProvider>().setLanguage(lang);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${lang.flag}  Language changed to ${lang.nativeName}',
                        style: const TextStyle(
                          fontFamily: AppTypography.displayFont,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: const Color(AppColors.limeLight),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language Tile
// ─────────────────────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final AppLanguage lang;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.lang,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? tc.limeBg : tc.cardBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? tc.limeBorder : tc.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? tc.limeShadow(tc.lime) : tc.cardShadow,
        ),
        child: Row(children: [
          // Flag circle
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isSelected ? tc.limeBg2 : tc.cardBg2,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? tc.limeBorder : tc.border,
              ),
            ),
            child: Center(
              child: Text(lang.flag, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),

          // Language names + greeting preview
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(
                  lang.nativeName,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? tc.limeText : tc.textPrimary,
                  ),
                ),
                if (isCurrent) ...[ 
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: tc.limeBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tc.limeBorder),
                    ),
                    child: Text(
                      'Current',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: tc.limeText,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 3),
              Row(children: [
                Text(
                  lang.name,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFont,
                    fontSize: 12,
                    color: tc.textMuted,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 3, height: 3,
                  decoration: BoxDecoration(
                    color: tc.textMuted2,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  lang.greeting,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFont,
                    fontSize: 12,
                    color: tc.textMuted2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ]),
            ]),
          ),

          // Selection indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: isSelected ? tc.lime : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? tc.lime : tc.border2,
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check_rounded, size: 13, color: tc.checkFg)
                : null,
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom apply bar
// ─────────────────────────────────────────────────────────────────────────────
class _ApplyBar extends StatelessWidget {
  final String? pendingCode;
  final String currentCode;
  final VoidCallback onApply;

  const _ApplyBar({
    required this.pendingCode,
    required this.currentCode,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final hasChange = pendingCode != null && pendingCode != currentCode;
    final pending = pendingCode != null ? AppLanguage.fromCode(pendingCode!) : null;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: tc.cardBg,
        border: Border(top: BorderSide(color: tc.border)),
        boxShadow: tc.elevatedShadow,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (hasChange && pending != null) ...[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(pending.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              'Apply ${pending.nativeName} (${pending.name})',
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 12,
                color: tc.textMuted,
              ),
            ),
          ]),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasChange ? tc.lime : tc.cardBg2,
              foregroundColor: hasChange ? tc.checkFg : tc.textMuted,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              side: hasChange ? null : BorderSide(color: tc.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: Text(
              hasChange ? 'Apply Language' : 'Done',
              style: const TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

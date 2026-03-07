import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/theme_utils.dart';

// ─── DCard ─────────────────────────────────────────────────────────────────────
class DCard extends StatelessWidget {
  final String? title;
  final Widget? titleTrailing;
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  const DCard({
    super.key, this.title, this.titleTrailing,
    required this.child, this.padding, this.borderColor, this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: borderColor ?? tc.border),
        boxShadow: shadow ?? tc.cardShadow,
      ),
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            DSectionLabel(title!),
            if (titleTrailing != null) titleTrailing!,
          ]),
          const SizedBox(height: 12),
        ],
        child,
      ]),
    );
  }
}

// ─── DSectionLabel ─────────────────────────────────────────────────────────────
class DSectionLabel extends StatelessWidget {
  final String text;
  const DSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: AppTypography.displayFont,
        fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5,
        color: tc.textMuted2,
      ),
    );
  }
}

// ─── PageHeader ────────────────────────────────────────────────────────────────
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;
  const PageHeader({super.key, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 22, fontWeight: FontWeight.w800, color: tc.textPrimary)),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12, color: tc.textMuted)),
        ])),
        if (action != null) action!,
      ]),
    );
  }
}

// ─── StatGrid / StatCard ───────────────────────────────────────────────────────
class StatGrid extends StatelessWidget {
  final List<StatCardData> stats;
  const StatGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.statGridColumns(context);
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6),
      itemCount: stats.length,
      itemBuilder: (_, i) => StatCardWidget(data: stats[i]),
    );
  }
}

class StatCardData {
  final String label, value, icon;
  final String? sub;
  final Color? accentColor;
  const StatCardData({required this.label, required this.value, this.sub, required this.icon, this.accentColor});
}

class StatCardWidget extends StatelessWidget {
  final StatCardData data;
  const StatCardWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final accent = data.accentColor ?? tc.lime;
    return Container(
      decoration: BoxDecoration(
        color: tc.cardBg, borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: tc.border), boxShadow: tc.cardShadow,
      ),
      child: Stack(children: [
        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(height: 3, decoration: BoxDecoration(
            color: accent.withOpacity(tc.isDark ? 1.0 : 0.65),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSizes.radiusLg))))),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(data.icon, style: const TextStyle(fontSize: 16)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(data.value, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 20, fontWeight: FontWeight.w800, color: tc.isDark ? accent : tc.textPrimary, height: 1)),
              const SizedBox(height: 2),
              Text(data.label, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 9, color: tc.textMuted2)),
              if (data.sub != null) ...[
                const SizedBox(height: 1),
                Text(data.sub!, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 9, color: tc.textMuted)),
              ],
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─── LeaderboardRow ────────────────────────────────────────────────────────────
class LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final bool isCurrentUser;
  const LeaderboardRow({super.key, required this.rank, required this.name, required this.score, this.isCurrentUser = false});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final isTop = rank <= 3;
    final rankColor = rank == 1 ? const Color(0xFFFFD700)
        : rank == 2 ? const Color(0xFFC0C0C0)
        : rank == 3 ? const Color(0xFFCD7F32)
        : tc.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isCurrentUser ? tc.limeBg : tc.cardBg2,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: isCurrentUser ? tc.limeBorder : tc.border),
        boxShadow: tc.cardShadow,
      ),
      child: Row(children: [
        SizedBox(width: 28,
          child: Text(isTop ? ['🥇','🥈','🥉'][rank-1] : '$rank',
            style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: isTop ? 16 : 12, fontWeight: FontWeight.w700, color: rankColor))),
        const SizedBox(width: 10),
        Expanded(child: Text(name, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w600,
          color: isCurrentUser ? tc.lime : tc.textPrimary))),
        Text('$score pts', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 12, fontWeight: FontWeight.w700,
          color: isCurrentUser ? tc.lime : tc.textMuted)),
      ]),
    );
  }
}

// ─── LoadingState ──────────────────────────────────────────────────────────────
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});
  @override
  Widget build(BuildContext context) => Center(child: CircularProgressIndicator(color: TC.of(context).lime, strokeWidth: 2.5));
}

// ─── ErrorState ───────────────────────────────────────────────────────────────
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return Center(child: Padding(padding: const EdgeInsets.all(AppSizes.xl), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.wifi_off_rounded, size: 48, color: tc.textMuted2),
      const SizedBox(height: 16),
      Text(message, textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTypography.bodyFont, color: tc.textMuted, fontSize: 13)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
    ])));
  }
}

// ─── DPill ────────────────────────────────────────────────────────────────────
class DPill extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  const DPill(this.text, {super.key, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final bg = color ?? tc.limeBg;
    final fg = textColor ?? tc.lime;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSizes.xl), border: Border.all(color: fg.withOpacity(0.22))),
      child: Text(text, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ─── HabitRow ─────────────────────────────────────────────────────────────────
class HabitRow extends StatelessWidget {
  final String emoji, name, subtitle;
  final bool done;
  final double progress;
  final VoidCallback? onToggle;
  final Color? accentColor;
  const HabitRow({super.key, required this.emoji, required this.name, required this.subtitle,
    required this.done, this.progress = 0, this.onToggle, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final accent = accentColor ?? tc.lime;
    final rowBg = done
        ? (tc.isDark ? tc.cardBg : tc.limeBg.withOpacity(0.45))
        : tc.cardBg;
    final rowBorder = done
        ? (tc.isDark ? accent.withOpacity(0.22) : tc.limeBorder.withOpacity(0.55))
        : tc.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: rowBorder),
        boxShadow: tc.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0,1))],
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: accent.withOpacity(tc.isDark ? 0.10 : 0.13), borderRadius: BorderRadius.circular(11),
            border: Border.all(color: accent.withOpacity(tc.isDark ? 0.15 : 0.22))),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 13, fontWeight: FontWeight.w700,
            color: done ? (tc.isDark ? tc.textPrimary : tc.lime) : tc.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 11, color: tc.textMuted)),
          if (progress > 0) ...[
            const SizedBox(height: 5),
            ClipRRect(borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: progress, backgroundColor: tc.progressTrack, color: accent, minHeight: 3)),
          ],
        ])),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: done ? accent : tc.cardBg2,
              shape: BoxShape.circle,
              border: Border.all(color: done ? accent : tc.border2, width: 1.5),
              boxShadow: done ? [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 6)] : [],
            ),
            child: done ? Icon(Icons.check_rounded, size: 15, color: tc.checkFg) : null,
          ),
        ),
      ]),
    );
  }
}

// ─── ScoreRing ────────────────────────────────────────────────────────────────
class ScoreRing extends StatelessWidget {
  final int score;
  final int maxScore;
  final double size;
  const ScoreRing({super.key, required this.score, this.maxScore = 1000, this.size = 110});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return SizedBox(width: size, height: size,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(width: size, height: size,
          child: CircularProgressIndicator(value: score / maxScore, strokeWidth: 7,
            backgroundColor: tc.progressTrack,
            color: tc.isDark ? const Color(AppColors.lime) : const Color(AppColors.limeLight),
            strokeCap: StrokeCap.round)),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$score', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 26, fontWeight: FontWeight.w800, color: tc.lime, height: 1)),
          Text('SCORE', style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: tc.textMuted)),
        ]),
      ]),
    );
  }
}

// ─── WeekBarChart ─────────────────────────────────────────────────────────────
class WeekBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double height;
  const WeekBarChart({super.key, required this.data, this.height = 68});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final max = data.fold<double>(0, (m, e) => (e['value'] as num).toDouble() > m ? (e['value'] as num).toDouble() : m);
    return SizedBox(height: height, child: Row(crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((e) {
        final v = (e['value'] as num).toDouble();
        final isToday = e['isToday'] as bool? ?? false;
        final frac = max > 0 ? v / max : 0.0;
        final barColor = isToday ? tc.lime : tc.limeBg;
        return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Flexible(child: FractionallySizedBox(heightFactor: frac.clamp(0.05, 1.0),
              child: Container(decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(3),
                boxShadow: isToday ? [BoxShadow(color: tc.lime.withOpacity(0.3), blurRadius: 8)] : null)))),
            const SizedBox(height: 4),
            Text((e['day'] as String? ?? '').substring(0, 1),
              style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 9,
                color: isToday ? tc.lime : tc.textMuted2, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
          ])));
      }).toList()));
  }
}

// ─── SectionLink / SectionHeader ─────────────────────────────────────────────
class SectionLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const SectionLink(this.text, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Text(text, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 11, fontWeight: FontWeight.w600, color: TC.of(context).lime)));
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? linkText;
  final VoidCallback? onLink;
  const SectionHeader(this.title, {super.key, this.linkText, this.onLink});

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      DSectionLabel(title),
      if (linkText != null && onLink != null) SectionLink(linkText!, onTap: onLink!),
    ]));
}

// ─── EmptyState ───────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji, title, subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;
  const EmptyState({super.key, required this.emoji, required this.title, required this.subtitle, this.buttonLabel, this.onButton});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return Center(child: Padding(padding: const EdgeInsets.all(AppSizes.xl), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 48)),
      const SizedBox(height: 16),
      Text(title, style: TextStyle(fontFamily: AppTypography.displayFont, fontSize: 17, fontWeight: FontWeight.w700, color: tc.textPrimary)),
      const SizedBox(height: 6),
      Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13, color: tc.textMuted)),
      if (buttonLabel != null && onButton != null) ...[
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onButton, child: Text(buttonLabel!)),
      ],
    ])));
  }
}

// ─── LimeHeroBanner ──────────────────────────────────────────────────────────
class LimeHeroBanner extends StatelessWidget {
  final Widget child;
  const LimeHeroBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: tc.isDark
            ? const LinearGradient(colors: [Color(0xFF0E1A0A), Color(0xFF101510)], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : LinearGradient(colors: [const Color(AppColors.limeLightBg), const Color(AppColors.limeLightBg).withOpacity(0.55)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: tc.isDark ? const Color(AppColors.limeAlpha20) : const Color(AppColors.limeLightBorder).withOpacity(0.55)),
        boxShadow: tc.isDark ? [] : [BoxShadow(color: const Color(AppColors.limeLight).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

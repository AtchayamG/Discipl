import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'providers/app_provider.dart';
import 'providers/language_provider.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/auth/signin_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const DisciplApp());
}

class DisciplApp extends StatelessWidget {
  const DisciplApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<AppProvider, LanguageProvider>(
        builder: (_, provider, langProvider, __) => MaterialApp(
          title: langProvider.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.themeMode,
          home: _RootRouter(provider: provider),
        ),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  final AppProvider provider;
  const _RootRouter({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) return const SplashScreen();
    if (provider.isSignedIn) return const MainShell();
    return const SignInScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Splash Screen — new lime design
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── controllers ────────────────────────────────────────────────────────────
  late final AnimationController _logoCtrl;     // logo entrance  (1.1 s)
  late final AnimationController _textCtrl;     // text entrance  (0.8 s)
  late final AnimationController _pulseCtrl;    // glow pulse loop
  late final AnimationController _particleCtrl; // particles loop
  late final AnimationController _progressCtrl; // 3-second fill

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoY;
  late final Animation<double> _textOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    // Logo pop-in
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _logoScale =
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut)
            .drive(Tween(begin: 0.4, end: 1.0));
    _logoOpacity =
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5))
            .drive(Tween(begin: 0.0, end: 1.0));
    _logoY =
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut)
            .drive(Tween(begin: 30.0, end: 0.0));

    // Glow pulse
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    // Text fade-in after logo
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _textOpacity =
        CurvedAnimation(parent: _textCtrl, curve: const Interval(0.0, 0.6))
            .drive(Tween(begin: 0.0, end: 1.0));
    _taglineOpacity =
        CurvedAnimation(parent: _textCtrl, curve: const Interval(0.3, 1.0))
            .drive(Tween(begin: 0.0, end: 1.0));
    _loaderOpacity =
        CurvedAnimation(parent: _textCtrl, curve: const Interval(0.6, 1.0))
            .drive(Tween(begin: 0.0, end: 1.0));

    // Particles
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat();

    // ── 3-second progress bar — starts immediately ─────────────────────────
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..forward();

    // Sequence: logo → 200 ms → text
    _logoCtrl.forward().then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 200),
            () { if (mounted) _textCtrl.forward(); });
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [

        // ── Radial glow ──────────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) => Center(
            child: Container(
              width: 420, height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(AppColors.lime)
                      .withOpacity(0.07 + _pulseCtrl.value * 0.05),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ),

        // ── Floating particles ───────────────────────────────────────────────
        AnimatedBuilder(
          animation: _particleCtrl,
          builder: (_, __) => CustomPaint(
            size: screenSize,
            painter: _ParticlePainter(_particleCtrl.value),
          ),
        ),

        // ── Main column ──────────────────────────────────────────────────────
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // Splash logo
            AnimatedBuilder(
              animation: _logoCtrl,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _logoY.value),
                child: Opacity(
                  opacity: _logoOpacity.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: const _SplashLogo(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Brand name
            AnimatedBuilder(
              animation: _textCtrl,
              builder: (_, __) => Opacity(
                opacity: _textOpacity.value.clamp(0.0, 1.0),
                child: RichText(
                  text: const TextSpan(children: [
                    TextSpan(text: 'Discipl',
                      style: TextStyle(fontFamily: AppTypography.displayFont,
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: Color(AppColors.textPrimary), letterSpacing: -0.5)),
                    TextSpan(text: '.',
                      style: TextStyle(fontFamily: AppTypography.displayFont,
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: Color(AppColors.lime))),
                    TextSpan(text: 'AI',
                      style: TextStyle(fontFamily: AppTypography.displayFont,
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: Color(AppColors.textPrimary))),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            AnimatedBuilder(
              animation: _textCtrl,
              builder: (_, __) => Opacity(
                opacity: _taglineOpacity.value.clamp(0.0, 1.0),
                child: const Text(
                  'BUILD  ·  TRACK  ·  TRANSFORM',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 11, fontWeight: FontWeight.w600,
                    letterSpacing: 3, color: Color(AppColors.textMuted)),
                ),
              ),
            ),
            const SizedBox(height: 44),

            // ── Progress bar + animated label ────────────────────────────────
            AnimatedBuilder(
              animation: _loaderOpacity,
              builder: (_, __) => Opacity(
                opacity: _loaderOpacity.value.clamp(0.0, 1.0),
                child: AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (_, __) {
                    final p = _progressCtrl.value;
                    final label = p < 0.33
                        ? 'Initialising...'
                        : p < 0.66
                            ? 'Loading your profile...'
                            : 'Almost ready...';
                    return Column(children: [
                      // Track
                      SizedBox(
                        width: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: p,
                            minHeight: 3,
                            backgroundColor: const Color(AppColors.surface),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(AppColors.lime)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Label
                      Text(label,
                        style: const TextStyle(
                          fontFamily: AppTypography.bodyFont,
                          fontSize: 11, color: Color(AppColors.textMuted),
                          letterSpacing: 0.3)),
                    ]);
                  },
                ),
              ),
            ),

          ]),
        ),

        // ── Bottom scan line ─────────────────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Color(AppColors.lime),
                Color(AppColors.teal),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Splash logo widget ──────────────────────────────────────────────────────
// Uses app_icon.png displayed as a rounded square — matches the actual app icon
class _SplashLogo extends StatelessWidget {
  const _SplashLogo();
  @override
  Widget build(BuildContext context) {
    const double size = 160;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.lime).withOpacity(0.35),
            blurRadius: 60,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ─── Particle painter ─────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);
  static final _rng = math.Random(42);
  static final _pts = List.generate(20, (_) => [
    _rng.nextDouble(), _rng.nextDouble(),
    _rng.nextDouble() * 0.4 + 0.1, _rng.nextDouble(),
  ]);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    for (final pt in _pts) {
      final phase = (t + pt[3]) % 1.0;
      final x = pt[0] * size.width;
      final y = (pt[1] - phase * 0.3) % 1.0 * size.height;
      final op = math.sin(phase * math.pi) * 0.4;
      p.color = const Color(AppColors.lime).withOpacity(op.clamp(0.0, 0.4));
      canvas.drawCircle(Offset(x, y), pt[2] * 3, p);
    }
  }
  @override
  bool shouldRepaint(_ParticlePainter o) => o.t != t;
}

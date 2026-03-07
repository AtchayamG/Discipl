import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../providers/app_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Sign In Screen — Lime / dark design
/// Business logic: unchanged (AppProvider.signIn / signUp)
/// ─────────────────────────────────────────────────────────────────────────────
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _emailCtrl    = TextEditingController(text: 'demo@discipl.ai');
  final _passwordCtrl = TextEditingController(text: 'demo123');
  final _nameCtrl     = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl  = TextEditingController();
  bool _obscurePass   = true;
  bool _obscureRegPass = true;
  String? _errorMsg;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() { _errorMsg = null; _loading = true; });
    final provider = context.read<AppProvider>();
    final err = await provider.signIn(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (mounted) setState(() { _errorMsg = err; _loading = false; });
  }

  Future<void> _signUp() async {
    setState(() { _errorMsg = null; _loading = true; });
    final provider = context.read<AppProvider>();
    final err = await provider.signUp(
      name: _nameCtrl.text.trim(),
      email: _regEmailCtrl.text.trim(),
      password: _regPassCtrl.text,
    );
    if (mounted) setState(() { _errorMsg = err; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 700;

    // Back button on sign-in/sign-up → exit app immediately (no auth stack to go back to)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Background radial glow
        Positioned(
          top: -80, left: size.width * 0.2,
          child: Container(
            width: 400, height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Color(0x28C8F135),
                Colors.transparent,
              ]),
            ),
          ),
        ),

        isWide ? _WideLayout(content: _buildCard()) : _NarrowLayout(content: _buildCard()),
      ]),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: TC.of(context).cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: TC.of(context).border2),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Icon + brand
        _AppIconBlock(),
        const SizedBox(height: 24),

        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: TC.of(context).cardBg2,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          padding: const EdgeInsets.all(3),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(
              color: TC.of(context).lime,
              borderRadius: BorderRadius.circular(9),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: TC.of(context).textMuted,
            labelStyle: const TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            dividerHeight: 0,
            tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
          ),
        ),
        const SizedBox(height: 22),

        // Error
        if (_errorMsg != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(AppColors.red).withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              border: Border.all(color: const Color(AppColors.red).withOpacity(0.3)),
            ),
            child: Text(
              _errorMsg!,
              style: const TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 12,
                color: Color(AppColors.red),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Forms - using AnimatedSwitcher to avoid height constraints
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _tabCtrl.index == 0
              ? _SignInForm(this)
              : _SignUpForm(this),
        ),
      ]),
    );
  }
}

// ─── Sign In form ─────────────────────────────────────────────────────────────
class _SignInForm extends StatelessWidget {
  final _SignInScreenState s;
  const _SignInForm(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _Field(
        label: 'EMAIL',
        icon: Icons.alternate_email_rounded,
        controller: s._emailCtrl,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 12),
      _Field(
        label: 'PASSWORD',
        icon: Icons.lock_outline_rounded,
        controller: s._passwordCtrl,
        obscureText: s._obscurePass,
        suffix: IconButton(
          icon: Icon(
            s._obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 16,
            color: TC.of(context).textMuted,
          ),
          onPressed: () => s.setState(() => s._obscurePass = !s._obscurePass),
        ),
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {},
          child: const Text('Forgot password?'),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: s._loading ? null : s._signIn,
          child: s._loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Sign In'),
        ),
      ),
    ]);
  }
}

// ─── Sign Up form ─────────────────────────────────────────────────────────────
class _SignUpForm extends StatelessWidget {
  final _SignInScreenState s;
  const _SignUpForm(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _Field(
        label: 'FULL NAME',
        icon: Icons.person_outline_rounded,
        controller: s._nameCtrl,
      ),
      const SizedBox(height: 10),
      _Field(
        label: 'EMAIL',
        icon: Icons.alternate_email_rounded,
        controller: s._regEmailCtrl,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 10),
      _Field(
        label: 'PASSWORD',
        icon: Icons.lock_outline_rounded,
        controller: s._regPassCtrl,
        obscureText: s._obscureRegPass,
        suffix: IconButton(
          icon: Icon(
            s._obscureRegPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 16,
            color: TC.of(context).textMuted,
          ),
          onPressed: () => s.setState(() => s._obscureRegPass = !s._obscureRegPass),
        ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: s._loading ? null : s._signUp,
          child: s._loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Create Account'),
        ),
      ),
    ]);
  }
}

// ─── Reusable field ───────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.displayFont,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: TC.of(context).textMuted,
        ),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: AppTypography.bodyFont,
          fontSize: 14,
          color: TC.of(context).textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 16, color: TC.of(context).textMuted2),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    ]);
  }
}

// ─── App icon + brand header ──────────────────────────────────────────────────
class _AppIconBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: TC.of(context).limeBorder, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(AppColors.lime).withOpacity(0.2),
              blurRadius: 28,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.5),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            'assets/images/app_icon.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Text(
                'D',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: TC.of(context).lime,
                ),
              ),
            ),
          ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      RichText(
        text: TextSpan(children: [
          TextSpan(
            text: 'Welcome to ',
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TC.of(context).textPrimary,
            ),
          ),
          TextSpan(
            text: 'Discipl',
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: TC.of(context).textPrimary,
            ),
          ),
          TextSpan(
            text: '.AI',
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: TC.of(context).lime,
            ),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      Text(
        'Your AI-powered discipline engine',
        style: TextStyle(
          fontFamily: AppTypography.bodyFont,
          fontSize: 12,
          color: TC.of(context).textMuted,
        ),
      ),
    ]);
  }
}

// ─── Layout helpers ───────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final Widget content;
  const _WideLayout({required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Left branding panel
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: TC.of(context).isDark ? [Color(0xFF0A1400), Color(0xFF000000)] : [Color(AppColors.lightBg), Color(AppColors.lightBg2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: TC.of(context).limeBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(AppColors.lime).withOpacity(0.25),
                      blurRadius: 50,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text('D', style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 60, fontWeight: FontWeight.w900,
                        color: TC.of(context).lime,
                      )),
                    ),
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Discipl',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFont,
                      fontSize: 36, fontWeight: FontWeight.w900,
                      color: TC.of(context).textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: '.AI',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFont,
                      fontSize: 36, fontWeight: FontWeight.w900,
                      color: TC.of(context).lime,
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              Text(
                'BUILD  ·  TRACK  ·  TRANSFORM',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 11,
                  letterSpacing: 3,
                  color: TC.of(context).textMuted,
                ),
              ),
            ]),
          ),
        ),
      ),
      // Right form panel
      Expanded(
        child: Container(
          color: Colors.black,
          child: Center(child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: content,
          )),
        ),
      ),
    ]);
  }
}

class _NarrowLayout extends StatelessWidget {
  final Widget content;
  const _NarrowLayout({required this.content});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: content,
      ),
    );
  }
}

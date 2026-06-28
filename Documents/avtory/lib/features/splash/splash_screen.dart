import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/accessibility/accessibility.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/adaptive_spacing.dart';
import '../../core/responsive/adaptive_typography.dart';
import '../../core/router/app_router.dart';
import '../../data/local/app_storage.dart';
import '../../services/biometrics_service.dart';
import '../../shared/widgets/app_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _taglineFade;
  bool _showBiometric = false;
  bool _isBiometricLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)));
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)));
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!mounted) return;
    final bioEnabled = await BiometricsService.isEnabled();
    final bioAvailable = bioEnabled && await BiometricsService.isAvailable();
    if (bioAvailable && mounted) {
      setState(() => _showBiometric = true);
    }
    context.read<AuthBloc>().add(AuthCheckStatus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.role == 'admin') {
            context.go(AppRoutes.adminDashboard);
          } else if (state.role == 'mechanic') {
            context.go(state.needsSetup
                ? AppRoutes.mechanicSetup
                : AppRoutes.mechanicDashboard);
          } else {
            context.go(AppRoutes.home);
          }
        } else if (state is AuthUnauthenticated) {
          // Navigate to login immediately; biometric overlay sits on top.
          SharedPreferences.getInstance().then((prefs) {
            final done = prefs.getBool('onboarding_done') ?? false;
            if (context.mounted) {
              context.go(done ? AppRoutes.login : AppRoutes.onboarding);
            }
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _SplashBody(
              ctrl: _ctrl,
              scale: _scale,
              fade: _fade,
              taglineSlide: _taglineSlide,
              taglineFade: _taglineFade,
            ),
            if (_showBiometric) _buildBiometricOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricOverlay() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 48,
      left: 24,
      right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  _isBiometricLoading ? null : _onBiometricLogin,
              icon: _isBiometricLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const AppIcon('fingerprint',
                      color: Colors.white, size: 22),
              label: Text(
                _isBiometricLoading ? 'Kirish...' : 'Biometrik kirish',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() => _showBiometric = false);
              SharedPreferences.getInstance().then((prefs) {
                final done =
                    prefs.getBool('onboarding_done') ?? false;
                if (context.mounted) {
                  context.go(
                      done ? AppRoutes.login : AppRoutes.onboarding);
                }
              });
            },
            child: Text(
              'Boshqa usul bilan kirish',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onBiometricLogin() async {
    setState(() => _isBiometricLoading = true);
    final authed = await BiometricsService.authenticate();
    if (!authed) {
      if (mounted) setState(() => _isBiometricLoading = false);
      return;
    }
    final credentials = await BiometricsService.getCredentials();
    final role = await BiometricsService.getRole();
    if (credentials != null) {
      final token = credentials['password'];
      final refreshToken = credentials['refresh_token'];
      if (token != null) await AppStorage.setToken(token);
      if (refreshToken != null) await AppStorage.setRefreshToken(refreshToken);
      if (role != null) await AppStorage.setRole(role);
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckStatus());
      }
    } else {
      // Inconsistent state: flag true but no credentials — clean up and go to login.
      await BiometricsService.clearCredentials();
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final done = prefs.getBool('onboarding_done') ?? false;
        if (mounted) context.go(done ? AppRoutes.login : AppRoutes.onboarding);
      }
    }
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody({
    required this.ctrl,
    required this.scale,
    required this.fade,
    required this.taglineSlide,
    required this.taglineFade,
  });
  final AnimationController ctrl;
  final Animation<double> scale, fade;
  final Animation<Offset> taglineSlide;
  final Animation<double> taglineFade;

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gradientCtrl;

  @override
  void initState() {
    super.initState();
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.ctrl, _gradientCtrl]),
      builder: (context, _) {
        final g = _gradientCtrl.value;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF0F172A), const Color(0xFF1A56CC), g * 0.3)!,
                Color.lerp(const Color(0xFF020617), const Color(0xFF0B1121), g)!,
                Color.lerp(const Color(0xFF0F172A), const Color(0xFF143E99), g * 0.2)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              ...List.generate(10, (i) => AppSemantics.hidden(_Particle(g, i))),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: widget.fade,
                      child: ScaleTransition(
                        scale: widget.scale,
                        child: _buildLogo(),
                      ),
                    ),
                    SizedBox(height: context.sectionGap),
                    SlideTransition(
                      position: widget.taglineSlide,
                      child: FadeTransition(
                        opacity: widget.taglineFade,
                        child: Column(
                          children: [
                            AppSemantics.image(
                              label: 'AVTORY',
                              child: const Text('AVTORY',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Inter',
                                      letterSpacing: 2)),
                            ),
                            SizedBox(height: context.cardGap),
                            AppSemantics.header(
                              label: "Yo'l yordami. Tez va ishonchli.",
                              child: Text(
                                "Yo'l yordami. Tez va ishonchli.",
                                style: context.headingSmall(color: Colors.white.withValues(alpha: 0.55)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.sp5XL),
                    _CustomLoader(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return AppSemantics.image(
      label: 'AVTORY logotipi',
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: DesignTokens.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: DesignTokens.primary.withValues(alpha: 0.35),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: DesignTokens.primary.withValues(alpha: 0.15),
              blurRadius: 80,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const AppIcon('location_on', color: Colors.white, size: 64),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Transform.rotate(
                angle: -0.5,
                child: const AppIcon('build_rounded', color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Particle extends StatelessWidget {
  const _Particle(this.g, this.index);
  final double g;
  final int index;

  @override
  Widget build(BuildContext context) {
    final seed = index * 137.5;
    final x = ((math.sin(seed) * 0.5 + 0.5) * (g * 0.3 + 0.7) +
            math.sin(seed + g * 2) * 0.05)
        .clamp(0.0, 1.0);
    final y = ((math.cos(seed * 1.7) * 0.5 + 0.5) * 0.9 +
            math.cos(seed + g * 1.3) * 0.05)
        .clamp(0.0, 1.0);
    final size = (math.sin(seed * 2.3) * 1.5 + 2.5).clamp(1.0, 4.0);
    final opacity = (math.sin(seed + g * 0.5) * 0.15 + 0.2).clamp(0.0, 0.35);

    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CustomLoader extends StatefulWidget {
  @override
  State<_CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<_CustomLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(
            painter: _LoaderPainter(t),
            size: const Size(28, 28),
          ),
        );
      },
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final arcPaint = Paint()
      ..shader = DesignTokens.primaryGradient.createShader(
          Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + t * math.pi * 2,
      (math.sin(t * math.pi * 4) * 0.5 + 1.5) * 0.6,
      false,
      arcPaint,
    );

    final dotPaint = Paint()
      ..color = DesignTokens.primaryLight.withValues(alpha: (math.sin(t * math.pi * 2) * 0.5 + 0.5) * 0.8)
      ..style = PaintingStyle.fill;

    final dotAngle = -math.pi / 2 + t * math.pi * 2;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);
    canvas.drawCircle(Offset(dotX, dotY), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(_LoaderPainter old) => old.t != t;
}


import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../../ui/theme/app_theme.dart';
import '../../shell/ui/app_shell.dart';
import '../domain/splash_config.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleUp;
  late final Animation<double> _slideUp;
  SplashConfig _config = SplashConfig.fallback;

  @override
  void initState() {
    super.initState();
    // Initialize with fallback config immediately to avoid uninitialized controller.
    _initAnim(_config);
    // Load external config asynchronously; update labels/assets when ready.
    SplashConfig.load().then((cfg) {
      if (!mounted) return;
      setState(() => _config = cfg);
    });
  }

  void _initAnim(SplashConfig cfg) {
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: cfg.durationMs),
    );
    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _scaleUp = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.15, 0.75, curve: Curves.easeOutBack),
      ),
    );
    _slideUp = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );
    _ctrl.forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        final delayMs = _config.nextDelayMs;
        Future.delayed(Duration(milliseconds: delayMs), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 350),
              pageBuilder: (_, __, ___) => const AppShell(),
              transitionsBuilder:
                  (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final cs = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);
    final subStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cs.surface, cs.surface.withAlpha(250), cs.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/animation
                    Transform.translate(
                      offset: Offset(0, _slideUp.value),
                      child: Transform.scale(
                        scale: _scaleUp.value,
                        child: _AnimatedMark(
                          opacity: _fadeIn.value,
                          config: _config,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.x3),
                    Opacity(
                      opacity: _fadeIn.value,
                      child: Column(
                        children: [
                          Text(
                            _config.title,
                            style: titleStyle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacing.x1),
                          Text(
                            _config.subtitle,
                            style: subStyle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedMark extends StatelessWidget {
  final double opacity;
  final SplashConfig config;
  const _AnimatedMark({required this.opacity, required this.config});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spacing = context.spacing;
    final size = 112.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset =
        isDark ? config.animation.darkAsset : config.animation.lightAsset;

    return Semantics(
      label: '앱 로고',
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // soft blob backdrop
          Opacity(
            opacity: 0.12 * opacity,
            child: Container(
              width: size * 1.6,
              height: size * 1.1,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withAlpha(38),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // animation content
          _contentByType(config.animation.type, asset, cs, spacing, size),
          // floating dot accents
          Positioned(
            right: -8,
            top: -6,
            child: _Dot(color: cs.primary, size: 10 * opacity),
          ),
          Positioned(
            left: -10,
            bottom: -8,
            child: _Dot(color: cs.tertiary, size: 14 * opacity),
          ),
          // subtle rotation
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.rotate(
                angle: (1 - opacity) * (math.pi / 96),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentByType(
    SplashAnimationType type,
    String asset,
    ColorScheme cs,
    dynamic spacing,
    double size,
  ) {
    switch (type) {
      case SplashAnimationType.lottie:
        return SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(asset, fit: BoxFit.contain, repeat: true),
        );
      case SplashAnimationType.svg:
        return _Pill(
          w: size,
          h: size * 0.68,
          color: cs.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                asset,
                width: size * 0.44,
                colorFilter: ColorFilter.mode(
                  cs.onPrimaryContainer,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        );
      case SplashAnimationType.image:
        return _Pill(
          w: size,
          h: size * 0.68,
          color: cs.primaryContainer,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.34),
            child: Image.asset(
              asset,
              width: size * 0.56,
              height: size * 0.56,
              fit: BoxFit.contain,
            ),
          ),
        );
    }
  }
}

class _Pill extends StatelessWidget {
  final double w;
  final double h;
  final Color color;
  final Widget child;
  const _Pill({
    required this.w,
    required this.h,
    required this.color,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(h / 2),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;
  const _Dot({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

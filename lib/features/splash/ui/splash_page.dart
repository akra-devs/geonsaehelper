import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../ui/theme/app_theme.dart';
import '../../shell/ui/app_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleUp;
  late final Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _scaleUp = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.15, 0.75, curve: Curves.easeOutBack)),
    );
    _slideUp = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 1.0, curve: Curves.easeOut)),
    );
    _ctrl.forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 350),
              pageBuilder: (_, __, ___) => const AppShell(),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
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
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);
    final subStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cs.surface, cs.surface.withOpacity(0.98), cs.surface],
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
                    // Logo mark: chat bubble + home glyph with gentle motion
                    Transform.translate(
                      offset: Offset(0, _slideUp.value),
                      child: Transform.scale(
                        scale: _scaleUp.value,
                        child: _LogoMark(opacity: _fadeIn.value),
                      ),
                    ),
                    SizedBox(height: spacing.x3),
                    Opacity(
                      opacity: _fadeIn.value,
                      child: Column(
                        children: [
                          Text('전세자금대출 도우미', style: titleStyle, textAlign: TextAlign.center),
                          SizedBox(height: spacing.x1),
                          Text('HUG 예비판정 · 내부 근거 Q&A', style: subStyle, textAlign: TextAlign.center),
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

class _LogoMark extends StatelessWidget {
  final double opacity;
  const _LogoMark({required this.opacity});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spacing = context.spacing;
    final size = 96.0;

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
                  BoxShadow(color: cs.primary.withOpacity(0.15), blurRadius: 24, spreadRadius: 4),
                ],
              ),
            ),
          ),
          // chat bubble circle
          _Pill(
            w: size,
            h: size * 0.68,
            color: cs.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_rounded, color: cs.onPrimaryContainer),
                SizedBox(width: spacing.x1),
                Icon(Icons.home_rounded, color: cs.onPrimaryContainer),
              ],
            ),
          ),
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
}

class _Pill extends StatelessWidget {
  final double w;
  final double h;
  final Color color;
  final Widget child;
  const _Pill({required this.w, required this.h, required this.color, required this.child});
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
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}


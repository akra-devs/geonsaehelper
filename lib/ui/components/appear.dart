import 'package:flutter/material.dart';

/// Simple fade + slight y-translate appear animation.
class Appear extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offsetY;

  const Appear({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200), // tokens.motion.durations_ms.normal
    this.curve = Curves.easeOut, // tokens.motion.easing.standard
    this.offsetY = 12,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, t, _) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * offsetY),
          child: child,
        ),
      ),
    );
  }
}


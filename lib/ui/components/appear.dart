import 'package:flutter/material.dart';

/// Simple fade + slight y-translate appear animation with optional delay.
class Appear extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offsetY;
  final Duration delay;

  const Appear({
    super.key,
    required this.child,
    this.duration = const Duration(
      milliseconds: 200,
    ), // tokens.motion.durations_ms.normal
    this.curve = Curves.easeOut, // tokens.motion.easing.standard
    this.offsetY = 12,
    this.delay = Duration.zero,
  });

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> {
  bool _start = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _start = true;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _start = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_start) {
      return Opacity(
        opacity: 0,
        child: Transform.translate(
          offset: Offset(0, widget.offsetY),
          child: widget.child,
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: widget.duration,
      curve: widget.curve,
      builder:
          (context, t, _) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * widget.offsetY),
              child: widget.child,
            ),
          ),
    );
  }
}

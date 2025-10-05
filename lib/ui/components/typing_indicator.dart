import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final bool active;
  const TypingIndicator({super.key, this.active = true});

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();
    return Row(
      key: const Key('TypingIndicator'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(delay: 0),
        const SizedBox(width: 4),
        _Dot(delay: 150),
        const SizedBox(width: 4),
        _Dot(delay: 300),
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay; // ms
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..repeat(reverse: true);
  late final Animation<double> _a = Tween(
    begin: 0.3,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: const CircleAvatar(radius: 3, backgroundColor: Colors.grey),
    );
  }
}

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

enum SplashAnimationType { lottie, svg, image }

class SplashAnimationConfig {
  final SplashAnimationType type;
  final String lightAsset;
  final String darkAsset;
  const SplashAnimationConfig({required this.type, required this.lightAsset, required this.darkAsset});
}

class SplashConfig {
  final int durationMs;
  final int nextDelayMs;
  final String title;
  final String subtitle;
  final SplashAnimationConfig animation;

  const SplashConfig({
    required this.durationMs,
    required this.nextDelayMs,
    required this.title,
    required this.subtitle,
    required this.animation,
  });

  static const SplashConfig fallback = SplashConfig(
    durationMs: 1200,
    nextDelayMs: 250,
    title: '전세자금대출 도우미',
    subtitle: 'HUG 예비판정 · 내부 근거 Q&A',
    animation: SplashAnimationConfig(
      type: SplashAnimationType.svg,
      lightAsset: 'assets/splash/logo.svg',
      darkAsset: 'assets/splash/logo.svg',
    ),
  );

  static Future<SplashConfig> load([String path = 'assets/splash/config.json']) async {
    try {
      final raw = await rootBundle.loadString(path);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final anim = map['animation'] as Map<String, dynamic>?;
      final typeStr = (anim?['type'] as String? ?? 'svg').toLowerCase();
      final type = switch (typeStr) {
        'lottie' => SplashAnimationType.lottie,
        'svg' => SplashAnimationType.svg,
        'image' => SplashAnimationType.image,
        _ => SplashAnimationType.svg,
      };
      return SplashConfig(
        durationMs: (map['durationMs'] as num?)?.toInt() ?? fallback.durationMs,
        nextDelayMs: (map['nextDelayMs'] as num?)?.toInt() ?? fallback.nextDelayMs,
        title: (map['title'] as String?) ?? fallback.title,
        subtitle: (map['subtitle'] as String?) ?? fallback.subtitle,
        animation: SplashAnimationConfig(
          type: type,
          lightAsset: (anim?['lightAsset'] as String?) ?? fallback.animation.lightAsset,
          darkAsset: (anim?['darkAsset'] as String?) ?? fallback.animation.darkAsset,
        ),
      );
    } catch (_) {
      return fallback;
    }
  }
}


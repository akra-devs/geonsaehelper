import 'package:flutter/material.dart';

@immutable
class Spacing extends ThemeExtension<Spacing> {
  final double x1; // 4
  final double x2; // 8
  final double x3; // 12
  final double x4; // 16
  final double x6; // 24
  const Spacing({this.x1 = 4, this.x2 = 8, this.x3 = 12, this.x4 = 16, this.x6 = 24});
  @override
  Spacing copyWith({double? x1, double? x2, double? x3, double? x4, double? x6}) => Spacing(
        x1: x1 ?? this.x1,
        x2: x2 ?? this.x2,
        x3: x3 ?? this.x3,
        x4: x4 ?? this.x4,
        x6: x6 ?? this.x6,
      );
  @override
  Spacing lerp(ThemeExtension<Spacing>? other, double t) => this;
}

@immutable
class Corners extends ThemeExtension<Corners> {
  final double sm; // 8
  final double md; // 12
  const Corners({this.sm = 8, this.md = 12});
  @override
  Corners copyWith({double? sm, double? md}) => Corners(sm: sm ?? this.sm, md: md ?? this.md);
  @override
  Corners lerp(ThemeExtension<Corners>? other, double t) => this;
}

ThemeData buildAppTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3B6EF5),
    brightness: brightness,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.4),
      labelLarge: base.textTheme.labelLarge?.copyWith(letterSpacing: 0.2),
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: base.textTheme.labelLarge?.copyWith(letterSpacing: 0.1),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
      side: BorderSide(color: scheme.outlineVariant),
      selectedColor: scheme.primaryContainer,
      backgroundColor: scheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      Spacing(),
      Corners(),
    ],
  );
}

extension ThemeGetters on BuildContext {
  Spacing get spacing => Theme.of(this).extension<Spacing>() ?? const Spacing();
  Corners get corners => Theme.of(this).extension<Corners>() ?? const Corners();
}

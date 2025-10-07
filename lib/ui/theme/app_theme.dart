import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _snow = Color(0xFFF9F7F7);
const Color _mist = Color(0xFFDBE2EF);
const Color _sky = Color(0xFF3F72AF);
const Color _navy = Color(0xFF112D4E);

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

ColorScheme _buildWinterScheme(Brightness brightness) {
  final seed = ColorScheme.fromSeed(seedColor: _sky, brightness: brightness);

  if (brightness == Brightness.light) {
    final slate = _mix(_navy, _sky, 0.35);
    final frost = _mix(_mist, _snow, 0.55);
    final paleSky = _mix(_sky, _mist, 0.35);
    return seed.copyWith(
      primary: _sky,
      onPrimary: _snow,
      primaryContainer: _mist,
      onPrimaryContainer: _navy,
      secondary: _navy,
      onSecondary: _snow,
      secondaryContainer: _mix(_navy, _mist, 0.25),
      onSecondaryContainer: _snow,
      tertiary: slate,
      onTertiary: _snow,
      tertiaryContainer: _mix(_mist, _sky, 0.5),
      onTertiaryContainer: _navy,
      background: _snow,
      onBackground: _navy,
      surface: _snow,
      onSurface: _navy,
      surfaceTint: _sky,
      surfaceVariant: _mist,
      onSurfaceVariant: slate,
      outline: _mix(_navy, _mist, 0.6),
      outlineVariant: frost,
      shadow: Colors.black,
      inverseSurface: _navy,
      inverseOnSurface: _mist,
      inversePrimary: paleSky,
    );
  }

  final deepNavy = _mix(_navy, Colors.black, 0.15);
  final midnight = _mix(_navy, Colors.black, 0.35);
  final moonlight = _mix(_mist, _snow, 0.7);
  final steel = _mix(_sky, _navy, 0.45);
  return seed.copyWith(
    primary: moonlight,
    onPrimary: _navy,
    primaryContainer: _sky,
    onPrimaryContainer: _snow,
    secondary: _mist,
    onSecondary: _navy,
    secondaryContainer: _mix(_sky, _mist, 0.25),
    onSecondaryContainer: _navy,
    tertiary: steel,
    onTertiary: moonlight,
    tertiaryContainer: _mix(_sky, _navy, 0.6),
    onTertiaryContainer: _mist,
    background: midnight,
    onBackground: moonlight,
    surface: deepNavy,
    onSurface: moonlight,
    surfaceTint: moonlight,
    surfaceVariant: _mix(_navy, _sky, 0.35),
    onSurfaceVariant: _mix(_mist, _snow, 0.85),
    outline: _mix(_sky, _navy, 0.55),
    outlineVariant: _mix(_navy, Colors.black, 0.3),
    shadow: Colors.black,
    inverseSurface: moonlight,
    inverseOnSurface: _navy,
    inversePrimary: _sky,
  );
}

@immutable
class Spacing extends ThemeExtension<Spacing> {
  final double x1; // 4
  final double x2; // 8
  final double x3; // 12
  final double x4; // 16
  final double x6; // 24
  final double x8; // 32
  final double x10; // 40
  const Spacing({
    this.x1 = 4,
    this.x2 = 8,
    this.x3 = 12,
    this.x4 = 16,
    this.x6 = 24,
    this.x8 = 32,
    this.x10 = 40,
  });
  @override
  Spacing copyWith({
    double? x1,
    double? x2,
    double? x3,
    double? x4,
    double? x6,
    double? x8,
    double? x10,
  }) => Spacing(
    x1: x1 ?? this.x1,
    x2: x2 ?? this.x2,
    x3: x3 ?? this.x3,
    x4: x4 ?? this.x4,
    x6: x6 ?? this.x6,
    x8: x8 ?? this.x8,
    x10: x10 ?? this.x10,
  );
  @override
  Spacing lerp(ThemeExtension<Spacing>? other, double t) => this;
}

@immutable
class Corners extends ThemeExtension<Corners> {
  final double sm; // 10
  final double md; // 14
  const Corners({this.sm = 10, this.md = 14});
  @override
  Corners copyWith({double? sm, double? md}) =>
      Corners(sm: sm ?? this.sm, md: md ?? this.md);
  @override
  Corners lerp(ThemeExtension<Corners>? other, double t) => this;
}

ThemeData buildAppTheme(Brightness brightness) {
  final scheme = _buildWinterScheme(brightness);
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.background,
  );
  final corners = const Corners();
  final interText = GoogleFonts.interTextTheme(base.textTheme);
  final isDark = brightness == Brightness.dark;
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.background,
    textTheme: interText.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: interText.bodyMedium?.copyWith(height: 1.5),
      labelLarge: interText.labelLarge?.copyWith(letterSpacing: 0.15),
    ),
    appBarTheme: base.appBarTheme.copyWith(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: base.cardTheme.copyWith(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(corners.md),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dividerTheme: base.dividerTheme.copyWith(
      color: isDark ? scheme.outline : scheme.outlineVariant,
      thickness: 1,
      space: 24,
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      height: 64,
      indicatorColor: scheme.secondaryContainer.withOpacity(0.35),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: base.textTheme.labelLarge?.copyWith(letterSpacing: 0.1),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      side: BorderSide(color: scheme.outlineVariant),
      selectedColor: scheme.secondaryContainer,
      backgroundColor: _mix(scheme.surface, scheme.surfaceVariant, 0.5),
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
    extensions: const <ThemeExtension<dynamic>>[Spacing(), Corners()],
  );
}

extension ThemeGetters on BuildContext {
  Spacing get spacing => Theme.of(this).extension<Spacing>() ?? const Spacing();
  Corners get corners => Theme.of(this).extension<Corners>() ?? const Corners();
}

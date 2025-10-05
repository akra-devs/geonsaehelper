import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_state.freezed.dart';

@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState({
    required ThemeMode mode,
  }) = _ThemeState;

  factory ThemeState.light() => const ThemeState(mode: ThemeMode.light);
  factory ThemeState.dark() => const ThemeState(mode: ThemeMode.dark);
  factory ThemeState.system() => const ThemeState(mode: ThemeMode.system);
}

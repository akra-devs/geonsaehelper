import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_state.freezed.dart';

@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState({
    required ThemeMode mode,
  }) = _ThemeState;

  const factory ThemeState.light() = _ThemeLight;
  const factory ThemeState.dark() = _ThemeDark;
  const factory ThemeState.system() = _ThemeSystem;
}

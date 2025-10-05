// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ThemeState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(ThemeMode mode) $default, {
    required TResult Function() light,
    required TResult Function() dark,
    required TResult Function() system,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(ThemeMode mode)? $default, {
    TResult? Function()? light,
    TResult? Function()? dark,
    TResult? Function()? system,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(ThemeMode mode)? $default, {
    TResult Function()? light,
    TResult Function()? dark,
    TResult Function()? system,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ThemeState value) $default, {
    required TResult Function(_ThemeLight value) light,
    required TResult Function(_ThemeDark value) dark,
    required TResult Function(_ThemeSystem value) system,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ThemeState value)? $default, {
    TResult? Function(_ThemeLight value)? light,
    TResult? Function(_ThemeDark value)? dark,
    TResult? Function(_ThemeSystem value)? system,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ThemeState value)? $default, {
    TResult Function(_ThemeLight value)? light,
    TResult Function(_ThemeDark value)? dark,
    TResult Function(_ThemeSystem value)? system,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemeStateCopyWith<$Res> {
  factory $ThemeStateCopyWith(
    ThemeState value,
    $Res Function(ThemeState) then,
  ) = _$ThemeStateCopyWithImpl<$Res, ThemeState>;
}

/// @nodoc
class _$ThemeStateCopyWithImpl<$Res, $Val extends ThemeState>
    implements $ThemeStateCopyWith<$Res> {
  _$ThemeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ThemeStateImplCopyWith<$Res> {
  factory _$$ThemeStateImplCopyWith(
    _$ThemeStateImpl value,
    $Res Function(_$ThemeStateImpl) then,
  ) = __$$ThemeStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ThemeMode mode});
}

/// @nodoc
class __$$ThemeStateImplCopyWithImpl<$Res>
    extends _$ThemeStateCopyWithImpl<$Res, _$ThemeStateImpl>
    implements _$$ThemeStateImplCopyWith<$Res> {
  __$$ThemeStateImplCopyWithImpl(
    _$ThemeStateImpl _value,
    $Res Function(_$ThemeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? mode = null}) {
    return _then(
      _$ThemeStateImpl(
        mode:
            null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                    as ThemeMode,
      ),
    );
  }
}

/// @nodoc

class _$ThemeStateImpl implements _ThemeState {
  const _$ThemeStateImpl({required this.mode});

  @override
  final ThemeMode mode;

  @override
  String toString() {
    return 'ThemeState(mode: $mode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemeStateImpl &&
            (identical(other.mode, mode) || other.mode == mode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mode);

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemeStateImplCopyWith<_$ThemeStateImpl> get copyWith =>
      __$$ThemeStateImplCopyWithImpl<_$ThemeStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(ThemeMode mode) $default, {
    required TResult Function() light,
    required TResult Function() dark,
    required TResult Function() system,
  }) {
    return $default(mode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(ThemeMode mode)? $default, {
    TResult? Function()? light,
    TResult? Function()? dark,
    TResult? Function()? system,
  }) {
    return $default?.call(mode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(ThemeMode mode)? $default, {
    TResult Function()? light,
    TResult Function()? dark,
    TResult Function()? system,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(mode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ThemeState value) $default, {
    required TResult Function(_ThemeLight value) light,
    required TResult Function(_ThemeDark value) dark,
    required TResult Function(_ThemeSystem value) system,
  }) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ThemeState value)? $default, {
    TResult? Function(_ThemeLight value)? light,
    TResult? Function(_ThemeDark value)? dark,
    TResult? Function(_ThemeSystem value)? system,
  }) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ThemeState value)? $default, {
    TResult Function(_ThemeLight value)? light,
    TResult Function(_ThemeDark value)? dark,
    TResult Function(_ThemeSystem value)? system,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _ThemeState implements ThemeState {
  const factory _ThemeState({required final ThemeMode mode}) = _$ThemeStateImpl;

  ThemeMode get mode;

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThemeStateImplCopyWith<_$ThemeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ThemeLightImplCopyWith<$Res> {
  factory _$$ThemeLightImplCopyWith(
    _$ThemeLightImpl value,
    $Res Function(_$ThemeLightImpl) then,
  ) = __$$ThemeLightImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ThemeLightImplCopyWithImpl<$Res>
    extends _$ThemeStateCopyWithImpl<$Res, _$ThemeLightImpl>
    implements _$$ThemeLightImplCopyWith<$Res> {
  __$$ThemeLightImplCopyWithImpl(
    _$ThemeLightImpl _value,
    $Res Function(_$ThemeLightImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ThemeLightImpl implements _ThemeLight {
  const _$ThemeLightImpl();

  @override
  String toString() {
    return 'ThemeState.light()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ThemeLightImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(ThemeMode mode) $default, {
    required TResult Function() light,
    required TResult Function() dark,
    required TResult Function() system,
  }) {
    return light();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(ThemeMode mode)? $default, {
    TResult? Function()? light,
    TResult? Function()? dark,
    TResult? Function()? system,
  }) {
    return light?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(ThemeMode mode)? $default, {
    TResult Function()? light,
    TResult Function()? dark,
    TResult Function()? system,
    required TResult orElse(),
  }) {
    if (light != null) {
      return light();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ThemeState value) $default, {
    required TResult Function(_ThemeLight value) light,
    required TResult Function(_ThemeDark value) dark,
    required TResult Function(_ThemeSystem value) system,
  }) {
    return light(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ThemeState value)? $default, {
    TResult? Function(_ThemeLight value)? light,
    TResult? Function(_ThemeDark value)? dark,
    TResult? Function(_ThemeSystem value)? system,
  }) {
    return light?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ThemeState value)? $default, {
    TResult Function(_ThemeLight value)? light,
    TResult Function(_ThemeDark value)? dark,
    TResult Function(_ThemeSystem value)? system,
    required TResult orElse(),
  }) {
    if (light != null) {
      return light(this);
    }
    return orElse();
  }
}

abstract class _ThemeLight implements ThemeState {
  const factory _ThemeLight() = _$ThemeLightImpl;
}

/// @nodoc
abstract class _$$ThemeDarkImplCopyWith<$Res> {
  factory _$$ThemeDarkImplCopyWith(
    _$ThemeDarkImpl value,
    $Res Function(_$ThemeDarkImpl) then,
  ) = __$$ThemeDarkImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ThemeDarkImplCopyWithImpl<$Res>
    extends _$ThemeStateCopyWithImpl<$Res, _$ThemeDarkImpl>
    implements _$$ThemeDarkImplCopyWith<$Res> {
  __$$ThemeDarkImplCopyWithImpl(
    _$ThemeDarkImpl _value,
    $Res Function(_$ThemeDarkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ThemeDarkImpl implements _ThemeDark {
  const _$ThemeDarkImpl();

  @override
  String toString() {
    return 'ThemeState.dark()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ThemeDarkImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(ThemeMode mode) $default, {
    required TResult Function() light,
    required TResult Function() dark,
    required TResult Function() system,
  }) {
    return dark();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(ThemeMode mode)? $default, {
    TResult? Function()? light,
    TResult? Function()? dark,
    TResult? Function()? system,
  }) {
    return dark?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(ThemeMode mode)? $default, {
    TResult Function()? light,
    TResult Function()? dark,
    TResult Function()? system,
    required TResult orElse(),
  }) {
    if (dark != null) {
      return dark();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ThemeState value) $default, {
    required TResult Function(_ThemeLight value) light,
    required TResult Function(_ThemeDark value) dark,
    required TResult Function(_ThemeSystem value) system,
  }) {
    return dark(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ThemeState value)? $default, {
    TResult? Function(_ThemeLight value)? light,
    TResult? Function(_ThemeDark value)? dark,
    TResult? Function(_ThemeSystem value)? system,
  }) {
    return dark?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ThemeState value)? $default, {
    TResult Function(_ThemeLight value)? light,
    TResult Function(_ThemeDark value)? dark,
    TResult Function(_ThemeSystem value)? system,
    required TResult orElse(),
  }) {
    if (dark != null) {
      return dark(this);
    }
    return orElse();
  }
}

abstract class _ThemeDark implements ThemeState {
  const factory _ThemeDark() = _$ThemeDarkImpl;
}

/// @nodoc
abstract class _$$ThemeSystemImplCopyWith<$Res> {
  factory _$$ThemeSystemImplCopyWith(
    _$ThemeSystemImpl value,
    $Res Function(_$ThemeSystemImpl) then,
  ) = __$$ThemeSystemImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ThemeSystemImplCopyWithImpl<$Res>
    extends _$ThemeStateCopyWithImpl<$Res, _$ThemeSystemImpl>
    implements _$$ThemeSystemImplCopyWith<$Res> {
  __$$ThemeSystemImplCopyWithImpl(
    _$ThemeSystemImpl _value,
    $Res Function(_$ThemeSystemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ThemeSystemImpl implements _ThemeSystem {
  const _$ThemeSystemImpl();

  @override
  String toString() {
    return 'ThemeState.system()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ThemeSystemImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(ThemeMode mode) $default, {
    required TResult Function() light,
    required TResult Function() dark,
    required TResult Function() system,
  }) {
    return system();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(ThemeMode mode)? $default, {
    TResult? Function()? light,
    TResult? Function()? dark,
    TResult? Function()? system,
  }) {
    return system?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(ThemeMode mode)? $default, {
    TResult Function()? light,
    TResult Function()? dark,
    TResult Function()? system,
    required TResult orElse(),
  }) {
    if (system != null) {
      return system();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ThemeState value) $default, {
    required TResult Function(_ThemeLight value) light,
    required TResult Function(_ThemeDark value) dark,
    required TResult Function(_ThemeSystem value) system,
  }) {
    return system(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ThemeState value)? $default, {
    TResult? Function(_ThemeLight value)? light,
    TResult? Function(_ThemeDark value)? dark,
    TResult? Function(_ThemeSystem value)? system,
  }) {
    return system?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ThemeState value)? $default, {
    TResult Function(_ThemeLight value)? light,
    TResult Function(_ThemeDark value)? dark,
    TResult Function(_ThemeSystem value)? system,
    required TResult orElse(),
  }) {
    if (system != null) {
      return system(this);
    }
    return orElse();
  }
}

abstract class _ThemeSystem implements ThemeState {
  const factory _ThemeSystem() = _$ThemeSystemImpl;
}

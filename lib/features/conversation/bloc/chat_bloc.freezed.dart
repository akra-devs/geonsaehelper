// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChatState {
  String? get selectedProductType => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? selectedProductType) idle,
    required TResult Function(String? selectedProductType) loading,
    required TResult Function(BotReply reply, String? selectedProductType)
    success,
    required TResult Function(String message, String? selectedProductType)
    error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? selectedProductType)? idle,
    TResult? Function(String? selectedProductType)? loading,
    TResult? Function(BotReply reply, String? selectedProductType)? success,
    TResult? Function(String message, String? selectedProductType)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? selectedProductType)? idle,
    TResult Function(String? selectedProductType)? loading,
    TResult Function(BotReply reply, String? selectedProductType)? success,
    TResult Function(String message, String? selectedProductType)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatStateCopyWith<ChatState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
  @useResult
  $Res call({String? selectedProductType});
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? selectedProductType = freezed}) {
    return _then(
      _value.copyWith(
            selectedProductType:
                freezed == selectedProductType
                    ? _value.selectedProductType
                    : selectedProductType // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
    _$IdleImpl value,
    $Res Function(_$IdleImpl) then,
  ) = __$$IdleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? selectedProductType});
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
    : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? selectedProductType = freezed}) {
    return _then(
      _$IdleImpl(
        selectedProductType:
            freezed == selectedProductType
                ? _value.selectedProductType
                : selectedProductType // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$IdleImpl with DiagnosticableTreeMixin implements _Idle {
  const _$IdleImpl({this.selectedProductType});

  @override
  final String? selectedProductType;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChatState.idle(selectedProductType: $selectedProductType)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChatState.idle'))
      ..add(DiagnosticsProperty('selectedProductType', selectedProductType));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdleImpl &&
            (identical(other.selectedProductType, selectedProductType) ||
                other.selectedProductType == selectedProductType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedProductType);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdleImplCopyWith<_$IdleImpl> get copyWith =>
      __$$IdleImplCopyWithImpl<_$IdleImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? selectedProductType) idle,
    required TResult Function(String? selectedProductType) loading,
    required TResult Function(BotReply reply, String? selectedProductType)
    success,
    required TResult Function(String message, String? selectedProductType)
    error,
  }) {
    return idle(selectedProductType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? selectedProductType)? idle,
    TResult? Function(String? selectedProductType)? loading,
    TResult? Function(BotReply reply, String? selectedProductType)? success,
    TResult? Function(String message, String? selectedProductType)? error,
  }) {
    return idle?.call(selectedProductType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? selectedProductType)? idle,
    TResult Function(String? selectedProductType)? loading,
    TResult Function(BotReply reply, String? selectedProductType)? success,
    TResult Function(String message, String? selectedProductType)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(selectedProductType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _Idle implements ChatState {
  const factory _Idle({final String? selectedProductType}) = _$IdleImpl;

  @override
  String? get selectedProductType;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdleImplCopyWith<_$IdleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? selectedProductType});
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? selectedProductType = freezed}) {
    return _then(
      _$LoadingImpl(
        selectedProductType:
            freezed == selectedProductType
                ? _value.selectedProductType
                : selectedProductType // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$LoadingImpl with DiagnosticableTreeMixin implements _Loading {
  const _$LoadingImpl({this.selectedProductType});

  @override
  final String? selectedProductType;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChatState.loading(selectedProductType: $selectedProductType)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChatState.loading'))
      ..add(DiagnosticsProperty('selectedProductType', selectedProductType));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadingImpl &&
            (identical(other.selectedProductType, selectedProductType) ||
                other.selectedProductType == selectedProductType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedProductType);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadingImplCopyWith<_$LoadingImpl> get copyWith =>
      __$$LoadingImplCopyWithImpl<_$LoadingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? selectedProductType) idle,
    required TResult Function(String? selectedProductType) loading,
    required TResult Function(BotReply reply, String? selectedProductType)
    success,
    required TResult Function(String message, String? selectedProductType)
    error,
  }) {
    return loading(selectedProductType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? selectedProductType)? idle,
    TResult? Function(String? selectedProductType)? loading,
    TResult? Function(BotReply reply, String? selectedProductType)? success,
    TResult? Function(String message, String? selectedProductType)? error,
  }) {
    return loading?.call(selectedProductType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? selectedProductType)? idle,
    TResult Function(String? selectedProductType)? loading,
    TResult Function(BotReply reply, String? selectedProductType)? success,
    TResult Function(String message, String? selectedProductType)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(selectedProductType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements ChatState {
  const factory _Loading({final String? selectedProductType}) = _$LoadingImpl;

  @override
  String? get selectedProductType;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadingImplCopyWith<_$LoadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
    _$SuccessImpl value,
    $Res Function(_$SuccessImpl) then,
  ) = __$$SuccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({BotReply reply, String? selectedProductType});

  $BotReplyCopyWith<$Res> get reply;
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
    _$SuccessImpl _value,
    $Res Function(_$SuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reply = null, Object? selectedProductType = freezed}) {
    return _then(
      _$SuccessImpl(
        null == reply
            ? _value.reply
            : reply // ignore: cast_nullable_to_non_nullable
                as BotReply,
        selectedProductType:
            freezed == selectedProductType
                ? _value.selectedProductType
                : selectedProductType // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BotReplyCopyWith<$Res> get reply {
    return $BotReplyCopyWith<$Res>(_value.reply, (value) {
      return _then(_value.copyWith(reply: value));
    });
  }
}

/// @nodoc

class _$SuccessImpl with DiagnosticableTreeMixin implements _Success {
  const _$SuccessImpl(this.reply, {this.selectedProductType});

  @override
  final BotReply reply;
  @override
  final String? selectedProductType;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChatState.success(reply: $reply, selectedProductType: $selectedProductType)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChatState.success'))
      ..add(DiagnosticsProperty('reply', reply))
      ..add(DiagnosticsProperty('selectedProductType', selectedProductType));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            (identical(other.reply, reply) || other.reply == reply) &&
            (identical(other.selectedProductType, selectedProductType) ||
                other.selectedProductType == selectedProductType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reply, selectedProductType);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? selectedProductType) idle,
    required TResult Function(String? selectedProductType) loading,
    required TResult Function(BotReply reply, String? selectedProductType)
    success,
    required TResult Function(String message, String? selectedProductType)
    error,
  }) {
    return success(reply, selectedProductType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? selectedProductType)? idle,
    TResult? Function(String? selectedProductType)? loading,
    TResult? Function(BotReply reply, String? selectedProductType)? success,
    TResult? Function(String message, String? selectedProductType)? error,
  }) {
    return success?.call(reply, selectedProductType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? selectedProductType)? idle,
    TResult Function(String? selectedProductType)? loading,
    TResult Function(BotReply reply, String? selectedProductType)? success,
    TResult Function(String message, String? selectedProductType)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(reply, selectedProductType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements ChatState {
  const factory _Success(
    final BotReply reply, {
    final String? selectedProductType,
  }) = _$SuccessImpl;

  BotReply get reply;
  @override
  String? get selectedProductType;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? selectedProductType});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? selectedProductType = freezed}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String,
        selectedProductType:
            freezed == selectedProductType
                ? _value.selectedProductType
                : selectedProductType // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl with DiagnosticableTreeMixin implements _Error {
  const _$ErrorImpl(this.message, {this.selectedProductType});

  @override
  final String message;
  @override
  final String? selectedProductType;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChatState.error(message: $message, selectedProductType: $selectedProductType)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChatState.error'))
      ..add(DiagnosticsProperty('message', message))
      ..add(DiagnosticsProperty('selectedProductType', selectedProductType));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.selectedProductType, selectedProductType) ||
                other.selectedProductType == selectedProductType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, selectedProductType);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? selectedProductType) idle,
    required TResult Function(String? selectedProductType) loading,
    required TResult Function(BotReply reply, String? selectedProductType)
    success,
    required TResult Function(String message, String? selectedProductType)
    error,
  }) {
    return error(message, selectedProductType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? selectedProductType)? idle,
    TResult? Function(String? selectedProductType)? loading,
    TResult? Function(BotReply reply, String? selectedProductType)? success,
    TResult? Function(String message, String? selectedProductType)? error,
  }) {
    return error?.call(message, selectedProductType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? selectedProductType)? idle,
    TResult Function(String? selectedProductType)? loading,
    TResult Function(BotReply reply, String? selectedProductType)? success,
    TResult Function(String message, String? selectedProductType)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, selectedProductType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements ChatState {
  const factory _Error(
    final String message, {
    final String? selectedProductType,
  }) = _$ErrorImpl;

  String get message;
  @override
  String? get selectedProductType;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

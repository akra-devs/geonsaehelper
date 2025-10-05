// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConversationEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String qid, String value) choiceSelected,
    required TResult Function(String suggestionId) suggestionSelected,
    required TResult Function() reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String qid, String value)? choiceSelected,
    TResult? Function(String suggestionId)? suggestionSelected,
    TResult? Function()? reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String qid, String value)? choiceSelected,
    TResult Function(String suggestionId)? suggestionSelected,
    TResult Function()? reset,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConversationStarted value) started,
    required TResult Function(ChoiceSelected value) choiceSelected,
    required TResult Function(SuggestionSelected value) suggestionSelected,
    required TResult Function(ConversationReset value) reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConversationStarted value)? started,
    TResult? Function(ChoiceSelected value)? choiceSelected,
    TResult? Function(SuggestionSelected value)? suggestionSelected,
    TResult? Function(ConversationReset value)? reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConversationStarted value)? started,
    TResult Function(ChoiceSelected value)? choiceSelected,
    TResult Function(SuggestionSelected value)? suggestionSelected,
    TResult Function(ConversationReset value)? reset,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationEventCopyWith<$Res> {
  factory $ConversationEventCopyWith(
    ConversationEvent value,
    $Res Function(ConversationEvent) then,
  ) = _$ConversationEventCopyWithImpl<$Res, ConversationEvent>;
}

/// @nodoc
class _$ConversationEventCopyWithImpl<$Res, $Val extends ConversationEvent>
    implements $ConversationEventCopyWith<$Res> {
  _$ConversationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ConversationStartedImplCopyWith<$Res> {
  factory _$$ConversationStartedImplCopyWith(
    _$ConversationStartedImpl value,
    $Res Function(_$ConversationStartedImpl) then,
  ) = __$$ConversationStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ConversationStartedImplCopyWithImpl<$Res>
    extends _$ConversationEventCopyWithImpl<$Res, _$ConversationStartedImpl>
    implements _$$ConversationStartedImplCopyWith<$Res> {
  __$$ConversationStartedImplCopyWithImpl(
    _$ConversationStartedImpl _value,
    $Res Function(_$ConversationStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ConversationStartedImpl implements ConversationStarted {
  const _$ConversationStartedImpl();

  @override
  String toString() {
    return 'ConversationEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String qid, String value) choiceSelected,
    required TResult Function(String suggestionId) suggestionSelected,
    required TResult Function() reset,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String qid, String value)? choiceSelected,
    TResult? Function(String suggestionId)? suggestionSelected,
    TResult? Function()? reset,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String qid, String value)? choiceSelected,
    TResult Function(String suggestionId)? suggestionSelected,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConversationStarted value) started,
    required TResult Function(ChoiceSelected value) choiceSelected,
    required TResult Function(SuggestionSelected value) suggestionSelected,
    required TResult Function(ConversationReset value) reset,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConversationStarted value)? started,
    TResult? Function(ChoiceSelected value)? choiceSelected,
    TResult? Function(SuggestionSelected value)? suggestionSelected,
    TResult? Function(ConversationReset value)? reset,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConversationStarted value)? started,
    TResult Function(ChoiceSelected value)? choiceSelected,
    TResult Function(SuggestionSelected value)? suggestionSelected,
    TResult Function(ConversationReset value)? reset,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class ConversationStarted implements ConversationEvent {
  const factory ConversationStarted() = _$ConversationStartedImpl;
}

/// @nodoc
abstract class _$$ChoiceSelectedImplCopyWith<$Res> {
  factory _$$ChoiceSelectedImplCopyWith(
    _$ChoiceSelectedImpl value,
    $Res Function(_$ChoiceSelectedImpl) then,
  ) = __$$ChoiceSelectedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String qid, String value});
}

/// @nodoc
class __$$ChoiceSelectedImplCopyWithImpl<$Res>
    extends _$ConversationEventCopyWithImpl<$Res, _$ChoiceSelectedImpl>
    implements _$$ChoiceSelectedImplCopyWith<$Res> {
  __$$ChoiceSelectedImplCopyWithImpl(
    _$ChoiceSelectedImpl _value,
    $Res Function(_$ChoiceSelectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? qid = null, Object? value = null}) {
    return _then(
      _$ChoiceSelectedImpl(
        null == qid
            ? _value.qid
            : qid // ignore: cast_nullable_to_non_nullable
                as String,
        null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ChoiceSelectedImpl implements ChoiceSelected {
  const _$ChoiceSelectedImpl(this.qid, this.value);

  @override
  final String qid;
  @override
  final String value;

  @override
  String toString() {
    return 'ConversationEvent.choiceSelected(qid: $qid, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChoiceSelectedImpl &&
            (identical(other.qid, qid) || other.qid == qid) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, qid, value);

  /// Create a copy of ConversationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChoiceSelectedImplCopyWith<_$ChoiceSelectedImpl> get copyWith =>
      __$$ChoiceSelectedImplCopyWithImpl<_$ChoiceSelectedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String qid, String value) choiceSelected,
    required TResult Function(String suggestionId) suggestionSelected,
    required TResult Function() reset,
  }) {
    return choiceSelected(qid, value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String qid, String value)? choiceSelected,
    TResult? Function(String suggestionId)? suggestionSelected,
    TResult? Function()? reset,
  }) {
    return choiceSelected?.call(qid, value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String qid, String value)? choiceSelected,
    TResult Function(String suggestionId)? suggestionSelected,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (choiceSelected != null) {
      return choiceSelected(qid, value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConversationStarted value) started,
    required TResult Function(ChoiceSelected value) choiceSelected,
    required TResult Function(SuggestionSelected value) suggestionSelected,
    required TResult Function(ConversationReset value) reset,
  }) {
    return choiceSelected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConversationStarted value)? started,
    TResult? Function(ChoiceSelected value)? choiceSelected,
    TResult? Function(SuggestionSelected value)? suggestionSelected,
    TResult? Function(ConversationReset value)? reset,
  }) {
    return choiceSelected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConversationStarted value)? started,
    TResult Function(ChoiceSelected value)? choiceSelected,
    TResult Function(SuggestionSelected value)? suggestionSelected,
    TResult Function(ConversationReset value)? reset,
    required TResult orElse(),
  }) {
    if (choiceSelected != null) {
      return choiceSelected(this);
    }
    return orElse();
  }
}

abstract class ChoiceSelected implements ConversationEvent {
  const factory ChoiceSelected(final String qid, final String value) =
      _$ChoiceSelectedImpl;

  String get qid;
  String get value;

  /// Create a copy of ConversationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChoiceSelectedImplCopyWith<_$ChoiceSelectedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SuggestionSelectedImplCopyWith<$Res> {
  factory _$$SuggestionSelectedImplCopyWith(
    _$SuggestionSelectedImpl value,
    $Res Function(_$SuggestionSelectedImpl) then,
  ) = __$$SuggestionSelectedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String suggestionId});
}

/// @nodoc
class __$$SuggestionSelectedImplCopyWithImpl<$Res>
    extends _$ConversationEventCopyWithImpl<$Res, _$SuggestionSelectedImpl>
    implements _$$SuggestionSelectedImplCopyWith<$Res> {
  __$$SuggestionSelectedImplCopyWithImpl(
    _$SuggestionSelectedImpl _value,
    $Res Function(_$SuggestionSelectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? suggestionId = null}) {
    return _then(
      _$SuggestionSelectedImpl(
        null == suggestionId
            ? _value.suggestionId
            : suggestionId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$SuggestionSelectedImpl implements SuggestionSelected {
  const _$SuggestionSelectedImpl(this.suggestionId);

  @override
  final String suggestionId;

  @override
  String toString() {
    return 'ConversationEvent.suggestionSelected(suggestionId: $suggestionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuggestionSelectedImpl &&
            (identical(other.suggestionId, suggestionId) ||
                other.suggestionId == suggestionId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, suggestionId);

  /// Create a copy of ConversationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuggestionSelectedImplCopyWith<_$SuggestionSelectedImpl> get copyWith =>
      __$$SuggestionSelectedImplCopyWithImpl<_$SuggestionSelectedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String qid, String value) choiceSelected,
    required TResult Function(String suggestionId) suggestionSelected,
    required TResult Function() reset,
  }) {
    return suggestionSelected(suggestionId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String qid, String value)? choiceSelected,
    TResult? Function(String suggestionId)? suggestionSelected,
    TResult? Function()? reset,
  }) {
    return suggestionSelected?.call(suggestionId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String qid, String value)? choiceSelected,
    TResult Function(String suggestionId)? suggestionSelected,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (suggestionSelected != null) {
      return suggestionSelected(suggestionId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConversationStarted value) started,
    required TResult Function(ChoiceSelected value) choiceSelected,
    required TResult Function(SuggestionSelected value) suggestionSelected,
    required TResult Function(ConversationReset value) reset,
  }) {
    return suggestionSelected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConversationStarted value)? started,
    TResult? Function(ChoiceSelected value)? choiceSelected,
    TResult? Function(SuggestionSelected value)? suggestionSelected,
    TResult? Function(ConversationReset value)? reset,
  }) {
    return suggestionSelected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConversationStarted value)? started,
    TResult Function(ChoiceSelected value)? choiceSelected,
    TResult Function(SuggestionSelected value)? suggestionSelected,
    TResult Function(ConversationReset value)? reset,
    required TResult orElse(),
  }) {
    if (suggestionSelected != null) {
      return suggestionSelected(this);
    }
    return orElse();
  }
}

abstract class SuggestionSelected implements ConversationEvent {
  const factory SuggestionSelected(final String suggestionId) =
      _$SuggestionSelectedImpl;

  String get suggestionId;

  /// Create a copy of ConversationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuggestionSelectedImplCopyWith<_$SuggestionSelectedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConversationResetImplCopyWith<$Res> {
  factory _$$ConversationResetImplCopyWith(
    _$ConversationResetImpl value,
    $Res Function(_$ConversationResetImpl) then,
  ) = __$$ConversationResetImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ConversationResetImplCopyWithImpl<$Res>
    extends _$ConversationEventCopyWithImpl<$Res, _$ConversationResetImpl>
    implements _$$ConversationResetImplCopyWith<$Res> {
  __$$ConversationResetImplCopyWithImpl(
    _$ConversationResetImpl _value,
    $Res Function(_$ConversationResetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ConversationResetImpl implements ConversationReset {
  const _$ConversationResetImpl();

  @override
  String toString() {
    return 'ConversationEvent.reset()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ConversationResetImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String qid, String value) choiceSelected,
    required TResult Function(String suggestionId) suggestionSelected,
    required TResult Function() reset,
  }) {
    return reset();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String qid, String value)? choiceSelected,
    TResult? Function(String suggestionId)? suggestionSelected,
    TResult? Function()? reset,
  }) {
    return reset?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String qid, String value)? choiceSelected,
    TResult Function(String suggestionId)? suggestionSelected,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (reset != null) {
      return reset();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConversationStarted value) started,
    required TResult Function(ChoiceSelected value) choiceSelected,
    required TResult Function(SuggestionSelected value) suggestionSelected,
    required TResult Function(ConversationReset value) reset,
  }) {
    return reset(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConversationStarted value)? started,
    TResult? Function(ChoiceSelected value)? choiceSelected,
    TResult? Function(SuggestionSelected value)? suggestionSelected,
    TResult? Function(ConversationReset value)? reset,
  }) {
    return reset?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConversationStarted value)? started,
    TResult Function(ChoiceSelected value)? choiceSelected,
    TResult Function(SuggestionSelected value)? suggestionSelected,
    TResult Function(ConversationReset value)? reset,
    required TResult orElse(),
  }) {
    if (reset != null) {
      return reset(this);
    }
    return orElse();
  }
}

abstract class ConversationReset implements ConversationEvent {
  const factory ConversationReset() = _$ConversationResetImpl;
}

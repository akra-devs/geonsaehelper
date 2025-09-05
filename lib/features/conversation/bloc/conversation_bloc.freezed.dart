// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConversationState {
  ConversationPhase get phase => throw _privateConstructorUsedError;
  bool get awaitingChoice => throw _privateConstructorUsedError;
  ConversationQuestion? get question => throw _privateConstructorUsedError;
  ConversationResult? get result => throw _privateConstructorUsedError;
  String? get message =>
      throw _privateConstructorUsedError; // optional bot message to show
  String? get userEcho =>
      throw _privateConstructorUsedError; // optional user message to echo in UI
  String? get suggestionReply =>
      throw _privateConstructorUsedError; // optional bot reply from suggestion
  bool get resetTriggered => throw _privateConstructorUsedError;

  /// Create a copy of ConversationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationStateCopyWith<ConversationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationStateCopyWith<$Res> {
  factory $ConversationStateCopyWith(
    ConversationState value,
    $Res Function(ConversationState) then,
  ) = _$ConversationStateCopyWithImpl<$Res, ConversationState>;
  @useResult
  $Res call({
    ConversationPhase phase,
    bool awaitingChoice,
    ConversationQuestion? question,
    ConversationResult? result,
    String? message,
    String? userEcho,
    String? suggestionReply,
    bool resetTriggered,
  });
}

/// @nodoc
class _$ConversationStateCopyWithImpl<$Res, $Val extends ConversationState>
    implements $ConversationStateCopyWith<$Res> {
  _$ConversationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? awaitingChoice = null,
    Object? question = freezed,
    Object? result = freezed,
    Object? message = freezed,
    Object? userEcho = freezed,
    Object? suggestionReply = freezed,
    Object? resetTriggered = null,
  }) {
    return _then(
      _value.copyWith(
            phase:
                null == phase
                    ? _value.phase
                    : phase // ignore: cast_nullable_to_non_nullable
                        as ConversationPhase,
            awaitingChoice:
                null == awaitingChoice
                    ? _value.awaitingChoice
                    : awaitingChoice // ignore: cast_nullable_to_non_nullable
                        as bool,
            question:
                freezed == question
                    ? _value.question
                    : question // ignore: cast_nullable_to_non_nullable
                        as ConversationQuestion?,
            result:
                freezed == result
                    ? _value.result
                    : result // ignore: cast_nullable_to_non_nullable
                        as ConversationResult?,
            message:
                freezed == message
                    ? _value.message
                    : message // ignore: cast_nullable_to_non_nullable
                        as String?,
            userEcho:
                freezed == userEcho
                    ? _value.userEcho
                    : userEcho // ignore: cast_nullable_to_non_nullable
                        as String?,
            suggestionReply:
                freezed == suggestionReply
                    ? _value.suggestionReply
                    : suggestionReply // ignore: cast_nullable_to_non_nullable
                        as String?,
            resetTriggered:
                null == resetTriggered
                    ? _value.resetTriggered
                    : resetTriggered // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationStateImplCopyWith<$Res>
    implements $ConversationStateCopyWith<$Res> {
  factory _$$ConversationStateImplCopyWith(
    _$ConversationStateImpl value,
    $Res Function(_$ConversationStateImpl) then,
  ) = __$$ConversationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ConversationPhase phase,
    bool awaitingChoice,
    ConversationQuestion? question,
    ConversationResult? result,
    String? message,
    String? userEcho,
    String? suggestionReply,
    bool resetTriggered,
  });
}

/// @nodoc
class __$$ConversationStateImplCopyWithImpl<$Res>
    extends _$ConversationStateCopyWithImpl<$Res, _$ConversationStateImpl>
    implements _$$ConversationStateImplCopyWith<$Res> {
  __$$ConversationStateImplCopyWithImpl(
    _$ConversationStateImpl _value,
    $Res Function(_$ConversationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? awaitingChoice = null,
    Object? question = freezed,
    Object? result = freezed,
    Object? message = freezed,
    Object? userEcho = freezed,
    Object? suggestionReply = freezed,
    Object? resetTriggered = null,
  }) {
    return _then(
      _$ConversationStateImpl(
        phase:
            null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                    as ConversationPhase,
        awaitingChoice:
            null == awaitingChoice
                ? _value.awaitingChoice
                : awaitingChoice // ignore: cast_nullable_to_non_nullable
                    as bool,
        question:
            freezed == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                    as ConversationQuestion?,
        result:
            freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                    as ConversationResult?,
        message:
            freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String?,
        userEcho:
            freezed == userEcho
                ? _value.userEcho
                : userEcho // ignore: cast_nullable_to_non_nullable
                    as String?,
        suggestionReply:
            freezed == suggestionReply
                ? _value.suggestionReply
                : suggestionReply // ignore: cast_nullable_to_non_nullable
                    as String?,
        resetTriggered:
            null == resetTriggered
                ? _value.resetTriggered
                : resetTriggered // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$ConversationStateImpl implements _ConversationState {
  const _$ConversationStateImpl({
    required this.phase,
    required this.awaitingChoice,
    this.question,
    this.result,
    this.message,
    this.userEcho,
    this.suggestionReply,
    this.resetTriggered = false,
  });

  @override
  final ConversationPhase phase;
  @override
  final bool awaitingChoice;
  @override
  final ConversationQuestion? question;
  @override
  final ConversationResult? result;
  @override
  final String? message;
  // optional bot message to show
  @override
  final String? userEcho;
  // optional user message to echo in UI
  @override
  final String? suggestionReply;
  // optional bot reply from suggestion
  @override
  @JsonKey()
  final bool resetTriggered;

  @override
  String toString() {
    return 'ConversationState(phase: $phase, awaitingChoice: $awaitingChoice, question: $question, result: $result, message: $message, userEcho: $userEcho, suggestionReply: $suggestionReply, resetTriggered: $resetTriggered)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationStateImpl &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.awaitingChoice, awaitingChoice) ||
                other.awaitingChoice == awaitingChoice) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.userEcho, userEcho) ||
                other.userEcho == userEcho) &&
            (identical(other.suggestionReply, suggestionReply) ||
                other.suggestionReply == suggestionReply) &&
            (identical(other.resetTriggered, resetTriggered) ||
                other.resetTriggered == resetTriggered));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    phase,
    awaitingChoice,
    question,
    result,
    message,
    userEcho,
    suggestionReply,
    resetTriggered,
  );

  /// Create a copy of ConversationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationStateImplCopyWith<_$ConversationStateImpl> get copyWith =>
      __$$ConversationStateImplCopyWithImpl<_$ConversationStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ConversationState implements ConversationState {
  const factory _ConversationState({
    required final ConversationPhase phase,
    required final bool awaitingChoice,
    final ConversationQuestion? question,
    final ConversationResult? result,
    final String? message,
    final String? userEcho,
    final String? suggestionReply,
    final bool resetTriggered,
  }) = _$ConversationStateImpl;

  @override
  ConversationPhase get phase;
  @override
  bool get awaitingChoice;
  @override
  ConversationQuestion? get question;
  @override
  ConversationResult? get result;
  @override
  String? get message; // optional bot message to show
  @override
  String? get userEcho; // optional user message to echo in UI
  @override
  String? get suggestionReply; // optional bot reply from suggestion
  @override
  bool get resetTriggered;

  /// Create a copy of ConversationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationStateImplCopyWith<_$ConversationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

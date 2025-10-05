// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assessment_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssessmentHistory _$AssessmentHistoryFromJson(Map<String, dynamic> json) {
  return _AssessmentHistory.fromJson(json);
}

/// @nodoc
mixin _$AssessmentHistory {
  String get id =>
      throw _privateConstructorUsedError; // Unique identifier (e.g., UUID)
  DateTime get timestamp =>
      throw _privateConstructorUsedError; // When the assessment was completed
  RulingStatus get status =>
      throw _privateConstructorUsedError; // Overall ruling status
  String get tldr => throw _privateConstructorUsedError; // Summary from result
  Map<String, String> get responses =>
      throw _privateConstructorUsedError; // Question ID -> Answer value
  String? get lastVerified => throw _privateConstructorUsedError;

  /// Serializes this AssessmentHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssessmentHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssessmentHistoryCopyWith<AssessmentHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentHistoryCopyWith<$Res> {
  factory $AssessmentHistoryCopyWith(
    AssessmentHistory value,
    $Res Function(AssessmentHistory) then,
  ) = _$AssessmentHistoryCopyWithImpl<$Res, AssessmentHistory>;
  @useResult
  $Res call({
    String id,
    DateTime timestamp,
    RulingStatus status,
    String tldr,
    Map<String, String> responses,
    String? lastVerified,
  });
}

/// @nodoc
class _$AssessmentHistoryCopyWithImpl<$Res, $Val extends AssessmentHistory>
    implements $AssessmentHistoryCopyWith<$Res> {
  _$AssessmentHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssessmentHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? status = null,
    Object? tldr = null,
    Object? responses = null,
    Object? lastVerified = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as RulingStatus,
            tldr:
                null == tldr
                    ? _value.tldr
                    : tldr // ignore: cast_nullable_to_non_nullable
                        as String,
            responses:
                null == responses
                    ? _value.responses
                    : responses // ignore: cast_nullable_to_non_nullable
                        as Map<String, String>,
            lastVerified:
                freezed == lastVerified
                    ? _value.lastVerified
                    : lastVerified // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssessmentHistoryImplCopyWith<$Res>
    implements $AssessmentHistoryCopyWith<$Res> {
  factory _$$AssessmentHistoryImplCopyWith(
    _$AssessmentHistoryImpl value,
    $Res Function(_$AssessmentHistoryImpl) then,
  ) = __$$AssessmentHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime timestamp,
    RulingStatus status,
    String tldr,
    Map<String, String> responses,
    String? lastVerified,
  });
}

/// @nodoc
class __$$AssessmentHistoryImplCopyWithImpl<$Res>
    extends _$AssessmentHistoryCopyWithImpl<$Res, _$AssessmentHistoryImpl>
    implements _$$AssessmentHistoryImplCopyWith<$Res> {
  __$$AssessmentHistoryImplCopyWithImpl(
    _$AssessmentHistoryImpl _value,
    $Res Function(_$AssessmentHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssessmentHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? status = null,
    Object? tldr = null,
    Object? responses = null,
    Object? lastVerified = freezed,
  }) {
    return _then(
      _$AssessmentHistoryImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as RulingStatus,
        tldr:
            null == tldr
                ? _value.tldr
                : tldr // ignore: cast_nullable_to_non_nullable
                    as String,
        responses:
            null == responses
                ? _value._responses
                : responses // ignore: cast_nullable_to_non_nullable
                    as Map<String, String>,
        lastVerified:
            freezed == lastVerified
                ? _value.lastVerified
                : lastVerified // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentHistoryImpl implements _AssessmentHistory {
  const _$AssessmentHistoryImpl({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.tldr,
    required final Map<String, String> responses,
    this.lastVerified,
  }) : _responses = responses;

  factory _$AssessmentHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentHistoryImplFromJson(json);

  @override
  final String id;
  // Unique identifier (e.g., UUID)
  @override
  final DateTime timestamp;
  // When the assessment was completed
  @override
  final RulingStatus status;
  // Overall ruling status
  @override
  final String tldr;
  // Summary from result
  final Map<String, String> _responses;
  // Summary from result
  @override
  Map<String, String> get responses {
    if (_responses is EqualUnmodifiableMapView) return _responses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_responses);
  }

  // Question ID -> Answer value
  @override
  final String? lastVerified;

  @override
  String toString() {
    return 'AssessmentHistory(id: $id, timestamp: $timestamp, status: $status, tldr: $tldr, responses: $responses, lastVerified: $lastVerified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tldr, tldr) || other.tldr == tldr) &&
            const DeepCollectionEquality().equals(
              other._responses,
              _responses,
            ) &&
            (identical(other.lastVerified, lastVerified) ||
                other.lastVerified == lastVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timestamp,
    status,
    tldr,
    const DeepCollectionEquality().hash(_responses),
    lastVerified,
  );

  /// Create a copy of AssessmentHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentHistoryImplCopyWith<_$AssessmentHistoryImpl> get copyWith =>
      __$$AssessmentHistoryImplCopyWithImpl<_$AssessmentHistoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentHistoryImplToJson(this);
  }
}

abstract class _AssessmentHistory implements AssessmentHistory {
  const factory _AssessmentHistory({
    required final String id,
    required final DateTime timestamp,
    required final RulingStatus status,
    required final String tldr,
    required final Map<String, String> responses,
    final String? lastVerified,
  }) = _$AssessmentHistoryImpl;

  factory _AssessmentHistory.fromJson(Map<String, dynamic> json) =
      _$AssessmentHistoryImpl.fromJson;

  @override
  String get id; // Unique identifier (e.g., UUID)
  @override
  DateTime get timestamp; // When the assessment was completed
  @override
  RulingStatus get status; // Overall ruling status
  @override
  String get tldr; // Summary from result
  @override
  Map<String, String> get responses; // Question ID -> Answer value
  @override
  String? get lastVerified;

  /// Create a copy of AssessmentHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssessmentHistoryImplCopyWith<_$AssessmentHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatCitation _$ChatCitationFromJson(Map<String, dynamic> json) {
  return _ChatCitation.fromJson(json);
}

/// @nodoc
mixin _$ChatCitation {
  String get docId => throw _privateConstructorUsedError;
  String get sectionKey => throw _privateConstructorUsedError;

  /// Serializes this ChatCitation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatCitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatCitationCopyWith<ChatCitation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatCitationCopyWith<$Res> {
  factory $ChatCitationCopyWith(
    ChatCitation value,
    $Res Function(ChatCitation) then,
  ) = _$ChatCitationCopyWithImpl<$Res, ChatCitation>;
  @useResult
  $Res call({String docId, String sectionKey});
}

/// @nodoc
class _$ChatCitationCopyWithImpl<$Res, $Val extends ChatCitation>
    implements $ChatCitationCopyWith<$Res> {
  _$ChatCitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatCitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? docId = null, Object? sectionKey = null}) {
    return _then(
      _value.copyWith(
            docId:
                null == docId
                    ? _value.docId
                    : docId // ignore: cast_nullable_to_non_nullable
                        as String,
            sectionKey:
                null == sectionKey
                    ? _value.sectionKey
                    : sectionKey // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatCitationImplCopyWith<$Res>
    implements $ChatCitationCopyWith<$Res> {
  factory _$$ChatCitationImplCopyWith(
    _$ChatCitationImpl value,
    $Res Function(_$ChatCitationImpl) then,
  ) = __$$ChatCitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String docId, String sectionKey});
}

/// @nodoc
class __$$ChatCitationImplCopyWithImpl<$Res>
    extends _$ChatCitationCopyWithImpl<$Res, _$ChatCitationImpl>
    implements _$$ChatCitationImplCopyWith<$Res> {
  __$$ChatCitationImplCopyWithImpl(
    _$ChatCitationImpl _value,
    $Res Function(_$ChatCitationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatCitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? docId = null, Object? sectionKey = null}) {
    return _then(
      _$ChatCitationImpl(
        docId:
            null == docId
                ? _value.docId
                : docId // ignore: cast_nullable_to_non_nullable
                    as String,
        sectionKey:
            null == sectionKey
                ? _value.sectionKey
                : sectionKey // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatCitationImpl implements _ChatCitation {
  const _$ChatCitationImpl({required this.docId, required this.sectionKey});

  factory _$ChatCitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatCitationImplFromJson(json);

  @override
  final String docId;
  @override
  final String sectionKey;

  @override
  String toString() {
    return 'ChatCitation(docId: $docId, sectionKey: $sectionKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatCitationImpl &&
            (identical(other.docId, docId) || other.docId == docId) &&
            (identical(other.sectionKey, sectionKey) ||
                other.sectionKey == sectionKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, docId, sectionKey);

  /// Create a copy of ChatCitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatCitationImplCopyWith<_$ChatCitationImpl> get copyWith =>
      __$$ChatCitationImplCopyWithImpl<_$ChatCitationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatCitationImplToJson(this);
  }
}

abstract class _ChatCitation implements ChatCitation {
  const factory _ChatCitation({
    required final String docId,
    required final String sectionKey,
  }) = _$ChatCitationImpl;

  factory _ChatCitation.fromJson(Map<String, dynamic> json) =
      _$ChatCitationImpl.fromJson;

  @override
  String get docId;
  @override
  String get sectionKey;

  /// Create a copy of ChatCitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatCitationImplCopyWith<_$ChatCitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BotReply _$BotReplyFromJson(Map<String, dynamic> json) {
  return _BotReply.fromJson(json);
}

/// @nodoc
mixin _$BotReply {
  String get content => throw _privateConstructorUsedError;
  List<ChatCitation> get citations => throw _privateConstructorUsedError;
  String get lastVerified => throw _privateConstructorUsedError;

  /// Serializes this BotReply to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BotReply
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BotReplyCopyWith<BotReply> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BotReplyCopyWith<$Res> {
  factory $BotReplyCopyWith(BotReply value, $Res Function(BotReply) then) =
      _$BotReplyCopyWithImpl<$Res, BotReply>;
  @useResult
  $Res call({
    String content,
    List<ChatCitation> citations,
    String lastVerified,
  });
}

/// @nodoc
class _$BotReplyCopyWithImpl<$Res, $Val extends BotReply>
    implements $BotReplyCopyWith<$Res> {
  _$BotReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BotReply
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? citations = null,
    Object? lastVerified = null,
  }) {
    return _then(
      _value.copyWith(
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            citations:
                null == citations
                    ? _value.citations
                    : citations // ignore: cast_nullable_to_non_nullable
                        as List<ChatCitation>,
            lastVerified:
                null == lastVerified
                    ? _value.lastVerified
                    : lastVerified // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BotReplyImplCopyWith<$Res>
    implements $BotReplyCopyWith<$Res> {
  factory _$$BotReplyImplCopyWith(
    _$BotReplyImpl value,
    $Res Function(_$BotReplyImpl) then,
  ) = __$$BotReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String content,
    List<ChatCitation> citations,
    String lastVerified,
  });
}

/// @nodoc
class __$$BotReplyImplCopyWithImpl<$Res>
    extends _$BotReplyCopyWithImpl<$Res, _$BotReplyImpl>
    implements _$$BotReplyImplCopyWith<$Res> {
  __$$BotReplyImplCopyWithImpl(
    _$BotReplyImpl _value,
    $Res Function(_$BotReplyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BotReply
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? citations = null,
    Object? lastVerified = null,
  }) {
    return _then(
      _$BotReplyImpl(
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        citations:
            null == citations
                ? _value._citations
                : citations // ignore: cast_nullable_to_non_nullable
                    as List<ChatCitation>,
        lastVerified:
            null == lastVerified
                ? _value.lastVerified
                : lastVerified // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BotReplyImpl implements _BotReply {
  const _$BotReplyImpl({
    required this.content,
    final List<ChatCitation> citations = const <ChatCitation>[],
    required this.lastVerified,
  }) : _citations = citations;

  factory _$BotReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$BotReplyImplFromJson(json);

  @override
  final String content;
  final List<ChatCitation> _citations;
  @override
  @JsonKey()
  List<ChatCitation> get citations {
    if (_citations is EqualUnmodifiableListView) return _citations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_citations);
  }

  @override
  final String lastVerified;

  @override
  String toString() {
    return 'BotReply(content: $content, citations: $citations, lastVerified: $lastVerified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BotReplyImpl &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(
              other._citations,
              _citations,
            ) &&
            (identical(other.lastVerified, lastVerified) ||
                other.lastVerified == lastVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    content,
    const DeepCollectionEquality().hash(_citations),
    lastVerified,
  );

  /// Create a copy of BotReply
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BotReplyImplCopyWith<_$BotReplyImpl> get copyWith =>
      __$$BotReplyImplCopyWithImpl<_$BotReplyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BotReplyImplToJson(this);
  }
}

abstract class _BotReply implements BotReply {
  const factory _BotReply({
    required final String content,
    final List<ChatCitation> citations,
    required final String lastVerified,
  }) = _$BotReplyImpl;

  factory _BotReply.fromJson(Map<String, dynamic> json) =
      _$BotReplyImpl.fromJson;

  @override
  String get content;
  @override
  List<ChatCitation> get citations;
  @override
  String get lastVerified;

  /// Create a copy of BotReply
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BotReplyImplCopyWith<_$BotReplyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

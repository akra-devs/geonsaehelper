// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatCitationImpl _$$ChatCitationImplFromJson(Map<String, dynamic> json) =>
    _$ChatCitationImpl(
      docId: json['docId'] as String,
      sectionKey: json['sectionKey'] as String,
    );

Map<String, dynamic> _$$ChatCitationImplToJson(_$ChatCitationImpl instance) =>
    <String, dynamic>{
      'docId': instance.docId,
      'sectionKey': instance.sectionKey,
    };

_$BotReplyImpl _$$BotReplyImplFromJson(Map<String, dynamic> json) =>
    _$BotReplyImpl(
      content: json['content'] as String,
      citations:
          (json['citations'] as List<dynamic>?)
              ?.map((e) => ChatCitation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ChatCitation>[],
      lastVerified: json['lastVerified'] as String,
    );

Map<String, dynamic> _$$BotReplyImplToJson(_$BotReplyImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
      'citations': instance.citations,
      'lastVerified': instance.lastVerified,
    };

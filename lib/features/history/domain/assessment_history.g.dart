// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssessmentHistoryImpl _$$AssessmentHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$AssessmentHistoryImpl(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  status: $enumDecode(_$RulingStatusEnumMap, json['status']),
  tldr: json['tldr'] as String,
  responses: Map<String, String>.from(json['responses'] as Map),
  lastVerified: json['lastVerified'] as String?,
);

Map<String, dynamic> _$$AssessmentHistoryImplToJson(
  _$AssessmentHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'status': _$RulingStatusEnumMap[instance.status]!,
  'tldr': instance.tldr,
  'responses': instance.responses,
  'lastVerified': instance.lastVerified,
};

const _$RulingStatusEnumMap = {
  RulingStatus.possible: 'possible',
  RulingStatus.notPossibleInfo: 'notPossibleInfo',
  RulingStatus.notPossibleDisq: 'notPossibleDisq',
};

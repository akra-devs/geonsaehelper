import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

@freezed
class ChatCitation with _$ChatCitation {
  const factory ChatCitation({
    required String docId,
    required String sectionKey,
  }) = _ChatCitation;
  factory ChatCitation.fromJson(Map<String, dynamic> json) =>
      _$ChatCitationFromJson(json);
}

@freezed
class BotReply with _$BotReply {
  const factory BotReply({
    required String content,
    @Default(<ChatCitation>[]) List<ChatCitation> citations,
    required String lastVerified, // YYYY-MM-DD
  }) = _BotReply;

  factory BotReply.fromJson(Map<String, dynamic> json) =>
      _$BotReplyFromJson(json);
}

class ChatError implements Exception {
  final String message;
  ChatError(this.message);
  @override
  String toString() => 'ChatError: $message';
}

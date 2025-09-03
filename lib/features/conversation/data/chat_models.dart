import 'package:flutter/material.dart';

@immutable
class ChatCitation {
  final String docId;
  final String sectionKey;
  const ChatCitation({required this.docId, required this.sectionKey});
}

@immutable
class BotReply {
  final String content;
  final List<ChatCitation> citations;
  final String lastVerified; // YYYY-MM-DD
  const BotReply({required this.content, required this.citations, required this.lastVerified});

  factory BotReply.fromJson(Map<String, dynamic> json) {
    final cites = (json['citations'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((e) => ChatCitation(docId: e['docId'] ?? '', sectionKey: e['section'] ?? e['sectionKey'] ?? ''))
        .toList();
    return BotReply(
      content: json['content'] ?? '',
      citations: cites,
      lastVerified: json['lastVerified'] ?? '',
    );
  }
}

class ChatError implements Exception {
  final String message;
  ChatError(this.message);
  @override
  String toString() => 'ChatError: $message';
}


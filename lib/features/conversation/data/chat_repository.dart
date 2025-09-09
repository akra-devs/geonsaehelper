import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/constants.dart';
import 'chat_models.dart';
import '../domain/citation_schema.dart';

abstract class ChatRepository {
  Future<void> ensureSession();
  Future<BotReply> complete(String userText);
}

class ApiChatRepository implements ChatRepository {
  final String baseUrl; // e.g., http://localhost:8080/api
  final http.Client _client;
  String? _sessionId;

  ApiChatRepository({String? baseUrl, http.Client? client})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'CHAT_API_BASE',
            defaultValue: 'http://localhost:8080/api',
          ),
      _client = client ?? http.Client();

  @override
  Future<void> ensureSession() async {
    if (_sessionId != null) return;
    final r = await _client.post(Uri.parse('$baseUrl/chat/session'));
    if (r.statusCode ~/ 100 != 2) {
      throw ChatError('session create failed (${r.statusCode})');
    }
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    _sessionId = body['sessionId']?.toString();
    if (_sessionId == null || _sessionId!.isEmpty) {
      throw ChatError('invalid session id');
    }
  }

  @override
  Future<BotReply> complete(String userText) async {
    await ensureSession();
    // Optional: send message to history endpoint (if server expects)
    await _client.post(
      Uri.parse('$baseUrl/chat/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': _sessionId,
        'role': 'user',
        'content': userText,
      }),
    );

    final r = await _client.post(
      Uri.parse('$baseUrl/chat/complete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sessionId': _sessionId, 'prompt': userText}),
    );
    if (r.statusCode ~/ 100 != 2) {
      throw ChatError('complete failed (${r.statusCode})');
    }
    final raw = jsonDecode(r.body) as Map<String, dynamic>;
    final norm = _normalizeReplyJson(raw);
    return BotReply.fromJson(norm);
  }
}

/// Mock fallback for local/dev when API server is not available.
class MockChatRepository implements ChatRepository {
  final String lastVerified;
  MockChatRepository({this.lastVerified = rulesLastVerifiedYmd});
  @override
  Future<void> ensureSession() async {}

  @override
  Future<BotReply> complete(String userText) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return BotReply(
      content:
          'TL;DR: 서류는 신분증, 가족·혼인관계, 소득 증빙이 기본입니다. 다음 단계에서 발급처/순서를 안내해 드립니다.',
      citations: const [
        ChatCitation(
          docId: 'HUG_POLICY_DOCS/HUG_POLICY.md',
          sectionKey: 'RENT_STANDARD:eligibility',
        ),
      ],
      lastVerified: lastVerified,
    );
  }
}

Map<String, dynamic> _normalizeReplyJson(Map<String, dynamic> json) {
  final out = Map<String, dynamic>.from(json);
  final rawCitations = (out['citations'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();

  final normalized = <Map<String, dynamic>>[];
  for (final m in rawCitations) {
    // Accept either 'section' or 'sectionKey'
    if (!m.containsKey('sectionKey') && m.containsKey('section')) {
      m['sectionKey'] = m['section'];
    }
    final docId = CitationSchema.normalizeDocId(m['docId']?.toString() ?? '');
    final sectionKey = (m['sectionKey'] ?? '').toString();
    if (CitationSchema.isValid(docId, sectionKey)) {
      normalized.add({'docId': docId, 'sectionKey': sectionKey});
    }
  }
  out['citations'] = normalized;
  return out;
}

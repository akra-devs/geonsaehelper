import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/constants.dart';
import '../domain/citation_schema.dart';
import 'chat_models.dart';

abstract class ChatRepository {
  Future<BotReply> complete(String userText, {List<String>? productTypes});
  Future<bool> isHealthy();
}

class ApiChatRepository implements ChatRepository {
  final String baseUrl; // e.g., http://localhost:8080
  final http.Client _client;

  ApiChatRepository({String? baseUrl, http.Client? client})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'CHAT_API_BASE',
            defaultValue: 'http://localhost:8080',
          ),
      _client = client ?? http.Client();

  Uri _resolvePath(String path) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final trimmed = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse(base).resolve(trimmed);
  }

  @override
  Future<bool> isHealthy() async {
    const overridePath = String.fromEnvironment('CHAT_HEALTH_PATH', defaultValue: '');
    final candidates = <String>[
      if (overridePath.isNotEmpty) overridePath,
      'api/health',
    ];

    for (final path in candidates) {
      final isAbsolute = path.contains('://');
      final normalizedPath = isAbsolute || !path.startsWith('/')
          ? path
          : path.substring(1);
      final uri = isAbsolute ? Uri.parse(path) : _resolvePath(normalizedPath);
      print('🔍 Health check URL: $uri');
      try {
        final response = await _client
            .get(
              uri,
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 10));
        print('✅ Health check response: ${response.statusCode}');
        if (response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        print('❌ Health check failed: $e');
        print('🔍 Base URL being used: $baseUrl');
      }
    }
    return false;
  }

  @override
  Future<BotReply> complete(String userText, {List<String>? productTypes}) async {
    const streamPath = String.fromEnvironment(
      'CHAT_STREAM_PATH',
      defaultValue: 'api/loan-advisor/stream',
    );
    final uri = _resolvePath(streamPath);
    print('🔗 Connecting to: $uri');

    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Accept': 'text/event-stream',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({
        'question': userText,
        'productTypes': productTypes ?? _getDefaultProductTypes(),
        'topK': 3,
        'provider': 'OPENAI',
      });

    late final http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await _client.send(request);
    } catch (e) {
      throw ChatError('stream request failed ($e)');
    }

    if (streamedResponse.statusCode ~/ 100 != 2) {
      throw ChatError('stream request failed (${streamedResponse.statusCode})');
    }

    final content = StringBuffer();
    final citations = <ChatCitation>[];
    final seenCitations = <String>{};
    var lastVerified = rulesLastVerifiedYmd;
    var isDone = false;

    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      for (final rawLine in lines) {
        final line = rawLine.trimRight();
        if (line.isEmpty || !line.startsWith('data:')) continue;

        final sep = line.indexOf(':');
        if (sep == -1) continue;
        final data = line.substring(sep + 1).trim();
        if (data.isEmpty) continue;

        if (data == '[DONE]') {
          isDone = true;
          break;
        }

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final chunkContent = json['content'];
          if (chunkContent is String && chunkContent.isNotEmpty) {
            content.write(chunkContent);
          }

          final rawCitations = json['citations'];
          if (rawCitations is List) {
            for (final cite in rawCitations.whereType<Map<String, dynamic>>()) {
              final rawDocId = cite['docId']?.toString() ?? '';
              final sectionValue = cite.containsKey('sectionKey')
                  ? cite['sectionKey']
                  : cite['section'];
              final sectionKey = sectionValue == null ? '' : sectionValue.toString();
              if (rawDocId.isEmpty || sectionKey.isEmpty) continue;
              final normalizedDocId = CitationSchema.normalizeDocId(rawDocId);
              if (!CitationSchema.isValid(normalizedDocId, sectionKey)) continue;
              final key = '$normalizedDocId#$sectionKey';
              if (seenCitations.add(key)) {
                citations.add(ChatCitation(docId: normalizedDocId, sectionKey: sectionKey));
              }
            }
          }

          final chunkLastVerified = json['lastVerified'];
          if (chunkLastVerified is String && chunkLastVerified.isNotEmpty) {
            lastVerified = chunkLastVerified;
          }
        } catch (_) {
          // Ignore malformed JSON chunk
        }
      }
      if (isDone) break;
    }

    final replyText = content.toString().trim();
    if (replyText.isEmpty) {
      throw ChatError('stream produced no content');
    }

    return BotReply(
      content: replyText,
      citations: citations,
      lastVerified: lastVerified,
    );
  }

  List<String> _getDefaultProductTypes() {
    return [
      'RENT_STANDARD',
      'RENT_NEWLYWED',
      'RENT_YOUTH',
      'RENT_NEWBORN',
      'RENT_DAMAGES',
      'RENT_DAMAGES_PRIORITY',
    ];
  }
}

/// Mock fallback for local/dev when API server is not available.
class MockChatRepository implements ChatRepository {
  final String lastVerified;
  MockChatRepository({this.lastVerified = rulesLastVerifiedYmd});

  @override
  Future<bool> isHealthy() async => true; // Mock is always "healthy"

  @override
  Future<BotReply> complete(String userText, {List<String>? productTypes}) async {
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

/// Factory class for automatic repository selection based on health check
class ChatRepositoryFactory {
  static Future<ChatRepository> create({
    String? baseUrl,
    http.Client? client,
    bool forceApi = false,
    bool forceMock = false,
  }) async {
    // Explicit override options
    if (forceMock) {
      print('🔧 Using MockChatRepository (forced)');
      return MockChatRepository();
    }

    if (forceApi) {
      print('🔧 Using ApiChatRepository (forced - skipping health check)');
      return ApiChatRepository(baseUrl: baseUrl, client: client);
    }

    // Auto-detect based on health check
    final apiRepo = ApiChatRepository(baseUrl: baseUrl, client: client);

    print('🔍 Performing health check...');
    final isApiHealthy = await apiRepo.isHealthy();

    if (isApiHealthy) {
      print('✅ API server is healthy, using ApiChatRepository');
      return apiRepo;
    } else {
      print('🔄 API server not available, falling back to MockChatRepository');
      print('💡 To force API usage: flutter run --dart-define=FORCE_API_CHAT=true');
      return MockChatRepository();
    }
  }
}


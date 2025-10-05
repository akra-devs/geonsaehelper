import 'dart:convert';
import 'package:http/http.dart' as http;

/// Remote configuration fetched from GitHub repository
class RemoteConfig {
  final String chatApiBaseUrl;
  final String? chatStreamPath;
  final String? chatHealthPath;

  const RemoteConfig({
    required this.chatApiBaseUrl,
    this.chatStreamPath,
    this.chatHealthPath,
  });

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    return RemoteConfig(
      chatApiBaseUrl: json['chatApiBaseUrl'] as String,
      chatStreamPath: json['chatStreamPath'] as String?,
      chatHealthPath: json['chatHealthPath'] as String?,
    );
  }

  static const RemoteConfig fallback = RemoteConfig(
    chatApiBaseUrl: 'http://localhost:8080',
    chatStreamPath: 'api/loan-advisor/stream',
    chatHealthPath: 'api/health',
  );
}

/// Fetches remote configuration from GitHub repository
class RemoteConfigLoader {
  static const String _githubRawUrl =
      'https://raw.githubusercontent.com/akra-devs/geonsaehelper/main/config/app_config.json';

  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  RemoteConfigLoader({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch configuration from GitHub
  /// Falls back to [RemoteConfig.fallback] if fetch fails
  Future<RemoteConfig> load() async {
    try {
      print('📡 Fetching remote config from: $_githubRawUrl');

      final response = await _client
          .get(Uri.parse(_githubRawUrl))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final config = RemoteConfig.fromJson(json);
        print('✅ Remote config loaded: ${config.chatApiBaseUrl}');
        return config;
      } else {
        print('⚠️ Remote config fetch failed: ${response.statusCode}');
        return RemoteConfig.fallback;
      }
    } catch (e) {
      print('⚠️ Remote config fetch error: $e');
      print('📍 Using fallback config: ${RemoteConfig.fallback.chatApiBaseUrl}');
      return RemoteConfig.fallback;
    }
  }

  void dispose() {
    _client.close();
  }
}

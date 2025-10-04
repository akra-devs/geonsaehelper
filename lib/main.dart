import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'ui/theme/app_theme.dart';
import 'features/splash/ui/splash_page.dart';
import 'features/conversation/data/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<ChatRepository> _repositoryFuture;

  @override
  void initState() {
    super.initState();
    _repositoryFuture = _createRepository();
  }

  Future<ChatRepository> _createRepository() async {
    // Check environment variables for forced selection
    const forceMock = bool.fromEnvironment('FORCE_MOCK_CHAT', defaultValue: false);
    const forceApi = bool.fromEnvironment('FORCE_API_CHAT', defaultValue: false);
    const useApiChat = bool.fromEnvironment('USE_API_CHAT', defaultValue: false);

    // Optional override for local debugging; default keeps safe fallback to mock
    // Set to true if you always want to use API (bypassing health check)
    const debugForceApi = bool.fromEnvironment('DEBUG_FORCE_API', defaultValue: true);

    const rawBaseUrl = String.fromEnvironment('CHAT_API_BASE', defaultValue: '');
    final baseUrl = rawBaseUrl.isEmpty ? null : rawBaseUrl;

    return ChatRepositoryFactory.create(
      baseUrl: baseUrl,
      forceMock: forceMock,
      forceApi: forceApi || useApiChat || debugForceApi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatRepository>(
      future: _repositoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading during health check
          return MaterialApp(
            title: '전세자금대출 도우미',
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            themeMode: ThemeMode.system,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final repository = snapshot.data ?? MockChatRepository();

        return RepositoryProvider<ChatRepository>(
          create: (_) => repository,
          child: MaterialApp(
            title: '전세자금대출 도우미',
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            themeMode: ThemeMode.system,
            scrollBehavior: const _AppScrollBehavior(),
            home: const SplashPage(),
          ),
        );
      },
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

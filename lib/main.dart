import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'ui/theme/app_theme.dart';
import 'features/splash/ui/splash_page.dart';
import 'features/conversation/data/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const useApi = bool.fromEnvironment('USE_API_CHAT', defaultValue: false);
    return RepositoryProvider<ChatRepository>(
      create: (_) => useApi ? ApiChatRepository() : MockChatRepository(),
      child: MaterialApp(
        title: '전세자금대출 도우미',
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        scrollBehavior: const _AppScrollBehavior(),
        home: const SplashPage(),
      ),
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

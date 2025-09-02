import 'package:flutter/material.dart';
import 'ui/theme/app_theme.dart';
import 'features/conversation/ui/conversation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '전세자금대출 도우미',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const ConversationPage(),
    );
  }
}

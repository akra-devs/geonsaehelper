import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ui/theme/app_theme.dart';
import '../../conversation/ui/conversation_page.dart';
import '../../conversation/bloc/conversation_bloc.dart';
import '../../qna/ui/qna_page.dart';
import '../../../common/analytics/analytics.dart';
import 'package:http/http.dart' as http;

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    ConversationPage(),
    QnAPage(),
    _HistoryPage(),
    _SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Provide ConversationBloc at AppShell level so it's accessible across tabs
    return BlocProvider<ConversationBloc>(
      create: (_) => ConversationBloc(),
      child: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, conversationState) {
          // Check if ruling is complete
          final isRulingComplete = conversationState.phase == ConversationPhase.qna &&
              conversationState.result != null;

          return Scaffold(
            body: SafeArea(child: IndexedStack(index: _index, children: _pages)),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) {
                // Prevent access to AI chat tab if ruling not complete
                if (i == 1 && !isRulingComplete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('예비판정을 먼저 완료해주세요'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                setState(() => _index = i);
                final tab = switch (i) {
                  0 => 'start',
                  1 => 'ai_chat',
                  2 => 'history',
                  _ => 'settings',
                };
                Analytics.instance.tabChange(tab);
              },
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.play_circle_outline),
                  label: '시작',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: isRulingComplete
                        ? null
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                  ),
                  label: 'AI 대화',
                ),
                const NavigationDestination(icon: Icon(Icons.history), label: '히스토리'),
                const NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChecklistPage extends StatefulWidget {
  const _ChecklistPage();
  @override
  State<_ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<_ChecklistPage> {
  final _sections = <String, List<_ChecklistItem>>{
    '개인': [
      _ChecklistItem('신분증'),
      _ChecklistItem('가족·혼인관계 증명'),
      _ChecklistItem('소득 증빙'),
    ],
    '임대': [
      _ChecklistItem('임대차계약서 사본'),
      _ChecklistItem('등기부등본'),
      _ChecklistItem('건축물대장(필요 시)'),
    ],
    '절차': [
      _ChecklistItem('은행 상담 예약'),
      _ChecklistItem('서류 제출'),
      _ChecklistItem('심사 → 승인 → 실행'),
    ],
  };

  bool _healthLoading = false;

  Future<void> _runHealthCheck() async {
    if (_healthLoading) return;
    setState(() => _healthLoading = true);
    final uri = Uri.parse('http://localhost:8080/api/health');
    const headers = {'Accept': 'application/json'};
    final started = DateTime.now();
    debugPrint('🛰️ [health-check] GET $uri');
    debugPrint('🧾 [health-check] Request headers: ' +
        headers.entries.map((e) => '${e.key}: ${e.value}').join(', '));
    try {
      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 5),
          );
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      if (!mounted) return;
      debugPrint('✅ [health-check] Response ${response.statusCode} (${elapsed}ms)');
      response.headers.forEach((k, v) {
        debugPrint('📥 [health-check] $k: $v');
      });
      final bodyPreview = response.body.length > 240
          ? response.body.substring(0, 237) + '...'
          : response.body;
      debugPrint('📄 [health-check] Body: $bodyPreview');
      final status = response.statusCode;
      final preview = response.body.length > 120
          ? response.body.substring(0, 117) + '...'
          : response.body;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Health $status: $preview')),
      );
    } catch (e) {
      debugPrint('❌ [health-check] Failed: $e');
      if (!mounted) return;
      var message = 'Health check failed: $e';
      if (kIsWeb && e is http.ClientException && e.message.contains('Failed to fetch')) {
        message = '브라우저에서 CORS 정책 때문에 요청이 차단됐어요. 서버에서 Access-Control-Allow-Origin 헤더를 허용해야 합니다.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _healthLoading = false);
      } else {
        _healthLoading = false;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final total = _sections.values.fold<int>(0, (p, e) => p + e.length);
    final done = _sections.values.fold<int>(
      0,
      (p, e) => p + e.where((i) => i.done).length,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('서류 체크리스트')),
      floatingActionButton: FloatingActionButton(
        onPressed: _runHealthCheck,
        child: _healthLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.health_and_safety),
      ),
      body: _CenteredBody(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: spacing.x4),
          children: [
            // Overall progress
            Text('진행 현황', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: total > 0 ? done / total : 0),
            SizedBox(height: spacing.x3),
            for (final entry in _sections.entries) ...[
              // Section header with progress
              _SectionHeader(title: entry.key, items: entry.value),
              const SizedBox(height: 8),
              ...entry.value.map(
                (it) => CheckboxListTile(
                  value: it.done,
                  onChanged: (v) => setState(() => it.done = v ?? false),
                  title: Text(it.label),
                ),
              ),
              SizedBox(height: spacing.x2),
              Divider(color: Theme.of(context).colorScheme.outlineVariant),
              SizedBox(height: spacing.x2),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem {
  final String label;
  bool done;
  _ChecklistItem(this.label, {this.done = false});
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final List<_ChecklistItem> items;
  const _SectionHeader({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done = items.where((i) => i.done).length;
    final total = items.length;
    final value = total > 0 ? done / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '$done/$total',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: value, minHeight: 4),
      ],
    );
  }
}

class _HistoryPage extends StatelessWidget {
  const _HistoryPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('히스토리')),
      body: _CenteredBody(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: context.spacing.x4),
          children: const [_EmptyHint(text: '최근 판정/대화가 여기에 표시됩니다.')],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: context.spacing.x4),
        children: const [_EmptyHint(text: '테마/데이터/고지 설정이 여기에 표시됩니다.')],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing.x6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CenteredBody extends StatelessWidget {
  final Widget child;
  const _CenteredBody({required this.child});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.x4),
          child: child,
        ),
      ),
    );
  }
}

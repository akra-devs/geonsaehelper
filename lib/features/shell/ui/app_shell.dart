import 'package:flutter/material.dart';
import '../../../ui/theme/app_theme.dart';
import '../../conversation/ui/conversation_page.dart';
import '../../../common/analytics/analytics.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    ConversationPage(),
    _ChecklistPage(),
    _HistoryPage(),
    _SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          final tab = switch (i) { 0 => 'start', 1 => 'checklist', 2 => 'history', _ => 'settings' };
          Analytics.instance.tabChange(tab);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.play_circle_outline), label: '시작'),
          NavigationDestination(icon: Icon(Icons.fact_check), label: '체크리스트'),
          NavigationDestination(icon: Icon(Icons.history), label: '히스토리'),
          NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
        ],
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

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final total = _sections.values.fold<int>(0, (p, e) => p + e.length);
    final done = _sections.values.fold<int>(0, (p, e) => p + e.where((i) => i.done).length);
    return Scaffold(
      appBar: AppBar(title: const Text('서류 체크리스트')),
      body: _CenteredBody(child: ListView(
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
            ...entry.value.map((it) => CheckboxListTile(
                  value: it.done,
                  onChanged: (v) => setState(() => it.done = v ?? false),
                  title: Text(it.label),
                )),
            SizedBox(height: spacing.x2),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            SizedBox(height: spacing.x2),
          ],
        ],
      )),
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
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            Text('$done/$total', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
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
      body: _CenteredBody(child: ListView(
        padding: EdgeInsets.symmetric(vertical: context.spacing.x4),
        children: const [
          _EmptyHint(text: '최근 판정/대화가 여기에 표시됩니다.'),
        ],
      )),
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
        children: const [
          _EmptyHint(text: '테마/데이터/고지 설정이 여기에 표시됩니다.'),
        ],
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

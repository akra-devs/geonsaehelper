import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../ui/theme/app_theme.dart';
import '../domain/assessment_history.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../conversation/domain/models.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('히스토리'),
        actions: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              return state.maybeWhen(
                loaded: (items) => items.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.delete_sweep),
                        onPressed: () => _showClearDialog(context),
                        tooltip: '전체 삭제',
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: _CenteredBody(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: Text('초기화 중...')),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (items) => items.isEmpty
                  ? _EmptyHint()
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<HistoryBloc>().add(const HistoryEvent.load());
                      },
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          vertical: context.spacing.x4,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => SizedBox(
                          height: context.spacing.x3,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _HistoryCard(
                            history: item,
                            onDelete: () {
                              context
                                  .read<HistoryBloc>()
                                  .add(HistoryEvent.delete(item.id));
                            },
                          );
                        },
                      ),
                    ),
              error: (message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    SizedBox(height: context.spacing.x4),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HistoryBloc>().add(const HistoryEvent.load());
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showClearDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 히스토리를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<HistoryBloc>().add(const HistoryEvent.clear());
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final AssessmentHistory history;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.history,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final corners = context.corners;

    final statusColor = switch (history.status) {
      RulingStatus.possible => theme.colorScheme.primary,
      RulingStatus.notPossibleInfo => theme.colorScheme.tertiary,
      RulingStatus.notPossibleDisq => theme.colorScheme.error,
    };

    final statusLabel = switch (history.status) {
      RulingStatus.possible => '가능',
      RulingStatus.notPossibleInfo => '불가(정보 부족)',
      RulingStatus.notPossibleDisq => '불가(결격)',
    };

    final dateFormat = DateFormat('yyyy년 M월 d일 HH:mm');

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HistoryDetailPage(history: history),
            ),
          );
        },
        borderRadius: BorderRadius.circular(corners.md.toDouble()),
        child: Padding(
          padding: EdgeInsets.all(spacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.x3,
                      vertical: spacing.x1,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(corners.sm.toDouble()),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    iconSize: 20,
                    tooltip: '삭제',
                  ),
                ],
              ),
              SizedBox(height: spacing.x2),
              Text(
                history.tldr,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing.x3),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: spacing.x1),
                  Text(
                    dateFormat.format(history.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            SizedBox(height: context.spacing.x4),
            Text(
              '저장된 판정 결과가 없습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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

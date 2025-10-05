import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../ui/theme/app_theme.dart';
import '../domain/assessment_history.dart';
import '../data/history_repository.dart';
import '../../conversation/domain/models.dart';

class HistoryPage extends StatefulWidget {
  final HistoryRepository repository;

  const HistoryPage({super.key, required this.repository});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<AssessmentHistory>? _history;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final history = await widget.repository.getAll();
      if (mounted) {
        setState(() {
          _history = history;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('히스토리 로드 실패: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      await widget.repository.delete(id);
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 히스토리를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.repository.clear();
        await _loadHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('전체 삭제되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('히스토리'),
        actions: [
          if (_history != null && _history!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: '전체 삭제',
            ),
        ],
      ),
      body: _CenteredBody(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _history == null || _history!.isEmpty
                ? _EmptyHint()
                : RefreshIndicator(
                    onRefresh: _loadHistory,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        vertical: context.spacing.x4,
                      ),
                      itemCount: _history!.length,
                      separatorBuilder: (_, __) => SizedBox(
                        height: context.spacing.x3,
                      ),
                      itemBuilder: (context, index) {
                        final item = _history![index];
                        return _HistoryCard(
                          history: item,
                          onDelete: () => _deleteItem(item.id),
                        );
                      },
                    ),
                  ),
      ),
    );
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
                    color: statusColor.withOpacity(0.1),
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
              ],
            ),
          ],
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
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
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

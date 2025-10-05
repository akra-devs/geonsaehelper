import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../ui/theme/app_theme.dart';
import '../domain/assessment_history.dart';
import '../../conversation/domain/models.dart';

class HistoryDetailPage extends StatelessWidget {
  final AssessmentHistory history;

  const HistoryDetailPage({super.key, required this.history});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('판정 상세'),
      ),
      body: _CenteredBody(
        child: ListView(
          padding: EdgeInsets.all(spacing.x4),
          children: [
            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.x3,
                vertical: spacing.x2,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(corners.sm.toDouble()),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(history.status),
                    color: statusColor,
                    size: 20,
                  ),
                  SizedBox(width: spacing.x2),
                  Text(
                    statusLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.x4),

            // Timestamp
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: spacing.x2),
                Text(
                  dateFormat.format(history.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.x4),

            // TL;DR
            Card(
              child: Padding(
                padding: EdgeInsets.all(spacing.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '요약',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing.x2),
                    Text(
                      history.tldr,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.x3),

            // Responses
            if (history.responses.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '응답 내역',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spacing.x3),
                      ...history.responses.entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: spacing.x2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(
                                  entry.key,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: spacing.x3),
                              Expanded(
                                child: Text(
                                  _formatAnswerValue(entry.value),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing.x3),
            ],

            // Last verified
            if (history.lastVerified != null) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(spacing.x4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: spacing.x2),
                      Text(
                        '규정 최종 확인일: ${history.lastVerified}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(RulingStatus status) {
    return switch (status) {
      RulingStatus.possible => Icons.check_circle,
      RulingStatus.notPossibleInfo => Icons.info,
      RulingStatus.notPossibleDisq => Icons.cancel,
    };
  }

  String _formatAnswerValue(String value) {
    // Format common answer values for better readability
    if (value == 'yes') return '예';
    if (value == 'no') return '아니오';
    if (value == 'unknown') return '모름';
    return value;
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
        child: child,
      ),
    );
  }
}

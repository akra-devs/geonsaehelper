import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum RulingStatus { possible, notPossibleInfo, notPossibleDisq }

class ReasonItem {
  final IconData icon;
  final String text;
  final String type; // e.g., '충족' | '미충족' | '확인불가'
  const ReasonItem(this.icon, this.text, this.type);
}

class ResultCard extends StatelessWidget {
  final RulingStatus status;
  final String tldr;
  final List<ReasonItem> reasons;
  final List<String> nextSteps;
  final String lastVerified; // YYYY-MM-DD
  final VoidCallback? onExpand;

  const ResultCard({
    super.key,
    required this.status,
    required this.tldr,
    required this.reasons,
    required this.nextSteps,
    required this.lastVerified,
    this.onExpand,
  });

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case RulingStatus.possible:
        return Colors.green;
      case RulingStatus.notPossibleInfo:
        return Colors.amber[700] ?? cs.tertiary;
      case RulingStatus.notPossibleDisq:
        return cs.error;
    }
  }

  String _statusLabel() {
    switch (status) {
      case RulingStatus.possible:
        return '가능';
      case RulingStatus.notPossibleInfo:
        return '불가(정보 부족)';
      case RulingStatus.notPossibleDisq:
        return '불가(결격)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final corners = context.corners;
    return Semantics(
      label: 'ResultCard',
      child: Container(
        key: const Key('ResultCard.Container'),
        width: double.infinity,
        padding: EdgeInsets.all(spacing.x4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(corners.md),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _statusColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: spacing.x2),
                Text(_statusLabel(), style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                _LastVerifiedBadge(lastVerified: lastVerified),
              ],
            ),
            SizedBox(height: spacing.x3),
            Text(tldr, key: const Key('ResultCard.TLDR'), style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: spacing.x3),
            if (reasons.isNotEmpty) ...[
              Text('사유', style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: spacing.x2),
              Column(
                key: const Key('ResultCard.Reasons'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: reasons
                    .map((r) => Padding(
                          padding: EdgeInsets.only(bottom: spacing.x2),
                          child: Row(
                            children: [
                              Icon(r.icon, size: 18),
                              SizedBox(width: spacing.x2),
                              Expanded(child: Text(r.text)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: spacing.x3),
            ],
            if (nextSteps.isNotEmpty) ...[
              Text('다음 단계', style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: spacing.x2),
              Column(
                key: const Key('ResultCard.Next'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final s in nextSteps)
                    Padding(
                      padding: EdgeInsets.only(bottom: spacing.x2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(s)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LastVerifiedBadge extends StatelessWidget {
  final String lastVerified;
  const _LastVerifiedBadge({required this.lastVerified});
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.x2, vertical: spacing.x1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('마지막 확인일 $lastVerified', style: Theme.of(context).textTheme.labelSmall),
    );
  }
}


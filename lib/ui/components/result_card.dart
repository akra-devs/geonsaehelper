import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../common/analytics/analytics.dart';
import '../../features/conversation/domain/models.dart' as domain;

class ResultCard extends StatefulWidget {
  final domain.RulingStatus status;
  final String tldr;
  final List<domain.Reason> reasons;
  final List<String> nextSteps;
  final String lastVerified; // YYYY-MM-DD
  final VoidCallback? onExpand;
  final List<domain.ProgramMatch>? programMatches; // optional
  final void Function(domain.ProgramId programId)? onProgramHelp;

  const ResultCard({
    super.key,
    required this.status,
    required this.tldr,
    required this.reasons,
    required this.nextSteps,
    required this.lastVerified,
    this.onExpand,
    this.programMatches,
    this.onProgramHelp,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  bool _expandReasons = false;
  bool _expandNext = false;
  final Set<String> _loggedProgramShown = {};

  // Derive program badges from reasons/tags contained in the card
  List<String> _programBadges() {
    final pm = widget.programMatches;
    if (pm != null && pm.isNotEmpty) {
      final eligible = _sortedProgramMatches(pm)
          .where((m) => m.status == domain.RulingStatus.possible)
          .map((m) => _ProgramRow._programLabel(m.programId))
          .toList();
      return eligible;
    }
    final texts = widget.reasons.map((r) => r.text).join(' ');
    final out = <String>[];
    if (texts.contains('전세피해자')) out.add('특례(피해자)');
    if (texts.contains('신생아')) out.add('특례(신생아)');
    if (texts.contains('신혼')) out.add('신혼');
    if (texts.contains('청년')) out.add('청년');
    return out;
  }

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (widget.status) {
      case domain.RulingStatus.possible:
        return cs.primary;
      case domain.RulingStatus.notPossibleInfo:
        return cs.tertiary;
      case domain.RulingStatus.notPossibleDisq:
        return cs.error;
    }
  }

  IconData _statusIcon() {
    switch (widget.status) {
      case domain.RulingStatus.possible:
        return Icons.check_circle;
      case domain.RulingStatus.notPossibleInfo:
        return Icons.info;
      case domain.RulingStatus.notPossibleDisq:
        return Icons.error;
    }
  }

  String _statusLabel() {
    switch (widget.status) {
      case domain.RulingStatus.possible:
        return '가능';
      case domain.RulingStatus.notPossibleInfo:
        return '불가(정보 부족)';
      case domain.RulingStatus.notPossibleDisq:
        return '불가(결격)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final corners = context.corners;
    final pm = widget.programMatches ?? const <domain.ProgramMatch>[];
    final sortedPm = _sortedProgramMatches(pm);
    _logProgramShownOnce(sortedPm);
    return Semantics(
      label: 'ResultCard',
      child: Card(
        key: const Key('ResultCard.Container'),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(corners.md),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(spacing.x4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(corners.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.x2,
                      vertical: spacing.x1,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(context).withAlpha(31),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(),
                          color: _statusColor(context),
                          size: 16,
                        ),
                        SizedBox(width: spacing.x1),
                        Text(
                          _statusLabel(),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: _statusColor(context)),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _LastVerifiedBadge(lastVerified: widget.lastVerified),
                ],
              ),
              // ProgramMatches section (optional)
              if (sortedPm.isNotEmpty) ...[
                SizedBox(height: spacing.x3),
                Text('프로그램별 결과', style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: spacing.x2),
                Column(
                  children: [
                    for (int i = 0; i < sortedPm.length; i++)
                      _ProgramRow(
                        match: sortedPm[i],
                        position: i + 1,
                        onProgramHelp: widget.onProgramHelp,
                      ),
                  ],
                ),
              ],
              if (_programBadges().isNotEmpty) ...[
                SizedBox(height: spacing.x2),
                Wrap(
                  spacing: spacing.x2,
                  runSpacing: spacing.x1,
                  children:
                      _programBadges()
                          .map(
                            (b) => Chip(
                              label: Text(
                                b,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              visualDensity: const VisualDensity(
                                horizontal: -2,
                                vertical: -2,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
              SizedBox(height: spacing.x3),
              Text(
                widget.tldr,
                key: const Key('ResultCard.TLDR'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing.x3),
              if (widget.reasons.isNotEmpty) ...[
                Text('사유', style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: spacing.x2),
                Column(
                  key: const Key('ResultCard.Reasons'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      _visibleReasons().map((r) {
                        final color = _reasonColor(context, r.kind);
                        return Padding(
                          padding: EdgeInsets.only(bottom: spacing.x2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(_reasonIcon(r.kind), size: 14, color: color),
                              SizedBox(width: spacing.x2),
                              Expanded(
                                child: Text(
                                  r.text,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
                if (_showReasonsToggle())
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setState(() => _expandReasons = !_expandReasons);
                        Analytics.instance.reasonsExpand(_expandReasons);
                      },
                      child: Text(_expandReasons ? '접기' : '자세히'),
                    ),
                  ),
                SizedBox(height: spacing.x3),
              ],
              if (widget.nextSteps.isNotEmpty) ...[
                Text('다음 단계', style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: spacing.x2),
                Column(
                  key: const Key('ResultCard.Next'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in _visibleNextSteps())
                      InkWell(
                        onTap: () => Analytics.instance.nextStepClick(s),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: spacing.x2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.chevron_right,
                                size: 14,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: spacing.x1),
                              Expanded(child: Text(s)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (_showNextToggle())
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed:
                          () => setState(() => _expandNext = !_expandNext),
                      child: Text(_expandNext ? '접기' : '자세히'),
                    ),
                  ),
              ],
              SizedBox(height: spacing.x3),
              Text(
                '본 결과는 예비판정이며, 실제 심사 결과와 다를 수 있습니다. (금융자문 아님)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _reasonColor(BuildContext context, domain.ReasonKind kind) {
    final cs = Theme.of(context).colorScheme;
    switch (kind) {
      case domain.ReasonKind.met:
        return cs.primary;
      case domain.ReasonKind.unmet:
        return cs.error;
      case domain.ReasonKind.unknown:
      case domain.ReasonKind.warning:
        return cs.tertiary;
    }
  }

  IconData _reasonIcon(domain.ReasonKind kind) {
    switch (kind) {
      case domain.ReasonKind.met:
        return Icons.check_circle;
      case domain.ReasonKind.unmet:
        return Icons.cancel;
      case domain.ReasonKind.warning:
        return Icons.warning_amber;
      case domain.ReasonKind.unknown:
        return Icons.help_outline;
    }
  }

  List<domain.Reason> _visibleReasons() {
    final list = widget.reasons;
    if (_expandReasons) return list;
    const maxShown = 3;
    return list.length <= maxShown ? list : list.take(maxShown).toList();
  }

  List<String> _visibleNextSteps() {
    final list = widget.nextSteps;
    if (_expandNext) return list;
    const maxShown = 3;
    return list.length <= maxShown ? list : list.take(maxShown).toList();
  }

  bool _showReasonsToggle() => widget.reasons.length > 3;
  bool _showNextToggle() => widget.nextSteps.length > 3;

  void _logProgramShownOnce(List<domain.ProgramMatch> list) {
    for (int i = 0; i < list.length; i++) {
      final m = list[i];
      final key = '${m.programId.name}#${i + 1}';
      if (_loggedProgramShown.add(key)) {
        Analytics.instance.programShown(m.programId.name, i + 1);
      }
    }
  }
}

class _ProgramRow extends StatelessWidget {
  final domain.ProgramMatch match;
  final int position;
  final void Function(domain.ProgramId programId)? onProgramHelp;
  const _ProgramRow({required this.match, required this.position, this.onProgramHelp});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final cs = Theme.of(context).colorScheme;
    final color = _statusColorFor(match.status, cs);
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: spacing.x2, vertical: spacing.x1),
            decoration: BoxDecoration(
              color: color.withAlpha(24),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(_programLabel(match.programId), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
          ),
          SizedBox(width: spacing.x2),
          Icon(_iconFor(match.status), size: 14, color: color),
          SizedBox(width: spacing.x1),
          Text(_statusText(match.status), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
          SizedBox(width: spacing.x2),
          Expanded(
            child: Text(
              match.summary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          SizedBox(width: spacing.x2),
          TextButton(
            onPressed: () {
              Analytics.instance.programSelect(match.programId.name, 'docs');
              onProgramHelp?.call(match.programId);
            },
            child: const Text('확인 방법'),
          ),
        ],
      ),
    );
  }

  static String _programLabel(domain.ProgramId id) {
    switch (id) {
      case domain.ProgramId.RENT_DAMAGES:
        return '특례(피해자)';
      case domain.ProgramId.RENT_NEWBORN:
        return '특례(신생아)';
      case domain.ProgramId.RENT_NEWLYWED:
        return '신혼';
      case domain.ProgramId.RENT_YOUTH:
        return '청년';
      case domain.ProgramId.RENT_STANDARD:
        return '표준(버팀목)';
    }
  }

  static String _statusText(domain.RulingStatus s) {
    switch (s) {
      case domain.RulingStatus.possible:
        return '가능';
      case domain.RulingStatus.notPossibleInfo:
        return '정보 부족';
      case domain.RulingStatus.notPossibleDisq:
        return '결격';
    }
  }

  static IconData _iconFor(domain.RulingStatus s) {
    switch (s) {
      case domain.RulingStatus.possible:
        return Icons.check_circle;
      case domain.RulingStatus.notPossibleInfo:
        return Icons.info;
      case domain.RulingStatus.notPossibleDisq:
        return Icons.error;
    }
  }

  static Color _statusColorFor(domain.RulingStatus s, ColorScheme cs) {
    switch (s) {
      case domain.RulingStatus.possible:
        return cs.primary;
      case domain.RulingStatus.notPossibleInfo:
        return cs.tertiary;
      case domain.RulingStatus.notPossibleDisq:
        return cs.error;
    }
  }
}

//

// Sort order: 피해자 → 신생아 → 신혼 → 청년 → 표준
List<domain.ProgramMatch> _sortedProgramMatches(List<domain.ProgramMatch> list) {
  int rank(domain.ProgramId id) {
    switch (id) {
      case domain.ProgramId.RENT_DAMAGES:
        return 0;
      case domain.ProgramId.RENT_NEWBORN:
        return 1;
      case domain.ProgramId.RENT_NEWLYWED:
        return 2;
      case domain.ProgramId.RENT_YOUTH:
        return 3;
      case domain.ProgramId.RENT_STANDARD:
        return 4;
    }
  }
  final copy = [...list];
  copy.sort((a, b) => rank(a.programId).compareTo(rank(b.programId)));
  return copy;
}

class _LastVerifiedBadge extends StatelessWidget {
  final String lastVerified;
  const _LastVerifiedBadge({required this.lastVerified});
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final cs = Theme.of(context).colorScheme;
    final stale = _isStale(lastVerified);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.x2,
            vertical: spacing.x1,
          ),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, size: 14),
              SizedBox(width: spacing.x1),
              Text(
                '마지막 확인일 $lastVerified',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        if (stale) ...[
          SizedBox(width: spacing.x1),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.x2,
              vertical: spacing.x1,
            ),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '정보 최신성 확인 필요',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: cs.onErrorContainer),
            ),
          ),
        ],
      ],
    );
  }

  bool _isStale(String ymd) {
    try {
      final d = DateTime.parse(ymd);
      return DateTime.now().difference(d).inDays > 30;
    } catch (_) {
      return false;
    }
  }
}

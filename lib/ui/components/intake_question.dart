import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/conversation/domain/models.dart' as domain;

class IntakeQuestion extends StatelessWidget {
  final String qid; // e.g., A1..S1
  final String label;
  final List<domain.Choice> options; // value, text
  final String? selected; // selected value
  final bool showUnknown; // show "모름"
  final ValueChanged<String?> onChanged;
  final String? helper; // helper text
  final String? errorText;

  const IntakeQuestion({
    super.key,
    required this.qid,
    required this.label,
    required this.options,
    required this.onChanged,
    this.selected,
    this.showUnknown = true,
    this.helper,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final allOptions = <domain.Choice>[
      ...options,
      if (showUnknown) const domain.Choice(value: '__unknown__', text: '모름'),
    ];
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: 'IntakeQuestion $qid',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium, key: Key('Intake.$qid.Label')),
          SizedBox(height: spacing.x3),
          Wrap(
            spacing: spacing.x2,
            runSpacing: spacing.x2,
            children: [
              for (final c in allOptions)
                _Segment(
                  key: Key('Intake.$qid.${c.value}'),
                  label: c.text,
                  selected: selected == c.value,
                  isUnknown: c.value == '__unknown__',
                  onTap: () => onChanged(c.value),
                ),
            ],
          ),
          if (helper != null) ...[
            SizedBox(height: spacing.x2),
            Text(helper!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
          if (errorText != null) ...[
            SizedBox(height: spacing.x2),
            Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isUnknown;
  final VoidCallback onTap;
  const _Segment({super.key, required this.label, required this.selected, required this.isUnknown, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final corners = context.corners;
    final cs = Theme.of(context).colorScheme;
    final bg = selected ? cs.primaryContainer : cs.surface;
    final fg = selected ? cs.onPrimaryContainer : cs.onSurface;
    final bd = selected ? cs.primaryContainer : cs.outlineVariant;
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(corners.sm),
        side: BorderSide(color: bd),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(corners.sm),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.x3, vertical: spacing.x2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUnknown) ...[
                Icon(Icons.help_outline, size: 14, color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                SizedBox(width: spacing.x1),
              ],
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

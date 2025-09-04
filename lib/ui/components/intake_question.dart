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
                ChoiceChip(
                  key: Key('Intake.$qid.${c.value}'),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.text),
                    ],
                  ),
                  selected: selected == c.value,
                  onSelected: (_) => onChanged(c.value),
                ),
            ],
          ),
          if (helper != null) ...[
            SizedBox(height: spacing.x2),
            Text(helper!, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (errorText != null) ...[
            SizedBox(height: spacing.x2),
            Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

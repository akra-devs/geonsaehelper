import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SuggestionItem {
  final String label;
  final String botReply;
  const SuggestionItem(this.label, this.botReply);
}

class SuggestionsPanel extends StatelessWidget {
  final List<SuggestionItem> suggestions;
  final ValueChanged<SuggestionItem>? onTap;
  const SuggestionsPanel({super.key, required this.suggestions, this.onTap});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Wrap(
      spacing: spacing.x2,
      runSpacing: spacing.x2,
      children: [
        for (final s in suggestions)
          ActionChip(
            avatar: const Icon(Icons.tips_and_updates, size: 18),
            label: Text(s.label),
            onPressed: onTap == null ? null : () => onTap!(s),
          ),
      ],
    );
  }
}

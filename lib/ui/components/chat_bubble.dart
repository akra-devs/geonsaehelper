import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ChatRole { user, bot }

class Citation {
  final String docId;
  final String sectionKey;
  const Citation(this.docId, this.sectionKey);
}

class ChatBubble extends StatelessWidget {
  final ChatRole role;
  final String content;
  final List<Citation> citations;
  const ChatBubble({
    super.key,
    required this.role,
    required this.content,
    this.citations = const [],
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isUser = role == ChatRole.user;
    final cs = Theme.of(context).colorScheme;
    final bubbleColor =
        isUser ? cs.primaryContainer : cs.surfaceContainerHighest;
    final textColor = isUser ? cs.onPrimaryContainer : cs.onSurface;
    final r = context.corners.sm;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
      bottomLeft: Radius.circular(isUser ? r : 6),
      bottomRight: Radius.circular(isUser ? 6 : r),
    );
    return Semantics(
      label: 'Chat.${isUser ? 'user' : 'bot'}',
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.x2),
        child: Column(
          key: Key('Chat.${isUser ? 'user' : 'bot'}'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Material(
                    color: bubbleColor,
                    elevation: 0,
                    borderRadius: radius,
                    child: Padding(
                      padding: EdgeInsets.all(spacing.x3),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Text(
                          content,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: textColor, height: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (citations.isNotEmpty && !isUser)
              Padding(
                padding: EdgeInsets.only(top: spacing.x1),
                child: Wrap(
                  spacing: spacing.x2,
                  runSpacing: spacing.x2,
                  children: [
                    for (var i = 0; i < citations.length; i++)
                      Chip(
                        key: Key('Chat.Citation.$i'),
                        label: Text(
                          '${citations[i].docId} • ${citations[i].sectionKey}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        visualDensity: const VisualDensity(
                          horizontal: -2,
                          vertical: -2,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

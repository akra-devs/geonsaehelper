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
  const ChatBubble({super.key, required this.role, required this.content, this.citations = const []});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isUser = role == ChatRole.user;
    final cs = Theme.of(context).colorScheme;
    final bubbleColor = isUser ? cs.primaryContainer : cs.surfaceVariant;
    final textColor = isUser ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(context.corners.sm),
      topRight: Radius.circular(context.corners.sm),
      bottomLeft: Radius.circular(isUser ? context.corners.sm : 4),
      bottomRight: Radius.circular(isUser ? 4 : context.corners.sm),
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
              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(spacing.x3),
                    constraints: const BoxConstraints(maxWidth: 560),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: radius,
                    ),
                    child: Text(content, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor)),
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
                        label: Text('${citations[i].docId} • ${citations[i].sectionKey}'),
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

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
    final bubbleColor = isUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Semantics(
      label: 'Chat.${isUser ? 'user' : 'bot'}',
      child: Column(
        key: Key('Chat.${isUser ? 'user' : 'bot'}'),
        crossAxisAlignment: align,
        children: [
          Container(
            padding: EdgeInsets.all(spacing.x3),
            margin: EdgeInsets.only(bottom: spacing.x2),
            constraints: const BoxConstraints(maxWidth: 560),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(context.corners.sm),
            ),
            child: Text(content),
          ),
          if (citations.isNotEmpty && !isUser)
            Wrap(
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
        ],
      ),
    );
  }
}


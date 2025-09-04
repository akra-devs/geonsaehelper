import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../theme/app_theme.dart';

class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  const ChatComposer({super.key, required this.controller, required this.onSend, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(22);
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
      padding: EdgeInsets.fromLTRB(spacing.x4, spacing.x2, spacing.x4, spacing.x2),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.7),
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: 0,
              color: cs.surface.withOpacity(0.7),
              borderRadius: radius,
              child: TextField(
                controller: controller,
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: enabled ? '질문을 입력하세요…' : '선택지에서 답변해 주세요',
                  isDense: true,
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  contentPadding: EdgeInsets.symmetric(horizontal: spacing.x3, vertical: spacing.x2),
                  border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          SizedBox(width: spacing.x2),
          AnimatedScale(
            scale: enabled ? 1.0 : 0.96,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Material(
              color: enabled ? cs.primaryContainer : cs.surfaceContainerHighest,
              elevation: enabled ? 2 : 0,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: enabled ? onSend : null,
                icon: Icon(Icons.send, color: enabled ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                tooltip: '보내기',
              ),
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }
}


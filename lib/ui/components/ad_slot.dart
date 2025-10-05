import 'package:flutter/material.dart';

enum AdPlacement { resultBottom, chatBottom }

class AdSlot extends StatelessWidget {
  final AdPlacement placement;
  final bool visible;
  const AdSlot({super.key, required this.placement, this.visible = true});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('광고', style: TextStyle(fontSize: 10)),
            ),
            const SizedBox(width: 8),
            Text(
              placement == AdPlacement.resultBottom ? '결과 관련 스폰서' : '추천 스폰서',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

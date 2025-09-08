import 'package:flutter/material.dart';

class ProgressInline extends StatelessWidget {
  final int current;
  final int total;
  final bool showBar;
  const ProgressInline({
    super.key,
    required this.current,
    required this.total,
    this.showBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = '진행 $current/$total';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          key: const Key('ProgressInline.Text'),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        if (showBar) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            key: const Key('ProgressInline.Bar'),
            value: total > 0 ? current / total : null,
            minHeight: 4,
          ),
        ],
      ],
    );
  }
}

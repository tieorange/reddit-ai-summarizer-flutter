import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PromptPreviewCard extends StatelessWidget {
  const PromptPreviewCard({super.key, required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prompt', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy prompt',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: prompt));
                    HapticFeedback.lightImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prompt copied!')),
                      );
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            SelectableText(
              prompt,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              maxLines: 20,
            ),
          ],
        ),
      ),
    );
  }
}

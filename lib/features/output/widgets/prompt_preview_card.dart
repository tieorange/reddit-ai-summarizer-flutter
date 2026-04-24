import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../core/theme/markdown_theme.dart';

class PromptPreviewCard extends StatelessWidget {
  const PromptPreviewCard({super.key, required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prompt', style: Theme.of(context).textTheme.titleMedium),
                IconButton.filledTonal(
                  icon: const Icon(Icons.copy_rounded, size: 20),
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
            const SizedBox(height: 12),
            MarkdownBody(
              data: prompt,
              selectable: true,
              styleSheet: MarkdownTheme.sheet(context),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/markdown_theme.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary, this.isLoading = false, this.error});

  final String? summary;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 14,
                    width: i == 4 ? 120 : double.infinity,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      );
    }
    if (summary == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('AI Summary', style: Theme.of(context).textTheme.titleMedium),
                IconButton.filledTonal(
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  tooltip: 'Copy summary',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: summary!));
                    HapticFeedback.lightImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Summary copied!')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            MarkdownBody(
              data: summary!,
              selectable: true,
              styleSheet: MarkdownTheme.sheet(context),
            ),
          ],
        ),
      ),
    );
  }
}

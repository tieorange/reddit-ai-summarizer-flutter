import 'package:flutter/material.dart';
import '../../../core/models/history_entry.dart';

class HistoryItemTile extends StatelessWidget {
  const HistoryItemTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final HistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.postTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${entry.timestamp.toLocal().toString().substring(0, 16)}  •  ${entry.aiSummary != null ? "AI + Prompt" : "Prompt only"}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}

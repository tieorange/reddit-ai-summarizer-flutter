import 'package:flutter/material.dart';
import '../cubit/output_state.dart';

class ModeToggle extends StatelessWidget {
  const ModeToggle({super.key, required this.mode, required this.onToggle});

  final OutputMode mode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<OutputMode>(
      segments: const [
        ButtonSegment(value: OutputMode.local, label: Text('Prompt'), icon: Icon(Icons.copy)),
        ButtonSegment(
            value: OutputMode.ai, label: Text('AI Summary'), icon: Icon(Icons.auto_awesome)),
      ],
      selected: {mode},
      onSelectionChanged: (_) => onToggle(),
    );
  }
}

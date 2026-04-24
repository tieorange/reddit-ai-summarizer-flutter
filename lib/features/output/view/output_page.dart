import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/post_data.dart';
import '../../../core/networking/ai_client.dart';
import '../../../core/storage/history_storage.dart';
import '../../../core/storage/settings_storage.dart';
import '../cubit/output_cubit.dart';
import '../cubit/output_state.dart';
import '../widgets/mode_toggle.dart';
import '../widgets/prompt_preview_card.dart';
import '../widgets/summary_card.dart';

class OutputPage extends StatelessWidget {
  const OutputPage({
    super.key,
    required this.postData,
    required this.prompt,
    required this.url,
  });

  final PostData postData;
  final String prompt;
  final String url;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OutputCubit(
        postData: postData,
        prompt: prompt,
        url: url,
        aiClient: AiClient(),
        settingsStorage: SettingsStorage(),
        historyStorage: HistoryStorage(),
      ),
      child: const _OutputView(),
    );
  }
}

class _OutputView extends StatelessWidget {
  const _OutputView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<OutputCubit, OutputState>(
      listener: (context, state) {
        if (state.historySaveError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.historySaveError!)),
          );
        }
      },
      child: BlocBuilder<OutputCubit, OutputState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Hero(
                tag: 'post_title_${state.postData.postId}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(state.postData.title, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey('${state.mode}_${state.status}'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ModeToggle(
                      mode: state.mode,
                      onToggle: () => context.read<OutputCubit>().toggleMode(),
                    ),
                    const SizedBox(height: 16),
                    if (state.mode == OutputMode.local)
                      PromptPreviewCard(prompt: state.prompt)
                    else
                      SummaryCard(
                        summary: state.aiSummary,
                        isLoading: state.status == OutputStatus.loading,
                        error: state.status == OutputStatus.error ? state.errorMessage : null,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

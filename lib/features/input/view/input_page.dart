import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/networking/reddit_client.dart';
import '../cubit/input_cubit.dart';
import '../cubit/input_state.dart';
import '../widgets/url_input_field.dart';

class InputPage extends StatelessWidget {
  const InputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InputCubit(redditClient: RedditClient()),
      child: const _InputView(),
    );
  }
}

class _InputView extends StatefulWidget {
  const _InputView();

  @override
  State<_InputView> createState() => _InputViewState();
}

class _InputViewState extends State<_InputView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InputCubit, InputState>(
      listener: (context, state) {
        if (state.status == InputStatus.done && state.postData != null) {
          context.push('/output', extra: {
            'postData': state.postData!,
            'prompt': state.prompt!,
            'url': state.url,
          });
          context.read<InputCubit>().reset();
          _controller.clear();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Reddit Summarizer')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<InputCubit, InputState>(
            builder: (context, state) {
              if (state.status == InputStatus.loading) {
                return const _LoadingSkeleton();
              }
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 64,
                        color: Color(0xFFFF4500),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reddit AI Summarizer',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Turn long threads into concise, actionable summaries in seconds.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      UrlInputField(
                        controller: _controller,
                        onSubmitted: () => context.read<InputCubit>().submit(),
                        errorText: state.status == InputStatus.error ? state.errorMessage : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () {
                            context.read<InputCubit>().updateUrl(_controller.text);
                            context.read<InputCubit>().submit();
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.summarize_rounded),
                          label: const Text('Fetch & Summarize', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(
              height: 56,
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 16),
          Container(
              height: 48,
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 24),
          Container(
              height: 120,
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
        ],
      ),
    );
  }
}

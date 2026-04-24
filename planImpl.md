# Reddit Summarizer — Full Flutter Implementation Plan

## What You're Building
A Flutter mobile app ("Reddit Summarizer") where users paste a Reddit URL, the app fetches the post and comments via Reddit's public JSON endpoint (no auth required), then either:
- **Mode A**: Formats a structured prompt the user can copy into any local AI app
- **Mode B**: Calls the Sambanova AI API directly and shows the summary in-app

Additional features: persisted history, editable API settings.

---

## Step 0 — Bootstrap

The repo contains only `plan.md`. Run this first to create the Flutter boilerplate:

```bash
flutter create --org com.tieorange --project-name reddit_summarizer --platforms ios,android .
```

Then replace `pubspec.yaml` and `lib/main.dart` entirely (content below).

---

## pubspec.yaml

Replace the entire file with:

```yaml
name: reddit_summarizer
description: Reddit AI Summarizer
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.1.1
  fpdart: ^1.2.0
  go_router: ^17.0.1
  dio: ^5.9.2
  flutter_secure_storage: ^10.0.0
  shared_preferences: ^2.5.5
  equatable: ^2.0.8
  shimmer: ^3.0.0
  url_launcher: ^6.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

Run `flutter pub get` after writing this file.

---

## Final Folder Structure

```
lib/
  core/
    errors/
      failures.dart
    models/
      comment.dart
      post_data.dart
      history_entry.dart
      app_settings.dart
    networking/
      reddit_client.dart
      ai_client.dart
    storage/
      settings_storage.dart
      history_storage.dart
    theme/
      app_theme.dart
    utils/
      reddit_url_parser.dart
      prompt_formatter.dart
  features/
    input/
      cubit/
        input_cubit.dart
        input_state.dart
      view/
        input_page.dart
      widgets/
        url_input_field.dart
    output/
      cubit/
        output_cubit.dart
        output_state.dart
      view/
        output_page.dart
      widgets/
        mode_toggle.dart
        prompt_preview_card.dart
        summary_card.dart
    history/
      cubit/
        history_cubit.dart
        history_state.dart
      view/
        history_page.dart
        history_detail_page.dart
      widgets/
        history_item_tile.dart
    settings/
      cubit/
        settings_cubit.dart
        settings_state.dart
      view/
        settings_page.dart
      widgets/
        settings_field.dart
  router/
    app_router.dart
  main.dart
```

---

## File Implementations

Create files in this exact order (dependencies first).

---

### lib/core/errors/failures.dart

```dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error. Check your connection.']) : super(message);
}

final class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error. Please try again.']) : super(message);
}

final class InvalidInputFailure extends Failure {
  const InvalidInputFailure([String message = 'Invalid Reddit URL.']) : super(message);
}

final class StorageFailure extends Failure {
  const StorageFailure([String message = 'Storage error.']) : super(message);
}

final class ParseFailure extends Failure {
  const ParseFailure([String message = 'Failed to parse Reddit response.']) : super(message);
}
```

---

### lib/core/models/comment.dart

```dart
import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.author,
    required this.body,
    required this.score,
    required this.isStickied,
    required this.depth,
    required this.replies,
  });

  final String id;
  final String author;
  final String body;
  final int score;
  final bool isStickied;
  final int depth;
  final List<Comment> replies;

  @override
  List<Object?> get props => [id, author, body, score, isStickied, depth, replies];
}
```

---

### lib/core/models/post_data.dart

```dart
import 'package:equatable/equatable.dart';
import 'comment.dart';

class PostData extends Equatable {
  const PostData({
    required this.title,
    required this.body,
    required this.subreddit,
    required this.postId,
    required this.comments,
  });

  final String title;
  final String body;
  final String subreddit;
  final String postId;
  final List<Comment> comments;

  @override
  List<Object?> get props => [title, body, subreddit, postId, comments];
}
```

---

### lib/core/models/history_entry.dart

```dart
import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.id,
    required this.url,
    required this.postTitle,
    required this.prompt,
    required this.timestamp,
    this.aiSummary,
  });

  final String id;
  final String url;
  final String postTitle;
  final String prompt;
  final String? aiSummary;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'postTitle': postTitle,
        'prompt': prompt,
        'aiSummary': aiSummary,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String,
        url: json['url'] as String,
        postTitle: json['postTitle'] as String,
        prompt: json['prompt'] as String,
        aiSummary: json['aiSummary'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  HistoryEntry copyWith({String? aiSummary}) => HistoryEntry(
        id: id,
        url: url,
        postTitle: postTitle,
        prompt: prompt,
        aiSummary: aiSummary ?? this.aiSummary,
        timestamp: timestamp,
      );

  @override
  List<Object?> get props => [id, url, postTitle, prompt, aiSummary, timestamp];
}
```

---

### lib/core/models/app_settings.dart

```dart
import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({
    required this.model,
    required this.baseUrl,
    required this.apiKey,
  });

  final String model;
  final String baseUrl;
  final String apiKey;

  static const defaults = AppSettings(
    model: 'Meta-Llama-3.3-70B-Instruct',
    baseUrl: 'https://api.sambanova.ai/v1',
    apiKey: 'your-api-key-here',
  );

  AppSettings copyWith({String? model, String? baseUrl, String? apiKey}) => AppSettings(
        model: model ?? this.model,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
      );

  @override
  List<Object?> get props => [model, baseUrl, apiKey];
}
```

---

### lib/core/utils/reddit_url_parser.dart

```dart
import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';

typedef RedditPostRef = ({String subreddit, String postId});

class RedditUrlParser {
  static final _pattern = RegExp(
    r'reddit\.com/r/([^/?#]+)/comments/([^/?#]+)',
    caseSensitive: false,
  );

  static Either<InvalidInputFailure, RedditPostRef> parse(String url) {
    final match = _pattern.firstMatch(url.trim());
    if (match == null) {
      return const Left(InvalidInputFailure('Not a valid Reddit post URL.'));
    }
    return Right((subreddit: match.group(1)!, postId: match.group(2)!));
  }
}
```

---

### lib/core/utils/prompt_formatter.dart

```dart
import '../models/post_data.dart';
import '../models/comment.dart';

class PromptFormatter {
  static String format(PostData data) {
    final comments = _formatComments(data.comments.take(100).toList(), 0);
    return '''Here is the full text of a Reddit post and its comments. Please provide a "TL;DR" summary of the post and then a breakdown of the overall sentiment and most interesting points raised in the comments. Write it in the style of a clear, neutral moderator summary.

### Post Title
${data.title}

### Post Body
${data.body.isEmpty ? '[No body text]' : data.body}

### Comments
$comments''';
  }

  static String _formatComments(List<Comment> comments, int depth) {
    final buffer = StringBuffer();
    final prefix = '>' * depth;
    for (final c in comments) {
      final indent = prefix.isEmpty ? '' : '$prefix ';
      final modPrefix = c.isStickied ? 'MOD NOTE: ' : '';
      buffer.writeln('${indent}u/${c.author} (score: ${c.score}): $modPrefix${c.body.trim()}');
      if (c.replies.isNotEmpty) {
        buffer.write(_formatComments(c.replies, depth + 1));
      }
    }
    return buffer.toString();
  }
}
```

---

### lib/core/networking/reddit_client.dart

```dart
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';
import '../models/comment.dart';
import '../models/post_data.dart';

class RedditClient {
  RedditClient() : _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'User-Agent': 'RedditSummarizer/1.0'},
      ));

  final Dio _dio;

  Future<Either<Failure, PostData>> fetchPost(String subreddit, String postId) async {
    try {
      final url = 'https://www.reddit.com/r/$subreddit/comments/$postId.json?sort=best&limit=500&raw_json=1';
      final response = await _dio.get<List<dynamic>>(url);
      final data = response.data;
      if (data == null || data.length < 2) return const Left(ParseFailure());

      final postListing = data[0] as Map<String, dynamic>;
      final postChildren = postListing['data']['children'] as List<dynamic>;
      if (postChildren.isEmpty) return const Left(ParseFailure('No post data found.'));
      final postJson = postChildren[0]['data'] as Map<String, dynamic>;

      final commentsListing = data[1] as Map<String, dynamic>;
      final commentChildren = commentsListing['data']['children'] as List<dynamic>;
      final comments = _parseComments(commentChildren, 0);

      return Right(PostData(
        title: postJson['title'] as String? ?? '',
        body: postJson['selftext'] as String? ?? '',
        subreddit: postJson['subreddit'] as String? ?? subreddit,
        postId: postJson['id'] as String? ?? postId,
        comments: comments,
      ));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Left(NetworkFailure());
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 429) {
        return const Left(ServerFailure('Reddit rate limited. Please wait a moment and try again.'));
      }
      return Left(ServerFailure('Reddit returned $statusCode.'));
    } catch (_) {
      return const Left(ParseFailure());
    }
  }

  List<Comment> _parseComments(List<dynamic> children, int depth) {
    final result = <Comment>[];
    for (final child in children) {
      final kind = child['kind'] as String?;
      if (kind != 't1') continue;
      final d = child['data'] as Map<String, dynamic>;
      final repliesRaw = d['replies'];
      List<Comment> replies = [];
      if (repliesRaw is Map) {
        final replyChildren = repliesRaw['data']?['children'] as List<dynamic>?;
        if (replyChildren != null) {
          replies = _parseComments(replyChildren, depth + 1);
        }
      }
      result.add(Comment(
        id: d['id'] as String? ?? '',
        author: d['author'] as String? ?? '[deleted]',
        body: d['body'] as String? ?? '',
        score: (d['score'] as num?)?.toInt() ?? 0,
        isStickied: d['stickied'] as bool? ?? false,
        depth: depth,
        replies: replies,
      ));
    }
    return result;
  }
}
```

---

### lib/core/networking/ai_client.dart

```dart
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';
import '../models/app_settings.dart';

class AiClient {
  AiClient() : _dio = Dio();

  final Dio _dio;

  Future<Either<Failure, String>> summarize(String prompt, AppSettings settings) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${settings.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${settings.apiKey}',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          'model': settings.model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that summarizes Reddit posts and comment threads concisely and insightfully.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        },
      );
      final content = response.data?['choices']?[0]?['message']?['content'] as String?;
      if (content == null) return const Left(ParseFailure('Empty response from AI.'));
      return Right(content);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Left(NetworkFailure());
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) return const Left(ServerFailure('Invalid API key.'));
      return Left(ServerFailure('AI API error: ${statusCode ?? 'unknown'}.'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
```

---

### lib/core/storage/settings_storage.dart

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/failures.dart';
import '../models/app_settings.dart';

class SettingsStorage {
  static const _apiKeyKey = 'api_key';
  static const _modelKey = 'ai_model';
  static const _baseUrlKey = 'base_url';

  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<Either<StorageFailure, AppSettings>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = await _secure.read(key: _apiKeyKey);
      return Right(AppSettings(
        model: prefs.getString(_modelKey) ?? AppSettings.defaults.model,
        baseUrl: prefs.getString(_baseUrlKey) ?? AppSettings.defaults.baseUrl,
        apiKey: apiKey ?? AppSettings.defaults.apiKey,
      ));
    } catch (_) {
      return const Left(StorageFailure('Failed to load settings.'));
    }
  }

  Future<Either<StorageFailure, Unit>> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modelKey, settings.model);
      await prefs.setString(_baseUrlKey, settings.baseUrl);
      await _secure.write(key: _apiKeyKey, value: settings.apiKey);
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure('Failed to save settings.'));
    }
  }
}
```

---

### lib/core/storage/history_storage.dart

```dart
import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/failures.dart';
import '../models/history_entry.dart';

class HistoryStorage {
  static const _key = 'history_entries';

  Future<Either<StorageFailure, List<HistoryEntry>>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      final entries = raw
          .map((s) => HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Right(entries);
    } catch (_) {
      return const Left(StorageFailure('Failed to load history.'));
    }
  }

  Future<Either<StorageFailure, Unit>> saveHistory(List<HistoryEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = entries.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_key, raw);
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure('Failed to save history.'));
    }
  }
}
```

---

### lib/core/theme/app_theme.dart

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4500),
          brightness: Brightness.light,
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4500),
          brightness: Brightness.dark,
        ),
      );
}
```

---

### lib/features/input/cubit/input_state.dart

```dart
import 'package:equatable/equatable.dart';
import '../../../core/models/post_data.dart';

enum InputStatus { initial, loading, done, error }

class InputState extends Equatable {
  const InputState({
    this.url = '',
    this.status = InputStatus.initial,
    this.postData,
    this.prompt,
    this.errorMessage,
  });

  final String url;
  final InputStatus status;
  final PostData? postData;
  final String? prompt;
  final String? errorMessage;

  InputState copyWith({
    String? url,
    InputStatus? status,
    PostData? postData,
    String? prompt,
    String? errorMessage,
  }) =>
      InputState(
        url: url ?? this.url,
        status: status ?? this.status,
        postData: postData ?? this.postData,
        prompt: prompt ?? this.prompt,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [url, status, postData, prompt, errorMessage];
}
```

---

### lib/features/input/cubit/input_cubit.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../core/networking/reddit_client.dart';
import '../../../core/utils/prompt_formatter.dart';
import '../../../core/utils/reddit_url_parser.dart';
import 'input_state.dart';

class InputCubit extends Cubit<InputState> {
  InputCubit({required RedditClient redditClient})
      : _redditClient = redditClient,
        super(const InputState());

  final RedditClient _redditClient;

  void updateUrl(String url) => emit(state.copyWith(url: url, status: InputStatus.initial));

  Future<void> submit() async {
    final parseResult = RedditUrlParser.parse(state.url);
    parseResult.fold(
      (failure) => emit(state.copyWith(
        status: InputStatus.error,
        errorMessage: failure.message,
      )),
      (ref) async {
        emit(state.copyWith(status: InputStatus.loading));
        final result = await _redditClient.fetchPost(ref.subreddit, ref.postId);
        result.fold(
          (failure) => emit(state.copyWith(
            status: InputStatus.error,
            errorMessage: failure.message,
          )),
          (postData) {
            final prompt = PromptFormatter.format(postData);
            emit(state.copyWith(
              status: InputStatus.done,
              postData: postData,
              prompt: prompt,
            ));
          },
        );
      },
    );
  }

  void reset() => emit(const InputState());
}
```

---

### lib/features/input/widgets/url_input_field.dart

```dart
import 'package:flutter/material.dart';

class UrlInputField extends StatelessWidget {
  const UrlInputField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.errorText,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.url,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: 'https://www.reddit.com/r/...',
        labelText: 'Reddit Post URL',
        errorText: errorText,
        prefixIcon: const Icon(Icons.link),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => controller.clear(),
        ),
        border: const OutlineInputBorder(),
      ),
      onSubmitted: (_) => onSubmitted(),
    );
  }
}
```

---

### lib/features/input/view/input_page.dart

```dart
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
                return _LoadingSkeleton();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  UrlInputField(
                    controller: _controller,
                    onSubmitted: () => context.read<InputCubit>().submit(),
                    errorText: state.status == InputStatus.error ? state.errorMessage : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<InputCubit>().updateUrl(_controller.text);
                      context.read<InputCubit>().submit();
                    },
                    icon: const Icon(Icons.summarize),
                    label: const Text('Fetch & Summarize'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 16),
          Container(height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 24),
          Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
        ],
      ),
    );
  }
}
```

---

### lib/features/output/cubit/output_state.dart

```dart
import 'package:equatable/equatable.dart';
import '../../../core/models/post_data.dart';

enum OutputMode { local, ai }
enum OutputStatus { initial, loading, loaded, error }

class OutputState extends Equatable {
  const OutputState({
    required this.postData,
    required this.prompt,
    required this.url,
    this.mode = OutputMode.local,
    this.aiSummary,
    this.status = OutputStatus.loaded,
    this.errorMessage,
  });

  final PostData postData;
  final String prompt;
  final String url;
  final OutputMode mode;
  final String? aiSummary;
  final OutputStatus status;
  final String? errorMessage;
  final String? historySaveError;

  OutputState copyWith({
    OutputMode? mode,
    String? aiSummary,
    OutputStatus? status,
    String? errorMessage,
    String? historySaveError,
  }) =>
      OutputState(
        postData: postData,
        prompt: prompt,
        url: url,
        mode: mode ?? this.mode,
        aiSummary: aiSummary ?? this.aiSummary,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        historySaveError: historySaveError ?? this.historySaveError,
      );

  @override
  List<Object?> get props => [postData, prompt, url, mode, aiSummary, status, errorMessage, historySaveError];
}
```

---

### lib/features/output/cubit/output_cubit.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/post_data.dart';
import '../../../core/networking/ai_client.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/storage/settings_storage.dart';
import '../../../core/storage/history_storage.dart';
import '../../../core/models/history_entry.dart';
import 'output_state.dart';

class OutputCubit extends Cubit<OutputState> {
  OutputCubit({
    required PostData postData,
    required String prompt,
    required String url,
    required AiClient aiClient,
    required SettingsStorage settingsStorage,
    required HistoryStorage historyStorage,
  })  : _aiClient = aiClient,
        _settingsStorage = settingsStorage,
        _historyStorage = historyStorage,
        super(OutputState(postData: postData, prompt: prompt, url: url)) {
    _saveToHistory(postData, prompt, url);
  }

  final AiClient _aiClient;
  final SettingsStorage _settingsStorage;
  final HistoryStorage _historyStorage;

  void toggleMode() {
    final next = state.mode == OutputMode.local ? OutputMode.ai : OutputMode.local;
    emit(state.copyWith(mode: next));
    if (next == OutputMode.ai && state.aiSummary == null) {
      fetchAiSummary();
    }
  }

  Future<void> fetchAiSummary() async {
    emit(state.copyWith(status: OutputStatus.loading));
    final settingsResult = await _settingsStorage.loadSettings();
    final settings = settingsResult.getOrElse((_) => AppSettings.defaults);
    final result = await _aiClient.summarize(state.prompt, settings);
    result.fold(
      (failure) => emit(state.copyWith(status: OutputStatus.error, errorMessage: failure.message)),
      (summary) {
        emit(state.copyWith(status: OutputStatus.loaded, aiSummary: summary));
        _updateHistoryWithSummary(summary);
      },
    );
  }

  Future<void> _saveToHistory(PostData postData, String prompt, String url) async {
    final loadResult = await _historyStorage.loadHistory();
    loadResult.fold(
      (failure) => emit(state.copyWith(historySaveError: 'Failed to save to history: ${failure.message}')),
      (entries) async {
        final entry = HistoryEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: url,
          postTitle: postData.title,
          prompt: prompt,
          timestamp: DateTime.now(),
        );
        final saveResult = await _historyStorage.saveHistory([entry, ...entries]);
        saveResult.fold(
          (failure) => emit(state.copyWith(historySaveError: 'Failed to save to history: ${failure.message}')),
          (_) {},
        );
      },
    );
  }

  Future<void> _updateHistoryWithSummary(String summary) async {
    final loadResult = await _historyStorage.loadHistory();
    loadResult.fold(
      (failure) => emit(state.copyWith(historySaveError: 'Failed to update history: ${failure.message}')),
      (entries) async {
        final updated = entries.map((e) {
          if (e.url == state.url && e.aiSummary == null) {
            return e.copyWith(aiSummary: summary);
          }
          return e;
        }).toList();
        final saveResult = await _historyStorage.saveHistory(updated);
        saveResult.fold(
          (failure) => emit(state.copyWith(historySaveError: 'Failed to update history: ${failure.message}')),
          (_) {},
        );
      },
    );
  }
}
```

---

### lib/features/output/widgets/mode_toggle.dart

```dart
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
        ButtonSegment(value: OutputMode.ai, label: Text('AI Summary'), icon: Icon(Icons.auto_awesome)),
      ],
      selected: {mode},
      onSelectionChanged: (_) => onToggle(),
    );
  }
}
```

---

### lib/features/output/widgets/prompt_preview_card.dart

```dart
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
```

---

### lib/features/output/widgets/summary_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

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
                IconButton(
                  icon: const Icon(Icons.copy),
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
            const Divider(),
            SelectableText(summary!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
```

---

### lib/features/output/view/output_page.dart

```dart
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
```

---

### lib/features/history/cubit/history_state.dart

```dart
import 'package:equatable/equatable.dart';
import '../../../core/models/history_entry.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  const HistoryState({
    this.entries = const [],
    this.status = HistoryStatus.initial,
    this.errorMessage,
  });

  final List<HistoryEntry> entries;
  final HistoryStatus status;
  final String? errorMessage;

  HistoryState copyWith({
    List<HistoryEntry>? entries,
    HistoryStatus? status,
    String? errorMessage,
  }) =>
      HistoryState(
        entries: entries ?? this.entries,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [entries, status, errorMessage];
}
```

---

### lib/features/history/cubit/history_cubit.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/history_storage.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required HistoryStorage historyStorage})
      : _storage = historyStorage,
        super(const HistoryState());

  final HistoryStorage _storage;

  Future<void> load() async {
    emit(state.copyWith(status: HistoryStatus.loading));
    final result = await _storage.loadHistory();
    result.fold(
      (failure) => emit(state.copyWith(status: HistoryStatus.error, errorMessage: failure.message)),
      (entries) => emit(state.copyWith(status: HistoryStatus.loaded, entries: entries)),
    );
  }

  Future<void> delete(String id) async {
    final updated = state.entries.where((e) => e.id != id).toList();
    final result = await _storage.saveHistory(updated);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(entries: updated)),
    );
  }

  Future<void> clear() async {
    final result = await _storage.saveHistory([]);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(entries: [])),
    );
  }
}
```

---

### lib/features/history/widgets/history_item_tile.dart

```dart
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
```

---

### lib/features/history/view/history_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/history_entry.dart';
import '../../../core/storage/history_storage.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../widgets/history_item_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(historyStorage: HistoryStorage())..load(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all',
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state.status == HistoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.entries.isEmpty) {
            return const Center(child: Text('No history yet.'));
          }
          return ListView.separated(
            itemCount: state.entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final entry = state.entries[i];
              return HistoryItemTile(
                entry: entry,
                onTap: () => context.push('/history/detail', extra: entry),
                onDelete: () => context.read<HistoryCubit>().delete(entry.id),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all history entries?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<HistoryCubit>().clear();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
```

---

### History Detail Page (inline in history feature)

Create **lib/features/history/view/history_detail_page.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/history_entry.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key, required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.postTitle, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Section(title: 'Prompt', content: entry.prompt),
            if (entry.aiSummary != null) ...[
              const SizedBox(height: 16),
              _Section(title: 'AI Summary', content: entry.aiSummary!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.content});
  final String title;
  final String content;

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
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: content));
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),
            const Divider(),
            SelectableText(content),
          ],
        ),
      ),
    );
  }
}
```

---

### lib/features/settings/cubit/settings_state.dart

```dart
import 'package:equatable/equatable.dart';
import '../../../core/models/app_settings.dart';

enum SettingsStatus { initial, loading, loaded, saving, saved, error }

class SettingsState extends Equatable {
  const SettingsState({
    this.settings = AppSettings.defaults,
    this.status = SettingsStatus.initial,
    this.errorMessage,
  });

  final AppSettings settings;
  final SettingsStatus status;
  final String? errorMessage;

  SettingsState copyWith({
    AppSettings? settings,
    SettingsStatus? status,
    String? errorMessage,
  }) =>
      SettingsState(
        settings: settings ?? this.settings,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [settings, status, errorMessage];
}
```

---

### lib/features/settings/cubit/settings_cubit.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/storage/settings_storage.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required SettingsStorage settingsStorage})
      : _storage = settingsStorage,
        super(const SettingsState());

  final SettingsStorage _storage;

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final result = await _storage.loadSettings();
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.error, errorMessage: failure.message)),
      (settings) => emit(state.copyWith(status: SettingsStatus.loaded, settings: settings)),
    );
  }

  Future<void> save(AppSettings settings) async {
    emit(state.copyWith(status: SettingsStatus.saving));
    final result = await _storage.saveSettings(settings);
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: SettingsStatus.saved, settings: settings)),
    );
  }
}
```

---

### lib/features/settings/widgets/settings_field.dart

```dart
import 'package:flutter/material.dart';

class SettingsField extends StatelessWidget {
  const SettingsField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
```

---

### lib/features/settings/view/settings_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/storage/settings_storage.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/settings_field.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(settingsStorage: SettingsStorage())..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  late TextEditingController _modelController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController();
    _baseUrlController = TextEditingController();
    _apiKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _populate(AppSettings s) {
    if (!mounted) return;
    _modelController.text = s.model;
    _baseUrlController.text = s.baseUrl;
    _apiKeyController.text = s.apiKey;
  }

  bool _validate() {
    final model = _modelController.text.trim();
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (model.isEmpty || baseUrl.isEmpty || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return false;
    }
    if (!Uri.tryParse(baseUrl)!.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base URL must be a valid URL (e.g. https://api.example.com/v1).')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.status == SettingsStatus.loaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _populate(state.settings));
        }
        if (state.status == SettingsStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved!')),
          );
        }
        if (state.status == SettingsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SettingsField(label: 'Model', controller: _modelController),
                const SizedBox(height: 12),
                SettingsField(label: 'Base URL', controller: _baseUrlController),
                const SizedBox(height: 12),
                SettingsField(label: 'API Key', controller: _apiKeyController, obscureText: true),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: state.status == SettingsStatus.saving
                      ? null
                      : () {
                          if (!_validate()) return;
                          context.read<SettingsCubit>().save(AppSettings(
                                model: _modelController.text.trim(),
                                baseUrl: _baseUrlController.text.trim(),
                                apiKey: _apiKeyController.text.trim(),
                              ));
                        },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

### lib/router/app_router.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/history/view/history_detail_page.dart';
import '../features/history/view/history_page.dart';
import '../features/input/view/input_page.dart';
import '../features/output/view/output_page.dart';
import '../features/settings/view/settings_page.dart';
import '../core/models/history_entry.dart';
import '../core/models/post_data.dart';

final appRouter = GoRouter(
  initialLocation: '/input',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithNav(child: child),
      routes: [
        GoRoute(path: '/input', builder: (_, __) => const InputPage()),
        GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
    GoRoute(
      path: '/output',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return OutputPage(
          postData: extra['postData'] as PostData,
          prompt: extra['prompt'] as String,
          url: extra['url'] as String,
        );
      },
    ),
    GoRoute(
      path: '/history/detail',
      builder: (context, state) {
        final entry = state.extra as HistoryEntry;
        return HistoryDetailPage(entry: entry);
      },
    ),
  ],
);

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = location.startsWith('/history')
        ? 1
        : location.startsWith('/settings')
            ? 2
            : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/input');
            case 1: context.go('/history');
            case 2: context.go('/settings');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.link), label: 'Input'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

---

### lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RedditSummarizerApp());
}

class RedditSummarizerApp extends StatelessWidget {
  const RedditSummarizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reddit Summarizer',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
```

---

## iOS Platform Setup

In `ios/Runner/Info.plist`, add (for network access):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

For `flutter_secure_storage` on iOS, no extra config needed — it uses Keychain by default.

---

## Known Gotchas

1. **Reddit JSON replies field**: `data.replies` can be `""` (empty string) instead of an object when there are no replies. Always guard with `if (repliesRaw is Map)` before accessing `.data.children`.

2. **go_router 17 ShellRoute**: The `ShellRoute` builder signature is `(BuildContext, GoRouterState, Widget child)`. The `child` is the active sub-route widget. Do NOT wrap it in another Scaffold.

3. **flutter_secure_storage 10**: Use `AndroidOptions(encryptedSharedPreferences: true)` in the constructor. The old `keychainAccessibility` approach still works on iOS.

4. **fpdart `unit`**: Import from `package:fpdart/fpdart.dart`. Use `Right(unit)` for successful void operations.

5. **go_router `state.extra` typing**: Always cast explicitly. `state.extra as Map<String, dynamic>` will throw at runtime if the route is accessed directly (e.g., deep link with no extra). Add a null guard or redirect if needed for production.

6. **Reddit URL variation**: Some URLs have a trailing slug after the post ID (e.g., `/comments/abc123/my_post_title/`). The regex `reddit\.com/r/([^/?#]+)/comments/([^/?#]+)` correctly captures only the post ID.

7. **`shared_preferences` on iOS**: Requires iOS 13.0+. Set `IPHONEOS_DEPLOYMENT_TARGET = 13.0` in Xcode if not already set.

---

## Verification Steps

```bash
# 1. Resolve dependencies
flutter pub get

# 2. Static analysis — should report zero issues
flutter analyze

# 3. Compile for iOS (no device needed)
flutter build ios --no-codesign

# 4. Run on iOS simulator
open -a Simulator
flutter run

# Manual test checklist:
# [ ] Paste invalid URL → red error text shown
# [ ] Paste https://www.reddit.com/r/ClaudeAI/comments/1abc123/ → fetches, navigates to Output
# [ ] Output page shows prompt in Mode A; Copy → snackbar + haptic
# [ ] Toggle to Mode B → shimmer → AI summary shown; Copy works
# [ ] Navigate to History → entry visible with title + timestamp
# [ ] Tap history entry → detail page shows prompt + summary
# [ ] Swipe/delete entry → removed from list
# [ ] Clear all → empty state shown
# [ ] Settings: change API key → save → used on next Mode B call
# [ ] Dark mode: switch system theme → app updates
```

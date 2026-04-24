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
    this.historySaveError,
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
  List<Object?> get props =>
      [postData, prompt, url, mode, aiSummary, status, errorMessage, historySaveError];
}

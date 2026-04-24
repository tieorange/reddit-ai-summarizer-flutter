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

import 'package:flutter_bloc/flutter_bloc.dart';
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

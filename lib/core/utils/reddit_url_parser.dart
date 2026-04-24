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

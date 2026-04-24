import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';
import '../models/comment.dart';
import '../models/post_data.dart';

class RedditClient {
  RedditClient()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: kIsWeb ? {} : {'User-Agent': 'RedditSummarizer/1.0'},
        ));

  final Dio _dio;

  Future<Either<Failure, PostData>> fetchPost(String subreddit, String postId) async {
    try {
      var url =
          'https://www.reddit.com/r/$subreddit/comments/$postId.json?sort=best&limit=500&raw_json=1';

      if (kIsWeb) {
        url = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      }

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
        return const Left(
            ServerFailure('Reddit rate limited. Please wait a moment and try again.'));
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

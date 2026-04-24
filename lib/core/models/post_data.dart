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

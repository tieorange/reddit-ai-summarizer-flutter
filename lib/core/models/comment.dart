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

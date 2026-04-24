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

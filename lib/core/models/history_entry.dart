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

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
    apiKey: String.fromEnvironment('AI_API_KEY', defaultValue: 'your-api-key-here'),
  );

  AppSettings copyWith({String? model, String? baseUrl, String? apiKey}) => AppSettings(
        model: model ?? this.model,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
      );

  @override
  List<Object?> get props => [model, baseUrl, apiKey];
}

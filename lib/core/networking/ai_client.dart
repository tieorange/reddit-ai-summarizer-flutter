import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';
import '../models/app_settings.dart';

class AiClient {
  AiClient() : _dio = Dio();

  final Dio _dio;

  Future<Either<Failure, String>> summarize(String prompt, AppSettings settings) async {
    try {
      var url = '${settings.baseUrl}/chat/completions';
      if (kIsWeb) {
        url = 'https://reddit-proxy.tieorange.workers.dev/ai';
      }
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${settings.apiKey}',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          'model': settings.model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that summarizes Reddit posts and comment threads concisely and insightfully.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        },
      );
      final content = response.data?['choices']?[0]?['message']?['content'] as String?;
      if (content == null) return const Left(ParseFailure('Empty response from AI.'));
      return Right(content);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Left(NetworkFailure());
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) return const Left(ServerFailure('Invalid API key.'));
      return Left(ServerFailure('AI API error: ${statusCode ?? 'unknown'}.'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/failures.dart';
import '../models/app_settings.dart';

class SettingsStorage {
  static const _apiKeyKey = 'api_key';
  static const _modelKey = 'ai_model';
  static const _baseUrlKey = 'base_url';

  final _secure = const FlutterSecureStorage();

  Future<Either<StorageFailure, AppSettings>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = await _secure.read(key: _apiKeyKey);
      return Right(AppSettings(
        model: prefs.getString(_modelKey) ?? AppSettings.defaults.model,
        baseUrl: prefs.getString(_baseUrlKey) ?? AppSettings.defaults.baseUrl,
        apiKey: apiKey ?? AppSettings.defaults.apiKey,
      ));
    } catch (_) {
      return const Left(StorageFailure('Failed to load settings.'));
    }
  }

  Future<Either<StorageFailure, Unit>> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modelKey, settings.model);
      await prefs.setString(_baseUrlKey, settings.baseUrl);
      await _secure.write(key: _apiKeyKey, value: settings.apiKey);
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure('Failed to save settings.'));
    }
  }
}

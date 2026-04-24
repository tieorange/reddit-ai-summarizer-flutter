import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/failures.dart';
import '../models/history_entry.dart';

class HistoryStorage {
  static const _key = 'history_entries';

  Future<Either<StorageFailure, List<HistoryEntry>>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      final entries = raw
          .map((s) => HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Right(entries);
    } catch (_) {
      return const Left(StorageFailure('Failed to load history.'));
    }
  }

  Future<Either<StorageFailure, Unit>> saveHistory(List<HistoryEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = entries.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_key, raw);
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure('Failed to save history.'));
    }
  }
}

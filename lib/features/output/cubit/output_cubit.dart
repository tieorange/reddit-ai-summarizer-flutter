import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/post_data.dart';
import '../../../core/networking/ai_client.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/storage/settings_storage.dart';
import '../../../core/storage/history_storage.dart';
import '../../../core/models/history_entry.dart';
import 'output_state.dart';

class OutputCubit extends Cubit<OutputState> {
  OutputCubit({
    required PostData postData,
    required String prompt,
    required String url,
    required AiClient aiClient,
    required SettingsStorage settingsStorage,
    required HistoryStorage historyStorage,
  })  : _aiClient = aiClient,
        _settingsStorage = settingsStorage,
        _historyStorage = historyStorage,
        super(OutputState(postData: postData, prompt: prompt, url: url)) {
    _saveToHistory(postData, prompt, url);
  }

  final AiClient _aiClient;
  final SettingsStorage _settingsStorage;
  final HistoryStorage _historyStorage;

  void toggleMode() {
    final next = state.mode == OutputMode.local ? OutputMode.ai : OutputMode.local;
    emit(state.copyWith(mode: next));
    if (next == OutputMode.ai && state.aiSummary == null) {
      fetchAiSummary();
    }
  }

  Future<void> fetchAiSummary() async {
    emit(state.copyWith(status: OutputStatus.loading));
    final settingsResult = await _settingsStorage.loadSettings();
    final settings = settingsResult.getOrElse((_) => AppSettings.defaults);
    final result = await _aiClient.summarize(state.prompt, settings);
    result.fold(
      (failure) => emit(state.copyWith(status: OutputStatus.error, errorMessage: failure.message)),
      (summary) {
        emit(state.copyWith(status: OutputStatus.loaded, aiSummary: summary));
        _updateHistoryWithSummary(summary);
      },
    );
  }

  Future<void> _saveToHistory(PostData postData, String prompt, String url) async {
    final loadResult = await _historyStorage.loadHistory();
    loadResult.fold(
      (failure) =>
          emit(state.copyWith(historySaveError: 'Failed to save to history: ${failure.message}')),
      (entries) async {
        final entry = HistoryEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: url,
          postTitle: postData.title,
          prompt: prompt,
          timestamp: DateTime.now(),
        );
        final saveResult = await _historyStorage.saveHistory([entry, ...entries]);
        saveResult.fold(
          (failure) => emit(
              state.copyWith(historySaveError: 'Failed to save to history: ${failure.message}')),
          (_) {},
        );
      },
    );
  }

  Future<void> _updateHistoryWithSummary(String summary) async {
    final loadResult = await _historyStorage.loadHistory();
    loadResult.fold(
      (failure) => emit(
          state.copyWith(historySaveError: 'Failed to update history: ${failure.message}')),
      (entries) async {
        final updated = entries.map((e) {
          if (e.url == state.url && e.aiSummary == null) {
            return e.copyWith(aiSummary: summary);
          }
          return e;
        }).toList();
        final saveResult = await _historyStorage.saveHistory(updated);
        saveResult.fold(
          (failure) => emit(
              state.copyWith(historySaveError: 'Failed to update history: ${failure.message}')),
          (_) {},
        );
      },
    );
  }
}

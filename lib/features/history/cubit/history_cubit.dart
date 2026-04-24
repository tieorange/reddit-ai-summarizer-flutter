import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/history_storage.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required HistoryStorage historyStorage})
      : _storage = historyStorage,
        super(const HistoryState());

  final HistoryStorage _storage;

  Future<void> load() async {
    emit(state.copyWith(status: HistoryStatus.loading));
    final result = await _storage.loadHistory();
    result.fold(
      (failure) => emit(state.copyWith(status: HistoryStatus.error, errorMessage: failure.message)),
      (entries) => emit(state.copyWith(status: HistoryStatus.loaded, entries: entries)),
    );
  }

  Future<void> delete(String id) async {
    final updated = state.entries.where((e) => e.id != id).toList();
    final result = await _storage.saveHistory(updated);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(entries: updated)),
    );
  }

  Future<void> clear() async {
    final result = await _storage.saveHistory([]);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(entries: [])),
    );
  }
}

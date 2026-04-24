import 'package:equatable/equatable.dart';
import '../../../core/models/history_entry.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  const HistoryState({
    this.entries = const [],
    this.status = HistoryStatus.initial,
    this.errorMessage,
  });

  final List<HistoryEntry> entries;
  final HistoryStatus status;
  final String? errorMessage;

  HistoryState copyWith({
    List<HistoryEntry>? entries,
    HistoryStatus? status,
    String? errorMessage,
  }) =>
      HistoryState(
        entries: entries ?? this.entries,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [entries, status, errorMessage];
}

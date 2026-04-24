import 'package:equatable/equatable.dart';
import '../../../core/models/app_settings.dart';

enum SettingsStatus { initial, loading, loaded, saving, saved, error }

class SettingsState extends Equatable {
  const SettingsState({
    this.settings = AppSettings.defaults,
    this.status = SettingsStatus.initial,
    this.errorMessage,
  });

  final AppSettings settings;
  final SettingsStatus status;
  final String? errorMessage;

  SettingsState copyWith({
    AppSettings? settings,
    SettingsStatus? status,
    String? errorMessage,
  }) =>
      SettingsState(
        settings: settings ?? this.settings,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [settings, status, errorMessage];
}

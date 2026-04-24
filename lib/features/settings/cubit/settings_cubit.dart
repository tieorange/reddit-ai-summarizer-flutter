import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/storage/settings_storage.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required SettingsStorage settingsStorage})
      : _storage = settingsStorage,
        super(const SettingsState());

  final SettingsStorage _storage;

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final result = await _storage.loadSettings();
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.error, errorMessage: failure.message)),
      (settings) => emit(state.copyWith(status: SettingsStatus.loaded, settings: settings)),
    );
  }

  Future<void> save(AppSettings settings) async {
    emit(state.copyWith(status: SettingsStatus.saving));
    final result = await _storage.saveSettings(settings);
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: SettingsStatus.saved, settings: settings)),
    );
  }
}

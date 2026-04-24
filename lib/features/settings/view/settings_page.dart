import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/storage/settings_storage.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/settings_field.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(settingsStorage: SettingsStorage())..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  late TextEditingController _modelController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController();
    _baseUrlController = TextEditingController();
    _apiKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _populate(AppSettings s) {
    if (!mounted) return;
    _modelController.text = s.model;
    _baseUrlController.text = s.baseUrl;
    _apiKeyController.text = s.apiKey;
  }

  bool _validate() {
    final model = _modelController.text.trim();
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (model.isEmpty || baseUrl.isEmpty || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return false;
    }
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Base URL must be a valid URL (e.g. https://api.example.com/v1).')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.status == SettingsStatus.loaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _populate(state.settings));
        }
        if (state.status == SettingsStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved!')),
          );
        }
        if (state.status == SettingsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SettingsField(label: 'Model', controller: _modelController),
                const SizedBox(height: 12),
                SettingsField(label: 'Base URL', controller: _baseUrlController),
                const SizedBox(height: 12),
                SettingsField(
                    label: 'API Key', controller: _apiKeyController, obscureText: true),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: state.status == SettingsStatus.saving
                      ? null
                      : () {
                          if (!_validate()) return;
                          context.read<SettingsCubit>().save(AppSettings(
                                model: _modelController.text.trim(),
                                baseUrl: _baseUrlController.text.trim(),
                                apiKey: _apiKeyController.text.trim(),
                              ));
                        },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

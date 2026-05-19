import '../repository/settings_repository.dart';

class SaveThemeSettingUseCase {
  final SettingsRepository repository;

  SaveThemeSettingUseCase(this.repository);

  Future<void> call(bool enabled) async {
    await repository.setDarkThemeEnabled(enabled);
  }
}

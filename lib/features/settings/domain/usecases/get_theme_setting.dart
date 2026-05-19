import '../repository/settings_repository.dart';

class GetThemeSettingUseCase {
  final SettingsRepository repository;

  GetThemeSettingUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isDarkThemeEnabled();
  }
}

import '../repository/settings_repository.dart';

class SaveAutoRecordSettingUseCase {
  final SettingsRepository repository;

  SaveAutoRecordSettingUseCase(this.repository);

  Future<void> call(bool enabled) async {
    await repository.setAutoRecordEnabled(enabled);
  }
}

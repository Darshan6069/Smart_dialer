import '../repository/settings_repository.dart';

class GetAutoRecordSettingUseCase {
  final SettingsRepository repository;

  GetAutoRecordSettingUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isAutoRecordEnabled();
  }
}

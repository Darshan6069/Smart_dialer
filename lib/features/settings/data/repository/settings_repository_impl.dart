import '../../domain/repository/settings_repository.dart';
import '../datasource/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> isDarkThemeEnabled() async {
    return await localDataSource.isDarkThemeEnabled();
  }

  @override
  Future<void> setDarkThemeEnabled(bool enabled) async {
    await localDataSource.setDarkThemeEnabled(enabled);
  }

  @override
  Future<bool> isAutoRecordEnabled() async {
    return await localDataSource.isAutoRecordEnabled();
  }

  @override
  Future<void> setAutoRecordEnabled(bool enabled) async {
    await localDataSource.setAutoRecordEnabled(enabled);
  }
}

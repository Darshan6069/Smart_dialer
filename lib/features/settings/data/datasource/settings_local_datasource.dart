import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

abstract class SettingsLocalDataSource {
  Future<bool> isDarkThemeEnabled();
  Future<void> setDarkThemeEnabled(bool enabled);
  Future<bool> isAutoRecordEnabled();
  Future<void> setAutoRecordEnabled(bool enabled);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Box _settingsBox;

  SettingsLocalDataSourceImpl(this._settingsBox);

  @override
  Future<bool> isDarkThemeEnabled() async {
    try {
      return _settingsBox.get(AppConstants.keyDarkTheme, defaultValue: true) as bool;
    } catch (e) {
      throw CacheException('Failed to load theme settings.');
    }
  }

  @override
  Future<void> setDarkThemeEnabled(bool enabled) async {
    try {
      await _settingsBox.put(AppConstants.keyDarkTheme, enabled);
    } catch (e) {
      throw CacheException('Failed to persist theme settings.');
    }
  }

  @override
  Future<bool> isAutoRecordEnabled() async {
    try {
      return _settingsBox.get(AppConstants.keyAutoRecord, defaultValue: false) as bool;
    } catch (e) {
      throw CacheException('Failed to load call auto-record preferences.');
    }
  }

  @override
  Future<void> setAutoRecordEnabled(bool enabled) async {
    try {
      await _settingsBox.put(AppConstants.keyAutoRecord, enabled);
    } catch (e) {
      throw CacheException('Failed to persist call auto-record preferences.');
    }
  }
}

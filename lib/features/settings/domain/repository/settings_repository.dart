abstract class SettingsRepository {
  Future<bool> isDarkThemeEnabled();
  Future<void> setDarkThemeEnabled(bool enabled);
  Future<bool> isAutoRecordEnabled();
  Future<void> setAutoRecordEnabled(bool enabled);
}

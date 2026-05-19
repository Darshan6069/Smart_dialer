import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_theme_setting.dart';
import '../../domain/usecases/save_theme_setting.dart';
import '../../domain/usecases/get_auto_record_setting.dart';
import '../../domain/usecases/save_auto_record_setting.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetThemeSettingUseCase getThemeSettingUseCase;
  final SaveThemeSettingUseCase saveThemeSettingUseCase;
  final GetAutoRecordSettingUseCase getAutoRecordSettingUseCase;
  final SaveAutoRecordSettingUseCase saveAutoRecordSettingUseCase;

  SettingsCubit({
    required this.getThemeSettingUseCase,
    required this.saveThemeSettingUseCase,
    required this.getAutoRecordSettingUseCase,
    required this.saveAutoRecordSettingUseCase,
  }) : super(const SettingsState.initial());

  Future<void> loadSettings() async {
    emit(const SettingsState.loading());
    try {
      final isDark = await getThemeSettingUseCase();
      final isAuto = await getAutoRecordSettingUseCase();
      emit(SettingsState.loaded(isDarkTheme: isDark, isAutoRecord: isAuto));
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> toggleTheme(bool enabled) async {
    final wasAuto = state.maybeWhen(
      loaded: (isDarkTheme, isAutoRecord) => isAutoRecord,
      orElse: () => false,
    );
    try {
      await saveThemeSettingUseCase(enabled);
      emit(SettingsState.loaded(isDarkTheme: enabled, isAutoRecord: wasAuto));
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> toggleAutoRecord(bool enabled) async {
    final wasDark = state.maybeWhen(
      loaded: (isDarkTheme, isAutoRecord) => isDarkTheme,
      orElse: () => true,
    );
    try {
      await saveAutoRecordSettingUseCase(enabled);
      emit(SettingsState.loaded(isDarkTheme: wasDark, isAutoRecord: enabled));
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }
}

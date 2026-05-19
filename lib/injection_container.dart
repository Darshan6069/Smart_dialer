import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:record/record.dart';
import 'core/constants/app_constants.dart';
import 'features/contacts/data/datasource/contacts_local_datasource.dart';
import 'features/contacts/data/repository/contacts_repository_impl.dart';
import 'features/contacts/domain/repository/contacts_repository.dart';
import 'features/contacts/domain/usecases/get_contacts.dart';
import 'features/contacts/presentation/cubit/contacts_cubit.dart';
import 'features/dialer/presentation/cubit/dialer_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/recents/data/datasource/recents_local_datasource.dart';
import 'features/recents/data/models/recent_call_model.dart';
import 'features/recents/data/repository/recents_repository_impl.dart';
import 'features/recents/domain/repository/recents_repository.dart';
import 'features/recents/domain/usecases/clear_recent_calls.dart';
import 'features/recents/domain/usecases/get_recent_calls.dart';
import 'features/recents/domain/usecases/save_recent_call.dart';
import 'features/recents/presentation/cubit/recents_cubit.dart';
import 'features/recording/data/datasource/recording_local_datasource.dart';
import 'features/recording/data/models/recorded_call_model.dart';
import 'features/recording/data/repository/recording_repository_impl.dart';
import 'features/recording/domain/repository/recording_repository.dart';
import 'features/recording/domain/usecases/delete_recording.dart';
import 'features/recording/domain/usecases/get_recordings.dart';
import 'features/recording/domain/usecases/start_recording.dart';
import 'features/recording/domain/usecases/stop_recording.dart';
import 'features/recording/presentation/cubit/recording_cubit.dart';
import 'features/settings/data/datasource/settings_local_datasource.dart';
import 'features/settings/data/repository/settings_repository_impl.dart';
import 'features/settings/domain/repository/settings_repository.dart';
import 'features/settings/domain/usecases/get_auto_record_setting.dart';
import 'features/settings/domain/usecases/get_theme_setting.dart';
import 'features/settings/domain/usecases/save_auto_record_setting.dart';
import 'features/settings/domain/usecases/save_theme_setting.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';
import 'features/call_screen/presentation/cubit/call_screen_cubit.dart';
import 'native_bridge/native_bridge.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================================
  // HIVE DATABASE SETUP
  // ==========================================
  await Hive.initFlutter();
  
  // Register manual fast-compiling type adapters
  Hive.registerAdapter(RecentCallAdapter());
  Hive.registerAdapter(RecordedCallAdapter());

  // Open Hive Storage Boxes
  final settingsBox = await Hive.openBox(AppConstants.settingsBox);
  final recentCallsBox = await Hive.openBox<RecentCallModel>(AppConstants.recentCallsBox);
  final recordingsBox = await Hive.openBox<RecordedCallModel>(AppConstants.recordingsBox);

  // ==========================================
  // EXTERNAL SERVICES / SINGLETONS
  // ==========================================
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<NativeBridge>(() => NativeBridge());
  sl.registerLazySingleton<AudioRecorder>(() => AudioRecorder());
  
  // ==========================================
  // DATA SOURCES
  // ==========================================
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(settingsBox),
  );
  sl.registerLazySingleton<RecentsLocalDataSource>(
    () => RecentsLocalDataSourceImpl(recentCallsBox),
  );
  sl.registerLazySingleton<ContactsLocalDataSource>(
    () => ContactsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<RecordingLocalDataSource>(
    () => RecordingLocalDataSourceImpl(recordingsBox, sl<AudioRecorder>()),
  );

  // ==========================================
  // REPOSITORIES
  // ==========================================
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<RecentsRepository>(
    () => RecentsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ContactsRepository>(
    () => ContactsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<RecordingRepository>(
    () => RecordingRepositoryImpl(localDataSource: sl()),
  );

  // ==========================================
  // USE CASES
  // ==========================================
  // Settings
  sl.registerLazySingleton(() => GetThemeSettingUseCase(sl()));
  sl.registerLazySingleton(() => SaveThemeSettingUseCase(sl()));
  sl.registerLazySingleton(() => GetAutoRecordSettingUseCase(sl()));
  sl.registerLazySingleton(() => SaveAutoRecordSettingUseCase(sl()));

  // Recents
  sl.registerLazySingleton(() => GetRecentCallsUseCase(sl()));
  sl.registerLazySingleton(() => SaveRecentCallUseCase(sl()));
  sl.registerLazySingleton(() => ClearRecentCallsUseCase(sl()));

  // Contacts
  sl.registerLazySingleton(() => GetContactsUseCase(sl()));

  // Recordings
  sl.registerLazySingleton(() => GetRecordingsUseCase(sl()));
  sl.registerLazySingleton(() => StartRecordingUseCase(sl()));
  sl.registerLazySingleton(() => StopRecordingUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRecordingUseCase(sl()));

  // ==========================================
  // PRESENTATION STATE MANAGERS (CUBITS)
  // ==========================================
  sl.registerFactory(() => SplashCubit(nativeBridge: sl()));
  sl.registerFactory(() => HomeCubit());
  sl.registerFactory(
    () => SettingsCubit(
      getThemeSettingUseCase: sl(),
      saveThemeSettingUseCase: sl(),
      getAutoRecordSettingUseCase: sl(),
      saveAutoRecordSettingUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => RecentsCubit(
      getRecentCallsUseCase: sl(),
      saveRecentCallUseCase: sl(),
      clearRecentCallsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ContactsCubit(
      getContactsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => RecordingCubit(
      getRecordingsUseCase: sl(),
      startRecordingUseCase: sl(),
      stopRecordingUseCase: sl(),
      deleteRecordingUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => DialerCubit(
      nativeBridge: sl(),
      getContactsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CallScreenCubit(
      nativeBridge: sl(),
      recentsCubit: sl(),
      recordingCubit: sl(),
    ),
  );
}

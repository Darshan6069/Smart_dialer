import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/contacts/presentation/cubit/contacts_cubit.dart';
import 'features/dialer/presentation/cubit/dialer_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/recents/presentation/cubit/recents_cubit.dart';
import 'features/recording/presentation/cubit/recording_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';
import 'features/call_screen/presentation/cubit/call_screen_cubit.dart';
import 'injection_container.dart' as di;

class SmartDialerApp extends StatelessWidget {
  const SmartDialerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashCubit>(create: (_) => di.sl<SplashCubit>()),
        BlocProvider<HomeCubit>(create: (_) => di.sl<HomeCubit>()),
        BlocProvider<SettingsCubit>(create: (_) => di.sl<SettingsCubit>()..loadSettings()),
        BlocProvider<RecentsCubit>(create: (_) => di.sl<RecentsCubit>()),
        BlocProvider<ContactsCubit>(create: (_) => di.sl<ContactsCubit>()),
        BlocProvider<RecordingCubit>(create: (_) => di.sl<RecordingCubit>()),
        BlocProvider<DialerCubit>(create: (_) => di.sl<DialerCubit>()),
        BlocProvider<CallScreenCubit>(create: (_) => di.sl<CallScreenCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Smart Dialer',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}

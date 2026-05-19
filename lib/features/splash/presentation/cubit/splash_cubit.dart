import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../native_bridge/native_bridge.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final NativeBridge nativeBridge;

  SplashCubit({required this.nativeBridge}) : super(const SplashState.initial());

  Future<void> initApp() async {
    emit(const SplashState.checkingPermissions());

    // Request required system telephony + contacts permissions
    await [
      Permission.phone,
      Permission.contacts,
      Permission.microphone,
    ].request();

    // Register native call listener now that permissions are checked
    await nativeBridge.registerCallStateListener();

    // Premium branding animations lag
    await Future.delayed(const Duration(milliseconds: 1200));

    emit(const SplashState.completed());
  }
}

import 'dart:async';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';

class NativeBridge {
  static const MethodChannel _dialerChannel = MethodChannel(AppConstants.dialerChannel);
  static const MethodChannel _recordingChannel = MethodChannel(AppConstants.recordingChannel);

  final StreamController<Map<String, String>> _callStateController = StreamController<Map<String, String>>.broadcast();

  NativeBridge() {
    _dialerChannel.setMethodCallHandler((call) async {
      if (call.method == 'onCallStateChanged') {
        final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
        final String state = args['state'] as String? ?? 'idle';
        final String number = args['phoneNumber'] as String? ?? '';
        _callStateController.add({'state': state, 'phoneNumber': number});
      }
      return null;
    });
  }

  Stream<Map<String, String>> get callStateStream => _callStateController.stream;

  // Default Dialer Check
  Future<bool> isSystemDialer() async {
    try {
      final bool result = await _dialerChannel.invokeMethod(AppConstants.methodGetSystemDialer);
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Register Call State Telephony Listener dynamically
  Future<bool> registerCallStateListener() async {
    try {
      final bool result = await _dialerChannel.invokeMethod('registerCallStateListener');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Request to set as Default Dialer
  Future<bool> setSystemDialer() async {
    try {
      final bool result = await _dialerChannel.invokeMethod(AppConstants.methodSetSystemDialer);
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Launch call intent / make a direct native call
  Future<bool> makeCall(String phoneNumber) async {
    try {
      final bool result = await _dialerChannel.invokeMethod(
        AppConstants.methodMakeCall,
        {'phoneNumber': phoneNumber},
      );
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // End active system call
  Future<bool> endCall() async {
    try {
      final bool result = await _dialerChannel.invokeMethod(AppConstants.methodEndCall);
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Toggle speakerphone route natively
  Future<bool> setSpeakerphoneOn(bool enabled) async {
    try {
      final bool result = await _dialerChannel.invokeMethod('setSpeakerphoneOn', {'enabled': enabled});
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Toggle microphone mute natively
  Future<bool> setMicrophoneMute(bool enabled) async {
    try {
      final bool result = await _dialerChannel.invokeMethod('setMicrophoneMute', {'enabled': enabled});
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Call Recording compatibility check
  Future<bool> isRecordingSupported() async {
    try {
      final bool result = await _recordingChannel.invokeMethod(AppConstants.methodIsRecordingSupported);
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Start call recording natively
  Future<bool> startNativeRecording(String fileName) async {
    try {
      final bool result = await _recordingChannel.invokeMethod(
        AppConstants.methodStartAudioRecord,
        {'fileName': fileName},
      );
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Stop native call recording
  Future<String?> stopNativeRecording() async {
    try {
      final String? path = await _recordingChannel.invokeMethod(AppConstants.methodStopAudioRecord);
      return path;
    } on PlatformException catch (_) {
      return null;
    }
  }
}

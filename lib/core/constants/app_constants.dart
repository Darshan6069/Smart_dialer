class AppConstants {
  // Application Details
  static const String appName = 'Smart Dialer';

  // Hive Box Names
  static const String settingsBox = 'settings_box';
  static const String recentCallsBox = 'recent_calls_box';
  static const String recordingsBox = 'recordings_box';

  // Hive Box Keys
  static const String keyDarkTheme = 'dark_theme_enabled';
  static const String keyAutoRecord = 'auto_record_enabled';

  // Native Method Channels
  static const String dialerChannel = 'com.smartdialer.app/dialer';
  static const String recordingChannel = 'com.smartdialer.app/recording';

  // Native Methods (Dialer)
  static const String methodGetSystemDialer = 'getSystemDialer';
  static const String methodSetSystemDialer = 'setSystemDialer';
  static const String methodMakeCall = 'makeCall';
  static const String methodEndCall = 'endCall';
  static const String methodIncomingCallBroadcast = 'incomingCallBroadcast';

  // Native Methods (Recording)
  static const String methodStartAudioRecord = 'startAudioRecord';
  static const String methodStopAudioRecord = 'stopAudioRecord';
  static const String methodIsRecordingSupported = 'isRecordingSupported';

  // UI Constants
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
}

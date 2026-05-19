import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_screen_state.freezed.dart';

@freezed
class CallScreenState with _$CallScreenState {
  const factory CallScreenState.idle() = _Idle;

  const factory CallScreenState.dialing({
    required String name,
    required String number,
    @Default(false) bool isMuted,
    @Default(false) bool isSpeakerOn,
  }) = _Dialing;

  const factory CallScreenState.ringing({
    required String name,
    required String number,
    @Default(false) bool isMuted,
    @Default(false) bool isSpeakerOn,
  }) = _Ringing;

  const factory CallScreenState.inCall({
    required String name,
    required String number,
    @Default(0) int durationSeconds,
    @Default(false) bool isMuted,
    @Default(false) bool isSpeakerOn,
    @Default(false) bool isRecording,
  }) = _InCall;

  const factory CallScreenState.ended({
    required String name,
    required String number,
    @Default(0) int durationSeconds,
    String? message,
  }) = _Ended;
}

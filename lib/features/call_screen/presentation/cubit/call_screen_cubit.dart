import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../native_bridge/native_bridge.dart';
import '../../../recents/domain/entities/recent_call.dart';
import '../../../recents/presentation/cubit/recents_cubit.dart';
import '../../../recording/presentation/cubit/recording_cubit.dart';
import 'call_screen_state.dart';

class CallScreenCubit extends Cubit<CallScreenState> {
  final NativeBridge nativeBridge;
  final RecentsCubit recentsCubit;
  final RecordingCubit recordingCubit;

  Timer? _callTimer;
  StreamSubscription? _nativeCallStateSub;

  CallScreenCubit({
    required this.nativeBridge,
    required this.recentsCubit,
    required this.recordingCubit,
  }) : super(const CallScreenState.idle()) {
    _nativeCallStateSub = nativeBridge.callStateStream.listen((event) {
      final String nativeState = event['state'] ?? 'idle';
      final String nativeNumber = event['phoneNumber'] ?? '';
      _handleNativeCallStateChange(nativeState, nativeNumber);
    });
  }

  void _handleNativeCallStateChange(String nativeState, String nativeNumber) {
    state.maybeWhen(
      idle: () {
        if (nativeState == 'ringing') {
          emit(CallScreenState.ringing(name: 'Incoming Call', number: nativeNumber));
        } else if (nativeState == 'inCall') {
          emit(CallScreenState.inCall(name: 'Active Call', number: nativeNumber));
          _startTimer();
        }
      },
      dialing: (name, number, mute, speaker) {
        if (nativeState == 'inCall') {
          _startTimer();
        } else if (nativeState == 'idle') {
          _finalizeCall(name, number, false);
        }
      },
      ringing: (name, number, mute, speaker) {
        if (nativeState == 'inCall') {
          _startTimer();
        } else if (nativeState == 'idle') {
          _finalizeCall(name, number, true);
        }
      },
      inCall: (name, number, duration, mute, speaker, recording) {
        if (nativeState == 'idle') {
          _finalizeCall(name, number, false);
        }
      },
      orElse: () {},
    );
  }

  void startCall(String name, String number, bool isIncoming, bool autoRecord) {
    if (isIncoming) {
      emit(CallScreenState.ringing(name: name, number: number));
    } else {
      emit(CallScreenState.dialing(name: name, number: number));
    }

    if (autoRecord) {
      startRecording(name, number);
    }
  }

  void _startTimer() {
    _callTimer?.cancel();

    // Initialize state mapping
    state.maybeWhen(
      dialing: (name, number, mute, speaker) {
        emit(CallScreenState.inCall(
          name: name,
          number: number,
          durationSeconds: 0,
          isMuted: mute,
          isSpeakerOn: speaker,
        ));
      },
      ringing: (name, number, mute, speaker) {
        emit(CallScreenState.inCall(
          name: name,
          number: number,
          durationSeconds: 0,
          isMuted: mute,
          isSpeakerOn: speaker,
        ));
      },
      orElse: () {},
    );

    int elapsed = 0;

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state.maybeWhen(
        inCall: (name, number, duration, mute, speaker, recording) {
          elapsed++;
          emit(CallScreenState.inCall(
            name: name,
            number: number,
            durationSeconds: elapsed,
            isMuted: mute,
            isSpeakerOn: speaker,
            isRecording: recording,
          ));
        },
        orElse: () {
          timer.cancel();
        },
      );
    });
  }

  void toggleMute() {
    state.maybeWhen(
      dialing: (name, number, mute, speaker) {
        final nextMute = !mute;
        nativeBridge.setMicrophoneMute(nextMute);
        emit(CallScreenState.dialing(name: name, number: number, isMuted: nextMute, isSpeakerOn: speaker));
      },
      ringing: (name, number, mute, speaker) {
        final nextMute = !mute;
        nativeBridge.setMicrophoneMute(nextMute);
        emit(CallScreenState.ringing(name: name, number: number, isMuted: nextMute, isSpeakerOn: speaker));
      },
      inCall: (name, number, duration, mute, speaker, recording) {
        final nextMute = !mute;
        nativeBridge.setMicrophoneMute(nextMute);
        emit(CallScreenState.inCall(
          name: name,
          number: number,
          durationSeconds: duration,
          isMuted: nextMute,
          isSpeakerOn: speaker,
          isRecording: recording,
        ));
      },
      orElse: () {},
    );
  }

  void toggleSpeaker() {
    state.maybeWhen(
      dialing: (name, number, mute, speaker) {
        final nextSpeaker = !speaker;
        nativeBridge.setSpeakerphoneOn(nextSpeaker);
        emit(CallScreenState.dialing(name: name, number: number, isMuted: mute, isSpeakerOn: nextSpeaker));
      },
      ringing: (name, number, mute, speaker) {
        final nextSpeaker = !speaker;
        nativeBridge.setSpeakerphoneOn(nextSpeaker);
        emit(CallScreenState.ringing(name: name, number: number, isMuted: mute, isSpeakerOn: nextSpeaker));
      },
      inCall: (name, number, duration, mute, speaker, recording) {
        final nextSpeaker = !speaker;
        nativeBridge.setSpeakerphoneOn(nextSpeaker);
        emit(CallScreenState.inCall(
          name: name,
          number: number,
          durationSeconds: duration,
          isMuted: mute,
          isSpeakerOn: nextSpeaker,
          isRecording: recording,
        ));
      },
      orElse: () {},
    );
  }

  Future<void> startRecording(String name, String number) async {
    final canRecord = state.maybeWhen(
      inCall: (name, number, duration, mute, speaker, recording) => !recording,
      orElse: () => false,
    );
    if (!canRecord) return;

    await recordingCubit.startCallRecording(name, number);

    state.maybeWhen(
      inCall: (name, number, duration, mute, speaker, recording) {
        emit(CallScreenState.inCall(
          name: name,
          number: number,
          durationSeconds: duration,
          isMuted: mute,
          isSpeakerOn: speaker,
          isRecording: true,
        ));
      },
      orElse: () {},
    );
  }

  Future<void> stopRecording() async {
    final canStop = state.maybeWhen(
      inCall: (name, number, duration, mute, speaker, recording) => recording,
      orElse: () => false,
    );
    if (!canStop) return;

    await recordingCubit.stopCallRecording();

    state.maybeWhen(
      inCall: (name, number, duration, mute, speaker, recording) {
        emit(CallScreenState.inCall(
          name: name,
          number: number,
          durationSeconds: duration,
          isMuted: mute,
          isSpeakerOn: speaker,
          isRecording: false,
        ));
      },
      orElse: () {},
    );
  }

  Future<void> endCall() async {
    final currentData = state.maybeWhen(
      dialing: (name, number, mute, speaker) => {'name': name, 'number': number, 'isIncoming': false},
      ringing: (name, number, mute, speaker) => {'name': name, 'number': number, 'isIncoming': true},
      inCall: (name, number, duration, mute, speaker, recording) => {'name': name, 'number': number, 'isIncoming': false},
      orElse: () => null,
    );

    if (currentData != null) {
      await nativeBridge.endCall();
      await _finalizeCall(
        currentData['name'] as String,
        currentData['number'] as String,
        currentData['isIncoming'] as bool,
      );
    }
  }

  Future<void> _finalizeCall(String name, String number, bool isIncoming) async {
    _callTimer?.cancel();

    bool wasRecorded = false;
    String? recordPath;

    final recordingActive = state.maybeWhen(
      inCall: (_, __, ___, ____, _____, recording) => recording,
      orElse: () => false,
    );

    final duration = state.maybeWhen(
      inCall: (_, __, dur, ___, ____, _____) => dur,
      ended: (_, __, dur, ___) => dur,
      orElse: () => 0,
    );

    if (recordingActive) {
      final savedFile = await recordingCubit.stopCallRecording();
      recordPath = savedFile?.filePath;
      wasRecorded = true;
    }

    emit(CallScreenState.ended(name: name, number: number, durationSeconds: duration));

    final callLog = RecentCall(
      id: const Uuid().v4(),
      name: name.isEmpty ? number : name,
      number: number,
      timestamp: DateTime.now(),
      durationInSeconds: duration,
      type: isIncoming ? CallType.incoming : CallType.outgoing,
      isRecorded: wasRecorded,
      recordingPath: recordPath,
    );
    await recentsCubit.addCallToHistory(callLog);

    await Future.delayed(const Duration(seconds: 2));
    emit(const CallScreenState.idle());
  }

  @override
  Future<void> close() {
    _callTimer?.cancel();
    _nativeCallStateSub?.cancel();
    return super.close();
  }
}

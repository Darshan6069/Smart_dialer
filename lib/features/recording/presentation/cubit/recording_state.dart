import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/recorded_call.dart';

part 'recording_state.freezed.dart';

@freezed
class RecordingState with _$RecordingState {
  const factory RecordingState.initial() = _Initial;
  const factory RecordingState.loading() = _Loading;
  const factory RecordingState.loaded({
    required List<RecordedCall> recordings,
    @Default(false) bool isRecordingActive,
    String? currentRecordingName,
    String? currentRecordingNumber,
  }) = _Loaded;
  const factory RecordingState.error(String message) = _Error;
}

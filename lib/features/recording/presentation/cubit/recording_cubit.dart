import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recorded_call.dart';
import '../../domain/usecases/get_recordings.dart';
import '../../domain/usecases/start_recording.dart';
import '../../domain/usecases/stop_recording.dart';
import '../../domain/usecases/delete_recording.dart';
import 'recording_state.dart';

class RecordingCubit extends Cubit<RecordingState> {
  final GetRecordingsUseCase getRecordingsUseCase;
  final StartRecordingUseCase startRecordingUseCase;
  final StopRecordingUseCase stopRecordingUseCase;
  final DeleteRecordingUseCase deleteRecordingUseCase;

  RecordingCubit({
    required this.getRecordingsUseCase,
    required this.startRecordingUseCase,
    required this.stopRecordingUseCase,
    required this.deleteRecordingUseCase,
  }) : super(const RecordingState.initial());

  Future<void> loadRecordings() async {
    emit(const RecordingState.loading());
    try {
      final recordings = await getRecordingsUseCase();
      emit(RecordingState.loaded(recordings: recordings));
    } catch (e) {
      emit(RecordingState.error(e.toString()));
    }
  }

  Future<void> startCallRecording(String contactName, String contactNumber) async {
    try {
      await startRecordingUseCase(contactName, contactNumber);
      
      final currentList = _getCurrentRecordings();
      emit(RecordingState.loaded(
        recordings: currentList,
        isRecordingActive: true,
        currentRecordingName: contactName,
        currentRecordingNumber: contactNumber,
      ));
    } catch (e) {
      emit(RecordingState.error('Failed to trigger audio recorder: $e'));
    }
  }

  Future<RecordedCall?> stopCallRecording() async {
    try {
      final savedRecord = await stopRecordingUseCase();
      final currentList = await getRecordingsUseCase();
      
      emit(RecordingState.loaded(
        recordings: currentList,
        isRecordingActive: false,
      ));
      return savedRecord;
    } catch (e) {
      emit(RecordingState.error('Failed to halt audio recording: $e'));
      return null;
    }
  }

  Future<void> removeRecording(String id) async {
    try {
      await deleteRecordingUseCase(id);
      final currentList = await getRecordingsUseCase();
      final wasRecordingActive = state.maybeWhen(
        loaded: (recordings, isRecordingActive, name, number) => isRecordingActive,
        orElse: () => false,
      );
      
      emit(RecordingState.loaded(
        recordings: currentList,
        isRecordingActive: wasRecordingActive,
      ));
    } catch (e) {
      emit(RecordingState.error('Failed to delete recording record: $e'));
    }
  }

  List<RecordedCall> _getCurrentRecordings() {
    return state.maybeWhen(
      loaded: (recordings, isRecordingActive, name, number) => recordings,
      orElse: () => [],
    );
  }
}

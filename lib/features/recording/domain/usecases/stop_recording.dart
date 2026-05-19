import '../entities/recorded_call.dart';
import '../repository/recording_repository.dart';

class StopRecordingUseCase {
  final RecordingRepository repository;

  StopRecordingUseCase(this.repository);

  Future<RecordedCall?> call() async {
    return await repository.stopRecording();
  }
}

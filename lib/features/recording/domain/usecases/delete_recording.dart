import '../repository/recording_repository.dart';

class DeleteRecordingUseCase {
  final RecordingRepository repository;

  DeleteRecordingUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteRecording(id);
  }
}

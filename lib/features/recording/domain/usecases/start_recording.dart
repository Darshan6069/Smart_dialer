import '../repository/recording_repository.dart';

class StartRecordingUseCase {
  final RecordingRepository repository;

  StartRecordingUseCase(this.repository);

  Future<void> call(String name, String number) async {
    await repository.startRecording(name, number);
  }
}

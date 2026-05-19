import '../entities/recorded_call.dart';
import '../repository/recording_repository.dart';

class GetRecordingsUseCase {
  final RecordingRepository repository;

  GetRecordingsUseCase(this.repository);

  Future<List<RecordedCall>> call() async {
    return await repository.getRecordings();
  }
}

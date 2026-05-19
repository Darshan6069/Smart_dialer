import '../../domain/entities/recorded_call.dart';
import '../../domain/repository/recording_repository.dart';
import '../datasource/recording_local_datasource.dart';
import '../models/recorded_call_model.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingLocalDataSource localDataSource;

  RecordingRepositoryImpl({required this.localDataSource});

  @override
  Future<List<RecordedCall>> getRecordings() async {
    return await localDataSource.getRecordings();
  }

  @override
  Future<void> saveRecording(RecordedCall recording) async {
    final model = RecordedCallModel.fromEntity(recording);
    await localDataSource.saveRecording(model);
  }

  @override
  Future<void> deleteRecording(String id) async {
    await localDataSource.deleteRecording(id);
  }

  @override
  Future<void> startRecording(String name, String number) async {
    await localDataSource.startRecording(name, number);
  }

  @override
  Future<RecordedCall?> stopRecording() async {
    return await localDataSource.stopRecording();
  }

  @override
  Future<bool> checkPermission() async {
    return await localDataSource.checkPermission();
  }
}

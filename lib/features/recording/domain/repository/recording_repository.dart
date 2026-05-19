import '../entities/recorded_call.dart';

abstract class RecordingRepository {
  Future<List<RecordedCall>> getRecordings();
  Future<void> saveRecording(RecordedCall recording);
  Future<void> deleteRecording(String id);
  Future<void> startRecording(String name, String number);
  Future<RecordedCall?> stopRecording();
  Future<bool> checkPermission();
}

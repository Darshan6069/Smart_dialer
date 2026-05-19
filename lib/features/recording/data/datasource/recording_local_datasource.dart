import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/recorded_call_model.dart';

abstract class RecordingLocalDataSource {
  Future<List<RecordedCallModel>> getRecordings();
  Future<void> saveRecording(RecordedCallModel recording);
  Future<void> deleteRecording(String id);
  Future<void> startRecording(String name, String number);
  Future<RecordedCallModel?> stopRecording();
  Future<bool> checkPermission();
}

class RecordingLocalDataSourceImpl implements RecordingLocalDataSource {
  final Box<RecordedCallModel> _recordingsBox;
  final AudioRecorder _audioRecorder;
  
  String? _tempName;
  String? _tempNumber;
  DateTime? _tempStartTime;

  RecordingLocalDataSourceImpl(this._recordingsBox, this._audioRecorder);

  @override
  Future<bool> checkPermission() async {
    try {
      final micStatus = await Permission.microphone.request();
      final storageStatus = await Permission.storage.request();
      return micStatus.isGranted && (storageStatus.isGranted || Platform.isAndroid);
    } catch (e) {
      throw PermissionException('Error checking recording permissions.');
    }
  }

  @override
  Future<void> startRecording(String name, String number) async {
    try {
      final hasPerm = await checkPermission();
      if (!hasPerm) {
        throw PermissionException('Microphone permission not granted.');
      }

      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }

      final docDir = await getApplicationDocumentsDirectory();
      final String recordId = const Uuid().v4();
      final String filePath = '${docDir.path}/rec_$recordId.m4a';

      _tempName = name;
      _tempNumber = number;
      _tempStartTime = DateTime.now();

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
    } catch (e) {
      throw ServerException('Failed to start call recording session.');
    }
  }

  @override
  Future<RecordedCallModel?> stopRecording() async {
    try {
      final String? path = await _audioRecorder.stop();
      if (path == null || _tempStartTime == null) return null;

      final File file = File(path);
      if (!await file.exists()) return null;

      final int size = await file.length();
      final int duration = DateTime.now().difference(_tempStartTime!).inSeconds;

      final RecordedCallModel recording = RecordedCallModel(
        id: const Uuid().v4(),
        name: _tempName ?? 'Unknown Number',
        number: _tempNumber ?? 'Unknown',
        timestamp: _tempStartTime!,
        durationInSeconds: duration > 0 ? duration : 1,
        filePath: path,
        fileSizeInBytes: size,
      );

      await saveRecording(recording);
      
      // Reset temp tracking states
      _tempName = null;
      _tempNumber = null;
      _tempStartTime = null;

      return recording;
    } catch (e) {
      throw ServerException('Failed to finalize call recording output.');
    }
  }

  @override
  Future<List<RecordedCallModel>> getRecordings() async {
    try {
      final List<RecordedCallModel> list = _recordingsBox.values.toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (e) {
      throw CacheException('Failed to load call recordings.');
    }
  }

  @override
  Future<void> saveRecording(RecordedCallModel recording) async {
    try {
      await _recordingsBox.put(recording.id, recording);
    } catch (e) {
      throw CacheException('Failed to cache call recording details.');
    }
  }

  @override
  Future<void> deleteRecording(String id) async {
    try {
      final item = _recordingsBox.get(id);
      if (item != null) {
        final file = File(item.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _recordingsBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete call recording.');
    }
  }
}

import 'package:hive/hive.dart';
import '../../domain/entities/recorded_call.dart';

class RecordedCallModel extends RecordedCall {
  const RecordedCallModel({
    required super.id,
    required super.name,
    required super.number,
    required super.timestamp,
    required super.durationInSeconds,
    required super.filePath,
    required super.fileSizeInBytes,
  });

  factory RecordedCallModel.fromEntity(RecordedCall entity) {
    return RecordedCallModel(
      id: entity.id,
      name: entity.name,
      number: entity.number,
      timestamp: entity.timestamp,
      durationInSeconds: entity.durationInSeconds,
      filePath: entity.filePath,
      fileSizeInBytes: entity.fileSizeInBytes,
    );
  }

  factory RecordedCallModel.fromJson(Map<String, dynamic> json) {
    return RecordedCallModel(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationInSeconds: json['durationInSeconds'] as int,
      filePath: json['filePath'] as String,
      fileSizeInBytes: json['fileSizeInBytes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'timestamp': timestamp.toIso8601String(),
      'durationInSeconds': durationInSeconds,
      'filePath': filePath,
      'fileSizeInBytes': fileSizeInBytes,
    };
  }
}

class RecordedCallAdapter extends TypeAdapter<RecordedCallModel> {
  @override
  final int typeId = 1;

  @override
  RecordedCallModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte() as int] = reader.read();
    }
    return RecordedCallModel(
      id: fields[0] as String,
      name: fields[1] as String,
      number: fields[2] as String,
      timestamp: fields[3] as DateTime,
      durationInSeconds: fields[4] as int,
      filePath: fields[5] as String,
      fileSizeInBytes: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecordedCallModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.number)
      ..writeByte(3)..write(obj.timestamp)
      ..writeByte(4)..write(obj.durationInSeconds)
      ..writeByte(5)..write(obj.filePath)
      ..writeByte(6)..write(obj.fileSizeInBytes);
  }
}

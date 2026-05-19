import 'package:hive/hive.dart';
import '../../domain/entities/recent_call.dart';

class RecentCallModel extends RecentCall {
  const RecentCallModel({
    required super.id,
    required super.name,
    required super.number,
    required super.timestamp,
    required super.durationInSeconds,
    required super.type,
    required super.isRecorded,
    super.recordingPath,
  });

  factory RecentCallModel.fromEntity(RecentCall entity) {
    return RecentCallModel(
      id: entity.id,
      name: entity.name,
      number: entity.number,
      timestamp: entity.timestamp,
      durationInSeconds: entity.durationInSeconds,
      type: entity.type,
      isRecorded: entity.isRecorded,
      recordingPath: entity.recordingPath,
    );
  }

  factory RecentCallModel.fromJson(Map<String, dynamic> json) {
    return RecentCallModel(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationInSeconds: json['durationInSeconds'] as int,
      type: CallType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CallType.incoming,
      ),
      isRecorded: json['isRecorded'] as bool? ?? false,
      recordingPath: json['recordingPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'timestamp': timestamp.toIso8601String(),
      'durationInSeconds': durationInSeconds,
      'type': type.toString(),
      'isRecorded': isRecorded,
      'recordingPath': recordingPath,
    };
  }
}

// Custom manual Hive Adapter to ensure 100% instant compilation and eliminate build_runner issues
class RecentCallAdapter extends TypeAdapter<RecentCallModel> {
  @override
  final int typeId = 0;

  @override
  RecentCallModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte() as int] = reader.read();
    }
    return RecentCallModel(
      id: fields[0] as String,
      name: fields[1] as String,
      number: fields[2] as String,
      timestamp: fields[3] as DateTime,
      durationInSeconds: fields[4] as int,
      type: CallType.values[fields[5] as int],
      isRecorded: fields[6] as bool,
      recordingPath: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecentCallModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.number)
      ..writeByte(3)..write(obj.timestamp)
      ..writeByte(4)..write(obj.durationInSeconds)
      ..writeByte(5)..write(obj.type.index)
      ..writeByte(6)..write(obj.isRecorded)
      ..writeByte(7)..write(obj.recordingPath);
  }
}

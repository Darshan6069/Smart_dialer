import 'package:equatable/equatable.dart';

class RecordedCall extends Equatable {
  final String id;
  final String name;
  final String number;
  final DateTime timestamp;
  final int durationInSeconds;
  final String filePath;
  final int fileSizeInBytes;

  const RecordedCall({
    required this.id,
    required this.name,
    required this.number,
    required this.timestamp,
    required this.durationInSeconds,
    required this.filePath,
    required this.fileSizeInBytes,
  });

  RecordedCall copyWith({
    String? id,
    String? name,
    String? number,
    DateTime? timestamp,
    int? durationInSeconds,
    String? filePath,
    int? fileSizeInBytes,
  }) {
    return RecordedCall(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      timestamp: timestamp ?? this.timestamp,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      filePath: filePath ?? this.filePath,
      fileSizeInBytes: fileSizeInBytes ?? this.fileSizeInBytes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        number,
        timestamp,
        durationInSeconds,
        filePath,
        fileSizeInBytes,
      ];
}

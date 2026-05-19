import 'package:equatable/equatable.dart';

enum CallType { incoming, outgoing, missed }

class RecentCall extends Equatable {
  final String id;
  final String name;
  final String number;
  final DateTime timestamp;
  final int durationInSeconds;
  final CallType type;
  final bool isRecorded;
  final String? recordingPath;

  const RecentCall({
    required this.id,
    required this.name,
    required this.number,
    required this.timestamp,
    required this.durationInSeconds,
    required this.type,
    required this.isRecorded,
    this.recordingPath,
  });

  RecentCall copyWith({
    String? id,
    String? name,
    String? number,
    DateTime? timestamp,
    int? durationInSeconds,
    CallType? type,
    bool? isRecorded,
    String? recordingPath,
  }) {
    return RecentCall(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      timestamp: timestamp ?? this.timestamp,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      type: type ?? this.type,
      isRecorded: isRecorded ?? this.isRecorded,
      recordingPath: recordingPath ?? this.recordingPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        number,
        timestamp,
        durationInSeconds,
        type,
        isRecorded,
        recordingPath,
      ];
}

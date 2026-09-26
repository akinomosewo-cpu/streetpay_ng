import 'package:equatable/equatable.dart';

/// A single day's attendance record for one guard. [dayKey] is "yyyy-MM-dd".
class AttendanceRecord extends Equatable {
  final String id;
  final String guardId;
  final String dayKey;
  final bool present;

  const AttendanceRecord({
    required this.id,
    required this.guardId,
    required this.dayKey,
    required this.present,
  });

  String get monthKey => dayKey.substring(0, 7);

  Map<String, dynamic> toMap() => {
        'id': id,
        'guardId': guardId,
        'dayKey': dayKey,
        'present': present,
      };

  factory AttendanceRecord.fromMap(Map<dynamic, dynamic> map) => AttendanceRecord(
        id: map['id'] as String,
        guardId: map['guardId'] as String,
        dayKey: map['dayKey'] as String,
        present: map['present'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, guardId, dayKey, present];
}

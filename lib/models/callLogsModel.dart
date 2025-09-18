// lib/src/models/call_log.dart

enum CallType { incoming, outgoing, missed, unknown }

class CallLog {
  final String id;
  final String number;
  final DateTime date;
  final CallType type;
  final int duration; // in seconds

  CallLog({
    required this.id,
    required this.number,
    required this.date,
    required this.type,
    required this.duration,
  });

  factory CallLog.fromMap(Map<String, dynamic> map) {
    return CallLog(
      id: map['id'] ?? '',
      number: map['number'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      type: _parseCallType(map['type'] ?? 'unknown'),
      duration: map['duration'] ?? 0,
    );
  }

  static CallType _parseCallType(String type) {
    switch (type) {
      case 'incoming':
        return CallType.incoming;
      case 'outgoing':
        return CallType.outgoing;
      case 'missed':
        return CallType.missed;
      default:
        return CallType.unknown;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'date': date.millisecondsSinceEpoch,
      'type': type.toString().split('.').last,
      'duration': duration,
    };
  }
}

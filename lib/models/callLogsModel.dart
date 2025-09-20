// lib/src/models/call_log.dart

import 'package:contacts_getter/const/nullString.dart';

enum CallType { incoming, outgoing, missed, unknown }

class CallLog {
  String id;
  String number;
  String date;
  String type;
  String duration; // in seconds

  CallLog({
    this.id = "",
    this.number = "",
    this.date = "",
    this.type = "",
    this.duration = "",
  });

  factory CallLog.fromMap(Map<String, dynamic> map) {
    return CallLog(
      id: map['id'].toString().toNullString(),
      number: map['number'].toString().toNullString(),
      date: map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date']).toString().toNullString() : "",
      type: parseCallType(map['type'] ?? 'unknown').toString().toNullString(),
      duration: map['duration'].toString().toNullString(),
    );
  }

  static String parseCallType(String type) {
    switch (type) {
      case 'incoming':
        return "incoming";
      case 'outgoing':
        return "outgoing";
      case 'missed':
        return "missed";
      default:
        return "unknown";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString().toNullString(),
      'number': number.toString().toNullString(),
      'date': date.toString().toNullString(),
      'type': type.toString().toNullString(),
      'duration': duration.toString().toNullString(),
    };
  }
}

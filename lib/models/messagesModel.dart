// lib/src/models/message.dart

import 'package:contacts_getter/const/nullString.dart';

enum MessageType { sent, received, unknown }

class Message {
  String id;
  String address; // sender/receiver number
  String body;
  String date;
  String type;
  bool read;

  Message({
    this.id = "",
    this.address = "",
    this.body = "",
    this.date = "",
    this.type = "",
    this.read = false,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'].toString().toNullString(),
      address: map['address'].toString().toNullString(),
      body: map['body'].toString().toNullString(),
      date: map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date']).toString().toNullString() : "",
      type: parseMessageType(map['type'] ?? 'unknown').toString().toNullString(),
      read: map['read'] ?? false,
    );
  }

  static String parseMessageType(String type) {
    switch (type) {
      case 'sent':
        return "sent";
      case 'received':
        return "received";
      default:
        return "unknown";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString().toNullString(),
      'address': address.toString().toNullString(),
      'body': body.toString().toNullString(),
      'date': date.toString().toNullString(),
      'type': type.toString().toNullString(),
      'read': read.toString().toNullString() == 'true',
    };
  }
}

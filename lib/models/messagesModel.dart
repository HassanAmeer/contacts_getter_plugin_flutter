// lib/src/models/message.dart

enum MessageType { sent, received, unknown }

class Message {
  final String id;
  final String address; // sender/receiver number
  final String body;
  final DateTime date;
  final MessageType type;
  final bool read;

  Message({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
    required this.type,
    this.read = false,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      address: map['address'] ?? '',
      body: map['body'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      type: _parseMessageType(map['type'] ?? 'unknown'),
      read: map['read'] ?? false,
    );
  }

  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'sent':
        return MessageType.sent;
      case 'received':
        return MessageType.received;
      default:
        return MessageType.unknown;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'body': body,
      'date': date.millisecondsSinceEpoch,
      'type': type.toString().split('.').last,
      'read': read,
    };
  }
}

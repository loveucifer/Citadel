// lib/models/message.dart
//
// Defines the data structure for a single chat message.

class Message {
  final int? id;
  final int contactId; // Foreign key to the contacts table
  final String content;
  final DateTime timestamp;
  final bool isSentByMe;

  Message({
    this.id,
    required this.contactId,
    required this.content,
    required this.timestamp,
    required this.isSentByMe,
  });

  // A factory constructor for creating a new Message instance from a map.
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      contactId: map['contactId'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isSentByMe: map['isSentByMe'] == 1,
    );
  }

  // A method for converting a Message instance into a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isSentByMe': isSentByMe ? 1 : 0,
    };
  }
}

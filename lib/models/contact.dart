// lib/models/contact.dart
//
// Defines the data structure for a Citadel contact.

class Contact {
  final int? id; // The local database ID
  final String citizenName; // The user's public handle [ID1]
  final String publicKey; // The user's public cryptographic key
  final DateTime addedAt;

  Contact({
    this.id,
    required this.citizenName,
    required this.publicKey,
    required this.addedAt,
  });

  // A factory constructor for creating a new Contact instance from a map.
  // This is useful when reading from the database.
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      citizenName: map['citizenName'],
      publicKey: map['publicKey'],
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt']),
    );
  }

  // A method for converting a Contact instance into a map.
  // This is useful when writing to the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'citizenName': citizenName,
      'publicKey': publicKey,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }
}

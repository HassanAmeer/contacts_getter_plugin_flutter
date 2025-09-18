// lib/src/models/contact.dart

class Contact {
  final String id;
  final String displayName;
  final String? phoneNumber;
  final String? email;
  final String? photoUri;

  Contact({
    required this.id,
    required this.displayName,
    this.phoneNumber,
    this.email,
    this.photoUri,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      photoUri: map['photoUri'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUri': photoUri,
    };
  }
}

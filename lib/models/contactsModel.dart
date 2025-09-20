// lib/src/models/contact.dart

import 'package:contacts_getter/const/nullString.dart';

class Contact {
  String id;
  String displayName;
  String phoneNumber;
  String email;
  String photoUri;

  Contact({
    this.id = "",
    this.displayName = "",
    this.phoneNumber = "",
    this.email = "",
    this.photoUri = "",
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'].toString().toNullString(),
      displayName: map['displayName'].toString().toNullString(),
      phoneNumber: map['phoneNumber'].toString().toNullString(),
      email: map['email'].toString().toNullString(),
      photoUri: map['photoUri'].toString().toNullString(),
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

import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class CurrentUser {
  String UID;
  String email;
  String name;
  String user_type_id;
  String phone;
  String addresss;
  bool is_active;

  CurrentUser({
    required this.UID,
    required this.email,
    required this.name,
    required this.user_type_id,
    required this.phone,
    required this.addresss,
    required this.is_active,
  });

//Method to add this object's data to the Firebase database.
  Future<void> addToFirestore() async {
    await _firestore.collection('users').add({
      'UID': this.UID,
      'address': this.addresss,
      'email': this.email,
      'is_active': this.is_active,
      'name': this.name,
      'phone': this.phone,
      'user_type': this.user_type_id
    });
  }
}

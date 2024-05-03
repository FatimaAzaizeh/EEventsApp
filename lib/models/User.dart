import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class CurrentUser {
  String Name;
  String Email;
  String Gender;

  CurrentUser({
    required this.Name,
    required this.Email,
    required this.Gender,
  });

//Method to add this object's data to the Firebase database.
  Future<void> addToFirestore() async {
    await _firestore.collection('CurrentUser').add({
      'UserName': this.Name,
      'Email': this.Email,
      'Gender': this.Gender,
    });
  }
}

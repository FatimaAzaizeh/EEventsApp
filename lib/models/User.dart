import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataBase {
  final String id;
  final String email;
  final String name;
  final String user_type_id;
  final String phone;
  final String address;
  final bool isActive;
  final String imageUrl;

  UserDataBase({
    required this.id,
    required this.email,
    required this.name,
    required this.user_type_id,
    required this.phone,
    required this.address,
    required this.isActive,
    required this.imageUrl,
  });

  Future<void> saveToDatabase() async {
    try {
      // Reference to the Firestore collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Add the user to the 'users' collection
      await users.add({
        'id': id,
        'email': email,
        'name': name,
        'user_type_id': user_type_id,
        'phone': phone,
        'address': address,
        'is_active': isActive,
        'Image_url': imageUrl,
      });

      print('User added to the database successfully!');
    } catch (error) {
      print('Error adding user to the database: $error');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceType {
  String id;
  String name;
  String imageUrl;

  ServiceType({required this.id, required this.name, required this.imageUrl});

  Future<void> saveToDatabase() async {
    try {
      // Reference to the Firestore collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('service_types');

      // Add the user to the 'users' collection
      await users.add({
        'id': id,
        'name': name,
        'image_url': imageUrl,
      });

      print('User added to the database successfully!');
    } catch (error) {
      print('Error adding user to the database: $error');
    }
  }
}

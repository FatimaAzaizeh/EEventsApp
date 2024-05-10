import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceType {
  String id;
  String name;
  String imageUrl;

  ServiceType({required this.id, required this.name, required this.imageUrl});

  Future<void> saveToDatabase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Specify the custom document ID
    String customId = this.id;

    // Reference to the collection where you want to add the document
    CollectionReference collectionReference =
        firestore.collection('service_types');

    try {
      // Add the document with the custom ID
      await collectionReference.doc(customId).set({
        'id': id,
        'name': name,
        'image_url': imageUrl,
      });

      print('User added to the database successfully!');
    } catch (error) {
      print('Error adding user to the database: $error');
    }
  }

  //edit
  static Future<bool> updateServiceFirestore(
      String name, String Imageurl, String id) async {
    try {
      // Get a reference to the document you want to update
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('service_types')
          .where('id', isEqualTo: id)
          .get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (assuming id is unique)
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        // Get the reference to the document
        DocumentReference eventRef = docSnapshot.reference;

        // Update the fields of the document
        await eventRef.update({
          'name': name,
          'image_url': Imageurl,
        });

        print('Document updated successfully');
        return true;
      } else {
        print('No document found with id: $id');
        return false;
      }
    } catch (error) {
      print('Error updating document: $error');
      return false;
    }
  }
}

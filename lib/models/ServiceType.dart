import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceType {
  String id;
  String name;
  String imageUrl;

  ServiceType({required this.id, required this.name, required this.imageUrl});

  Future<String> saveToDatabase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
// Reference to the collection where you want to add the document
    CollectionReference collectionReference =
        firestore.collection('service_types');
    try {
// Check if an entry with the same name already exists
      QuerySnapshot nameQuerySnapshot =
          await collectionReference.where('name', isEqualTo: this.name).get();
      if (nameQuerySnapshot.docs.isNotEmpty) {
        return 'An entry with the name "${this.name}" already exists';
      }
// Check if the document already exists by ID
      DocumentSnapshot idDocumentSnapshot =
          await collectionReference.doc(this.id).get();
      if (idDocumentSnapshot.exists) {
        return 'Document with ID ${this.id} already exists';
      }
// Add the document
      await collectionReference.doc(this.id).set({
        'id': this.id,
        'name': this.name,
        'image_url': this.imageUrl,
      });
      print('Document added with ID: ${this.id}');
      return 'تم إضافة الخدمة بنجاح';
    } catch (e) {
      print('Error adding document: $e');
      return 'حدث خطأ لم تتم إضافة الخدمة: $e';
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

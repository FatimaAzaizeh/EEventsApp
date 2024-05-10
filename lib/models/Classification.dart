import 'package:cloud_firestore/cloud_firestore.dart';

class Classification {
  String id;
  String description;

  Classification({
    required this.id,
    required this.description,
  });

//create new EventType_Req3.
  Future<void> addDocumentWithCustomId() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Specify the custom document ID
    String customId = this.id;

    // Reference to the collection where you want to add the document
    CollectionReference collectionReference =
        firestore.collection('event_classificaion_types');

    try {
      // Add the document with the custom ID
      await collectionReference.doc(customId).set({
        'name': this.description,
        // Add other fields as needed
      });
      print('Document added with custom ID: $customId');
    } catch (e) {
      print('Error adding document: $e');
    }
  }

  //edit EventType_Req8
  static Future<bool> updateClassificationFirestore(
      String id, String description) async {
    try {
      // Get a reference to the document you want to update
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('event_classificaion_types')
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
          'description': description,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:testtapp/widgets/Event_item.dart';

final _firestore = FirebaseFirestore.instance;

class EventType {
  String id;
  String name;
  String imageUrl;
  DocumentReference event_classificaion_types;
  EventType(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.event_classificaion_types});

//create new EventType_Req3.
  Future<String> addToFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the collection where you want to add the document
    CollectionReference collectionReference =
        firestore.collection('event_types');

    try {
      // Check if an event with the same name already exists
      QuerySnapshot nameQuerySnapshot =
          await collectionReference.where('name', isEqualTo: this.name).get();

      if (nameQuerySnapshot.docs.isNotEmpty) {
        return 'An event with the name "${this.name}" already exists';
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
        'event_classificaion_types': this.event_classificaion_types,
        'image_url': this.imageUrl,
        // Add other fields as needed
      });
      print('Document added with ID: ${this.id}');
      return 'تم إضافة المناسبة بنجاح';
    } catch (e) {
      print('Error adding document: $e');
      return 'حدث خطأ لم تتم إضافة المناسبة: $e';
    }
  }

  //edit EventType_Req8
  static Future<bool> updateEventTypeFirestore(String newName, String newImage,
      DocumentReference newEventClassificationTypes, String id) async {
    try {
      // Get a reference to the document you want to update
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('event_types')
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
          'name': newName,
          'event_classificaion_types': newEventClassificationTypes,
          'image_url': newImage,
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

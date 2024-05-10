import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:testtapp/widgets/Event_item.dart';

final _firestore = FirebaseFirestore.instance;

class EventType {
  String id;
  String name;
  String imageUrl;
  Reference event_classificaion_types;
  EventType(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.event_classificaion_types});

  // Method to convert EventType object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
    };
  }

//create new EventType_Req3.
  Future<void> addToFirestore() async {
    await _firestore.collection('event_types').add({
      'id': this.id,
      'name': this.name,
      'event_classificaion_types': this.event_classificaion_types,
      'image_url': this.imageUrl,
    });
  }

  //edit EventType_Req8
  Future<bool> updateEventTypeFirestore(String newName, String newImage,
      String newEventClassificationTypes, String id) async {
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

  Future<bool> deleteEventTypeFirestore(String id) async {
    try {
      // Get a reference to the document you want to delete
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('event_types').doc(id);

      // Check if the document exists
      DocumentSnapshot docSnapshot = await eventRef.get();
      if (docSnapshot.exists) {
        // Delete the document
        await eventRef.delete();
        print('Document with ID $id deleted successfully');
        return true;
      } else {
        print('No document found with ID: $id');
        return false;
      }
    } catch (error) {
      print('Error deleting document: $error');
      return false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Classification {
  String id;
  String description;

  Classification({
    required this.id,
    required this.description,
  });

  // Create new EventType_Req3.
  Future<String> addDocumentWithCustomId() async {
    if (await isClassificationExist()) {
      return 'رقم التصنيف موجود الرجاء اختيار رقم اخر ';
    }

    if (await isClassificationDescExist()) {
      return 'اسم التصنيف موجود الرجاء ادخال اسم اخر ';
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Add the document with the custom ID
      await firestore.collection('event_classificaion_types').doc(id).set({
        'description': description,
        'id': id,
        // Add other fields as needed
      });
      return 'تم إضافة تصنيف جديد  $description';
    } catch (e) {
      return 'حدث خطأ ,لم يتم إضافة التصنيف: $e';
    }
  }

  // Edit EventType_Req8
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

  Future<bool> isClassificationExist() async {
    try {
      // Query Firestore to check if the document with given id exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('event_classificaion_types')
          .where('id', isEqualTo: id)
          .limit(1) // Limit the query to 1 document for efficiency
          .get();

      // If any documents match the query, it means the object exists
      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking document existence: $error');
      return false;
    }
  }

  Future<bool> isClassificationDescExist() async {
    try {
      // Query Firestore to check if the document with given id exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('event_classificaion_types')
          .where('description', isEqualTo: description)
          .limit(1) // Limit the query to 1 document for efficiency
          .get();

      // If any documents match the query, it means the object exists
      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking document existence: $error');
      return false;
    }
  }
}


/*
  // Get the number of the last document ID in the Firestore collection
  static Future<int?> getLastDocumentIdNumber() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the collection
    CollectionReference collectionReference =
        firestore.collection('event_classification_types');

    // Query to get all documents sorted by document ID in descending order
    QuerySnapshot querySnapshot = await collectionReference
        .orderBy(FieldPath.documentId, descending: true)
        .get();

    // Check if there are any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Extract the ID of the last document
      String lastDocumentId = querySnapshot.docs.first.id;

      // Extract the number part of the document ID
      int? lastDocumentIdNumber = int.tryParse(lastDocumentId.split('_').last);

      return lastDocumentIdNumber;
    }

    // Return null if no documents are found
    return null;
  }
*/
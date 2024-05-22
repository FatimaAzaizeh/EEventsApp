import 'package:cloud_firestore/cloud_firestore.dart';

class EventWizard {
  final String event_type_id;
  final Map<int, Map<String, dynamic>> services;

  EventWizard({required this.event_type_id, required this.services});

  // Method to upload EventWizard to Firebase Firestore
  Future<String> uploadToFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Specify the custom document ID
    String customId = this.event_type_id;

    // Reference to the collection where you want to add the document
    CollectionReference collectionReference =
        firestore.collection('event_wizard');

    try {
      // Add the document with the custom ID
      await collectionReference.doc(customId).set({
        'event_type_id': event_type_id,
        'services': services.map((key, value) {
          return MapEntry(
            key.toString(),
            {
              'order_number': key,
              'servicename': value['servicename'],
              'serviceimage': value['serviceimage'],
              'serviceId': value['serviceId'], // Store DocumentReference
            },
          );
        }),
      });
      return 'EventWizard uploaded to Firebase successfully!';
    } catch (e) {
      return 'Error uploading EventWizard to Firebase: $e';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String id;
  DocumentReference vendorId;
  String name;
  String itemCode;
  String imageUrl;
  String description;
  double price;
  int capacity;
  DocumentReference eventTypeId;
  DocumentReference serviceTypeId;
  DocumentReference eventClassificationTypeId;
  DocumentReference itemStatusId;
  DateTime createdAt;

  Item({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.itemCode,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.capacity,
    required this.eventTypeId,
    required this.serviceTypeId,
    required this.eventClassificationTypeId,
    required this.itemStatusId,
    required this.createdAt,
  });

  // Method to add an item to Firestore
  Future<void> addItemToFirestore() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('items').doc(id);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        throw Exception('Item with ID $id already exists.');
      }
      await docRef.set({
        'id': id,
        'vendor_id': vendorId,
        'name': name,
        'item_code': itemCode,
        'image_url': imageUrl,
        'description': description,
        'price': price,
        'capacity': capacity,
        'event_type_id': eventTypeId,
        'service_type_id': serviceTypeId,
        'event_classification_type_id': eventClassificationTypeId,
        'item_status_id': itemStatusId,
        'created_at': Timestamp.fromDate(createdAt),
      });
    } catch (error) {
      throw Exception('Failed to add item: $error');
    }
  }

  // Method to edit an item in Firestore
  static Future<void> editItemInFirestore(
      String id,
      String name,
      String itemCode,
      String imageUrl,
      String description,
      double price,
      int capacity) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('items').doc(id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Item with ID $id does not exist.');
      }
      await docRef.update({
        'name': name,
        'item_code': itemCode,
        'image_url': imageUrl,
        'description': description,
        'price': price,
        'capacity': capacity,
        // 'event_type_id': eventTypeId,
        // 'service_type_id': serviceTypeId,
        // 'event_classification_type_id': eventClassificationTypeId,
        // 'item_status_id': itemStatusId,
      });
    } catch (error) {
      throw Exception('Failed to edit item: $error');
    }
  }

  // Method to disable an item in Firestore
  Future<void> deactiveItemInFirestore(
      String id, DocumentReference item_status_id) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('items').doc(id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Item with ID $id does not exist.');
      }
      await docRef.update({
        'item_status_id': itemStatusId,
      });
    } catch (error) {
      throw Exception('Failed to edit item: $error');
    }
  }
}

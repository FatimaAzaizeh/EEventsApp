import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
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
  Timestamp createdAt;

  Item({
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
      final docRef =
          FirebaseFirestore.instance.collection('item').doc(itemCode);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        throw Exception('Item with ID $itemCode already exists.');
      }
      await docRef.set({
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
        'created_at': createdAt,
      });
    } catch (error) {
      throw Exception('Failed to add item: $error');
    }
  }

  // Method to edit an item in Firestore
  static Future<void> editItemInFirestore(
      String name,
      String itemCode,
      String imageUrl,
      String description,
      double price,
      int capacity,
      DocumentReference itemStatusId) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('item').doc(itemCode);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Item with ID $itemCode does not exist.');
      }
      await docRef.update({
        'name': name,
        'image_url': imageUrl,
        'description': description,
        'price': price,
        'capacity': capacity,
        'item_status_id': itemStatusId,
      });
    } catch (error) {
      throw Exception('Failed to edit item: $error');
    }
  }

  // Method to disable an item in Firestore
  static Future<void> deactiveItemInFirestore(String itemCode) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('item').doc(itemCode);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Item with ID $itemCode does not exist.');
      }
      await docRef.update({
        'item_status_id':
            FirebaseFirestore.instance.collection('item_status').doc('2')
      });
      print('succiful');
    } catch (error) {
      throw Exception('Failed to edit item: $error');
    }
  }
}

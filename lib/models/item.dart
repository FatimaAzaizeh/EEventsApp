import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    required this.itemStatusId,
    required this.createdAt,
  });

  // Method to add an item to Firestore
  Future<String> addItemToFirestore() async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('item');
      final querySnapshot = await collectionRef
          .where('item_code', isEqualTo: itemCode)
          .where('vendor_id', isEqualTo: vendorId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'العنصر ذو المعرف $itemCode موجود بالفعل   .';
      }
      await collectionRef.add({
        'vendor_id': vendorId,
        'name': name,
        'item_code': itemCode,
        'image_url': imageUrl,
        'description': description,
        'price': price,
        'capacity': capacity,
        'event_type_id': eventTypeId,
        'service_type_id': serviceTypeId,
        'item_status_id': itemStatusId,
        'created_at': createdAt,
      });
      return 'تمت إضافة العنصر ذو المعرف $itemCode بنجاح  .';
    } catch (error) {
      throw Exception('فشل إضافة العنصر: $error');
    }
  }

  static Future<String> editItemInFirestore(
      String name,
      String itemCode,
      String imageUrl,
      String description,
      double price,
      int capacity,
      DocumentReference itemStatusId) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('item');
      DocumentReference vendorid = FirebaseFirestore.instance
          .collection('vendor')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final querySnapshot = await collectionRef
          .where('item_code', isEqualTo: itemCode)
          .where('vendor_id', isEqualTo: vendorid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 'العنصر ذو المعرف $itemCode غير موجود  .';
      }

      // Update each document found with the provided data
      for (final docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.update({
          'name': name,
          'image_url': imageUrl,
          'description': description,
          'price': price,
          'capacity': capacity,
          'item_status_id': itemStatusId,
        });
      }

      return 'تم تعديل العنصر ذو المعرف $itemCode بنجاح ';
    } catch (error) {
      throw Exception('فشل تعديل العنصر: $error');
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

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // This method can be called from other pages
  static Future<int> getCountOfRecords(String collectionName) async {
    try {
      // Reference to your collection
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection(collectionName);

      // Get all documents in the collection
      QuerySnapshot querySnapshot = await collectionRef.get();

      // Count the number of documents
      int count = querySnapshot.size;

      print('Number of records in the collection: $count');
      return count;
    } catch (e) {
      print('Error counting documents: $e');
      return 0;
    }
  }
}

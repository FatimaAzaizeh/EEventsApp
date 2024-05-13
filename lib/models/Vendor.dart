import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class Vendor {
  String id;
  String businessName;
  String email;
  String contactNumber;
  String logoUrl;
  String instagramUrl;
  String website;
  String bio;
  DocumentReference serviceTypesId;
  String businessTypesId;
  String address;
  String locationUrl;
  String workingHourFrom;
  String workingHourTo;
  String verificationCode;
  Timestamp createdAt;
  DocumentReference vendorStatusId;

  Vendor({
    required this.id,
    required this.businessName,
    required this.email,
    required this.contactNumber,
    required this.logoUrl,
    required this.instagramUrl,
    required this.website,
    required this.bio,
    required this.serviceTypesId,
    required this.businessTypesId,
    required this.address,
    required this.locationUrl,
    required this.workingHourFrom,
    required this.workingHourTo,
    required this.verificationCode,
    required this.createdAt,
    required this.vendorStatusId,
  });

  Future<void> addToFirestore() async {
    // Generate a new document ID (automatically provided by Firestore)
    CollectionReference vendor =
        FirebaseFirestore.instance.collection('vendor');
    // Use the generated document ID to set the document in Firestore
    await vendor.add({
      'id': id,
      'business_name': businessName,
      'email': email,
      'contact_number': contactNumber,
      'logo_url': logoUrl,
      'instagram_url': instagramUrl,
      'website': website,
      'bio': bio,
      'service_types_id': serviceTypesId,
      'business_types_id': businessTypesId,
      'address': address,
      'location_url': locationUrl,
      'working_hour_from': workingHourFrom,
      'working_hour_to': workingHourTo,
      'verification_code': verificationCode,
      'created_at': createdAt,
      'vendor_status_id': vendorStatusId,
    });
  }

  static Future<void> updateStatusIdInFirestore(
      DocumentReference new_vendor_status_id, String id) async {
    try {
      // Get a reference to the document you want to update
// Get a reference to the document you want to update
      // Get a reference to the document you want to update
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vendor')
          .where('UID', isEqualTo: id)
          .get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (assuming id is unique)
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        // Get the reference to the document
        DocumentReference vendorRef = docSnapshot.reference;

        // Update the bio field of the document
        await vendorRef.update({
          'vendor_status_id': new_vendor_status_id,
        });

        print(' updated successfully');
      } else {
        print('No document found with id: $id');
      }
    } catch (error) {
      print('Error updating : $error');
    }
  }

  static Future<bool> isVendorTypeReferenceValid(
      String VendorId, DocumentReference vendorStatusId) async {
    try {
      // Get a reference to the Vendor document
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vendor')
          .where('UID', isEqualTo: VendorId)
          .get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (assuming id is unique)
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;

        // Check if the vendor_status_id reference matches the expected reference
        return userSnapshot['vendor_status_id'] == vendorStatusId;
      } else {
        // User document does not exist
        print('User document with ID $visibleForTesting does not exist.');
        return false;
      }
    } catch (error) {
      print('Error checking user type reference validity: $error');
      return false;
    }
  }
}

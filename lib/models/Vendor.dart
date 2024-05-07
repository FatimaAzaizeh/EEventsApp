import 'package:cloud_firestore/cloud_firestore.dart';

class Vendor {
  String id;
  String businessName;
  String email;
  String contactNumber;
  String logoUrl;
  String instagramUrl;
  String website;
  String bio;
  String serviceTypesId;
  String businessTypesId;
  String address;
  String locationUrl;
  String workingHourFrom;
  String workingHourTo;
  String verificationCode;
  Timestamp createdAt;
  int vendorStatusId;

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
    String documentId =
        FirebaseFirestore.instance.collection('vendor').doc().id;
    // Use the generated document ID to set the document in Firestore
    await FirebaseFirestore.instance.collection('vendor').doc(documentId).set({
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
}

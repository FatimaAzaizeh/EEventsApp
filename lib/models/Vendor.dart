// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:testtapp/constants.dart';

final _firestore = FirebaseFirestore.instance;

// Define a Vendor class to hold Firestore document data
class Vendor {
  final String? CommercialName;
  final String? email;
  final String? socialMedia;
  final String? description;
  final bool state;

  Vendor({
    required this.CommercialName,
    required this.email,
    required this.socialMedia,
    required this.description,
    required this.state,
  });

  String? get id => null;

  Future<void> addToFirestore() async {
    // Generate a new document ID (automatically provided by Firestore)
    String documentId = _firestore.collection('VendorRequest').doc().id;
    // Use the generated document ID to set the document in Firestore
    await _firestore.collection('VendorRequest').doc(documentId).set({
      'CommercialName': this.CommercialName,
      'Email': this.email,
      'Description': this.description,
      'SocialMedia': this.socialMedia,
      'State': false,
      'ImageUrl': "ImageVendor",
    });

    try {
      DocumentReference parentDocumentRef =
          _firestore.collection('VendorRequest').doc(documentId);

      // Reference to the sub-collection you want to create
      CollectionReference subCollectionRef =
          parentDocumentRef.collection('ImageVendor');

      // Add documents to the sub-collection
      await subCollectionRef.add({
        'field1': 'value1',
        'field2': 'value2',
        // Add more fields as needed
      });

      print('Sub-collection created successfully.');
    } catch (error) {
      print('Error creating sub-collection: $error');
    }
  }
}

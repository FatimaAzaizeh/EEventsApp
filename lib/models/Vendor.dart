import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define a Vendor class to hold Firestore document data
class Vendor {
  final String? name;
  final String? image;
  final String? source;
  final String? text;
  bool state;
  final String id;

  Vendor({
    this.name,
    this.image,
    this.source,
    this.text,
    required this.state,
    required this.id,
  });
}

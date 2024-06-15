import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/constants.dart';

class FirestoreDropdown extends StatefulWidget {
  final String collectionName;
  final String dropdownLabel;
  final Function(String)? onChanged;

  const FirestoreDropdown({
    required this.collectionName,
    required this.dropdownLabel,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _FirestoreDropdownState createState() => _FirestoreDropdownState();
}

class _FirestoreDropdownState extends State<FirestoreDropdown> {
  late Stream<List<String?>> _dropdownItemsStream;

  @override
  void initState() {
    super.initState();
    _dropdownItemsStream = _fetchDropdownItems();
  }

  Stream<List<String?>> _fetchDropdownItems() {
    return FirebaseFirestore.instance
        .collection(widget.collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              // Checking if 'name' field exists and not null
              if (doc.data().containsKey('name')) {
                return doc['name'] as String?;
              }
              // Checking if 'description' field exists and not null
              else if (doc.data().containsKey('description')) {
                return doc['description'] as String?;
              }
              // If neither 'name' nor 'description' field exists
              else {
                return null;
              }
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String?>>(
      stream: _dropdownItemsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while fetching data
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return DropdownButtonFormField<String?>(
          style: StyleTextAdmin(14, Colors.black),
          decoration: InputDecoration(
              labelText: widget.dropdownLabel,
              labelStyle: StyleTextAdmin(14, Colors.black)),
          items: snapshot.data?.map((item) {
                return DropdownMenuItem<String?>(
                  value: item,
                  child: Text(item ?? ''), // Handling null values
                );
              }).toList() ??
              [],
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value!); // Adjusted the parameter
            }
          },
        );
      },
    );
  }
}

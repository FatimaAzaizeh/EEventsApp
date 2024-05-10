import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassificationDropdown extends StatefulWidget {
  final ValueChanged<String>? onClassificationSelected;

  ClassificationDropdown({this.onClassificationSelected});

  @override
  _ClassificationDropdownState createState() => _ClassificationDropdownState();
}

class _ClassificationDropdownState extends State<ClassificationDropdown> {
  String selectedClassification = ''; // Initialize with a default value
  List<String> classifications = [];

  @override
  void initState() {
    super.initState();
    fetchClassifications();
  }

  Future<void> fetchClassifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('event_classification_types')
        .get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        classifications =
            snapshot.docs.map((doc) => doc['description'] as String).toList();
        selectedClassification =
            classifications.first; // Select the first classification by default
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClassDropDown();
  }

  Column ClassDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: selectedClassification,
          hint: Text('Select Classification'),
          onChanged: (newValue) {
            setState(() {
              selectedClassification = newValue!;
              widget.onClassificationSelected
                  ?.call(newValue); // Callback to parent widget if provided
            });
          },
          items: classifications.map((classification) {
            return DropdownMenuItem<String>(
              value: classification,
              child: Text(classification),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        if (classifications.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedClassification = classifications.first;
              });
            },
            child: Text('Add Another Classification'),
          ),
      ],
    );
  }
}

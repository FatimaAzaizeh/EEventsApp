import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class StoreStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Simple Dropdown Example'),
        ),
        body: Center(
          child: SimpleDropdown(),
        ),
      ),
    );
  }
}

class SimpleDropdown extends StatefulWidget {
  @override
  _SimpleDropdownState createState() => _SimpleDropdownState();
}

class _SimpleDropdownState extends State<SimpleDropdown> {
  String _selectedItem = 'متاح'; // Initial value

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedItem,
      onChanged: (String? newValue) async {
        setState(() {
          _selectedItem = newValue!;
        });

        try {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('UID', isEqualTo: _auth.currentUser!.uid.toString())
              .get();

          // Check if any documents match the query
          if (querySnapshot.docs.isNotEmpty) {
            // Get the first document (assuming id is unique)
            DocumentSnapshot userSnapshot = querySnapshot.docs.first;

            // Check if the vendor_status_id reference matches the expected reference
            if (newValue == 'متاح')
              userSnapshot.reference.update({'is_active': true});
            else
              userSnapshot.reference.update({'is_active': false});
          } else {
            // User document does not exist
            print(
                'User document with ID ${_auth.currentUser!.uid} does not exist.');
          }
        } catch (error) {
          print('Error checking user type reference validity: $error');
        }
      },
      items: <String>['متاح', 'مغلق']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

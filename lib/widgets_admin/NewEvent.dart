import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/widgets/textfield_design.dart';

final _firestore = FirebaseFirestore.instance;

class AddEvent extends StatefulWidget {
  static const String screenRoute = 'NewEvent';
  const AddEvent({Key? key}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _auth = FirebaseAuth.instance;
  late String name; // Name of the Event
  late String classification = ''; // Classification of the Event
  late List<String> serviceType = []; // Services related to the event
  bool showSpinner = false;
  List<String> classificationList = []; // Initialize classification list

  // Method to fetch classifications from Firestore
  void fetchClassificationsFromFirestore() async {
    try {
      setState(() {
        showSpinner = true; // Show spinner when fetching data
      });
      QuerySnapshot querySnapshot =
          await _firestore.collection("Classifications").get();

      setState(() {
        classificationList.clear(); // Clear the list before adding new data
      });

      for (var docSnapshot in querySnapshot.docs) {
        setState(() {
          classificationList.add(docSnapshot.get('Name').toString());
        });
      }
      setState(() {
        showSpinner = false; // Hide spinner after fetching data
      });
    } catch (e) {
      print("Error fetching classifications: $e");
      setState(() {
        showSpinner = false; // Hide spinner if there's an error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClassificationsFromFirestore(); // Fetch classifications when widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: [
            CustomTextField(
              hintText: 'Enter Event Name:',
              keyboardType: TextInputType.name,
              onChanged: (value) {
                setState(() {
                  name = value; // Update the Name variable
                });
              },
              obscureText: false,
            ),
            SizedBox(
              height: 20,
            ),
            // Call the buildClassificationDropdown method where you want to display the dropdown
            buildClassificationDropdown(),
            SizedBox(
              height: 20,
            ),
            CustomTextField(
              hintText: 'Enter Related Services:',
              keyboardType: TextInputType.name,
              onChanged: (value) {
                setState(() {
                  serviceType = value.split(','); // Update the serviceType list
                });
              },
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }

  // Method to build the classification dropdown widget
  Widget buildClassificationDropdown() {
    return showSpinner
        ? CircularProgressIndicator() // Show spinner while fetching data
        : DropdownButton<String>(
            value:
                classificationList.isNotEmpty ? classificationList.first : null,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                classification = value!;
              });
            },
            items: classificationList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
  }
}
